import { eventChannel } from 'redux-saga'
import { all, call, put, race, select, take, takeLatest } from 'redux-saga/effects'

import { getPointTags } from '~/lib/time'
import { getAuthTokenCookie } from '~/lib/session'

import PlayerActions, { PlayerTypes } from '~/redux/player'
import SpotifyActions from '~/redux/spotify'

import config from '~/config'


export playBlend = (api, { params, token }) ->
    { blend, device, volume, filterExplicit, fade, deviceId, play } = params
    api.setHeader('BlendToken', token)

    blendRes = yield call(api.blend, params)
    if not blendRes.ok and blendRes.status is 404
        yield put(PlayerActions.setState(noTracks: true, playingBlend: false))
    unless blendRes.ok
        return

    { tracks, playlist } = blendRes.data
    point = {
        getPointTags({ blend: blend })...
        measurement: config.MEASUREMENTS.BLEND_PLAY
        fields: {
            tracks: (tracks ? []).join(',')
            device: device
            deviceId: deviceId
            volume: volume
            filterExplicit: filterExplicit
        }
    }
    yield all([
        put(PlayerActions.setState(blendPlaylist: playlist, playingBlend: false))
    ])


export fade = (api, { stopVolume, startVolume, direction, timeMinutes, device }) ->
    if direction is 1
        start = Math.min(startVolume, stopVolume)
        stop = Math.max(startVolume, stopVolume)
    else
        start = Math.max(startVolume, stopVolume)
        stop = Math.min(startVolume, stopVolume)

    res = yield call(api.fade, stop, start, direction, timeMinutes, device)
    unless res.ok
        yield return

    return

export play = (api, { device, items, volume, filterExplicit, fade }) ->
    res = yield call(api.play, device, items, volume, filterExplicit, fade)
    unless res.ok
        return

    if not res.data.playback?.isPlaying
        if res.data.reason is 'DEVICE_UNAVAILABLE'
            yield put([
                PlayerActions.setDeviceUnavailable(true)
                SpotifyActions.setInfoMessage(
                    'Spotify says the device is unavailable ¯\\_(ツ)_/¯'
                )
            ])
    else
        yield put([
            PlayerActions.setDevicePlaying(true, device)
            PlayerActions.setPlayback(res.data.playback)
        ])

export pause = (api, { device }) ->
    res = yield call(api.pause, device)
    unless res.ok
        return

    if res.data.playback?.isPlaying
        if res.data.reason is 'DEVICE_UNAVAILABLE'
            yield put([
                PlayerActions.setDeviceUnavailable(true)
                SpotifyActions.setInfoMessage(
                    'Spotify says the device is unavailable ¯\\_(ツ)_/¯'
                )
            ])
    else
        yield put([
            PlayerActions.setDevicePlaying(false, device)
            PlayerActions.setPlayback(res.data.playback)
        ])


export nextTrack = (api, { device }) ->
    res = yield call(api.nextTrack, device)
    unless res.ok
        return

    if res.data.worked
        if res.data.reason is 'DEVICE_UNAVAILABLE'
            yield put([
                PlayerActions.setDeviceUnavailable(true)
                SpotifyActions.setInfoMessage(
                    'Spotify says the device is unavailable ¯\\_(ツ)_/¯'
                )
            ])

export previousTrack = (api, { device }) ->
    res = yield call(api.previousTrack, device)
    unless res.ok
        return

    if res.data.worked
        if res.data.reason is 'DEVICE_UNAVAILABLE'
            yield put([
                PlayerActions.setDeviceUnavailable(true)
                SpotifyActions.setInfoMessage(
                    'Spotify says the device is unavailable ¯\\_(ツ)_/¯'
                )
            ])

export fetchDevices = (api) ->
    res = yield call(api.devices)
    unless res.ok
        return

    yield put([
        PlayerActions.setDevices(res.data.devices)
        PlayerActions.setPlayback(res.data.playback)
    ])

watchMessages = (socket) ->
    eventChannel((emit) ->
        socket.onmessage = (event) ->
            data = JSON.parse(event.data)
            emit(data)

        return () -> socket.close()
    )

setDevicesAndPlayback = (chan) ->
    loop
        data = yield take(chan)
        yield put([
            PlayerActions.setDevices(data.devices)
            PlayerActions.setPlayback(data.playback)
        ])

setPlayback = (chan) ->
    loop
        data = yield take(chan)
        yield put(
            PlayerActions.setPlayback(data)
        )

changeDevicesWatcherPolling = (socket) ->
    loop
        { polling } = yield take(PlayerTypes.CHANGE_DEVICES_WATCHER_POLLING)
        if socket.readyState is WebSocket.OPEN
            yield call([socket, socket.send], JSON.stringify(polling))

controlPlayback = (socket) ->
    loop
        { type, data... } = yield take([
            PlayerTypes.PLAY
            PlayerTypes.PAUSE
            PlayerTypes.NEXT_TRACK
            PlayerTypes.PREVIOUS_TRACK
        ])

        action = type[7..]
        if action is 'PLAY'
            data = { data..., data.items... }
        else
            data = {}

        if socket.readyState is WebSocket.OPEN
            yield call([socket, socket.send], JSON.stringify({ action, data... }))

export openDevicesWatcherWebsocket = ({ polling }) ->
    token = getAuthTokenCookie()
    socket = new WebSocket("#{ config.WS_URL }/devices-watcher/#{ polling }?token=#{ token }")
    socketChannel = yield call(watchMessages, socket)
    yield put(PlayerActions.setState(devicesWatcherWebsocketOpen: true))

    { cancel } = yield race(
        task: all [
            call(setDevicesAndPlayback, socketChannel),
            call(changeDevicesWatcherPolling, socket)
        ]
        cancel: take(PlayerTypes.CLOSE_DEVICES_WATCHER_WEBSOCKET)
    )

    if cancel
        yield put(PlayerActions.setState(devicesWatcherWebsocketOpen: false))
        socketChannel.close()

export openPlaybackControllerWebsocket = () ->
    token = getAuthTokenCookie()
    socket = new WebSocket("#{ config.WS_URL }/playback-controller?token=#{ token }")
    socketChannel = yield call(watchMessages, socket)
    yield put(PlayerActions.setState(playbackControllerWebsocketOpen: true))

    { cancel } = yield race(
        task: all [
            call(setDevicesAndPlayback, socketChannel),
            call(controlPlayback, socket)
        ]
        cancel: take(PlayerTypes.CLOSE_PLAYBACK_CONTROLLER_WEBSOCKET)
    )

    if cancel
        yield put(PlayerActions.setState(playbackControllerWebsocketOpen: false))
        socketChannel.close()
