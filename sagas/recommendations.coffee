import { eventChannel } from 'redux-saga'
import { all, call, put, race, select, take } from 'redux-saga/effects'

import _ from 'lodash'

import PlaylistActions from '~/redux/playlists'
import RecommendationActions, { RecommendationTypes } from '~/redux/recommendations'
import SpotifyActions from '~/redux/spotify'

import config from '~/config'



export applyTuning = (api, { items }) ->
    tuneableAttributes = yield select(
        (state) -> state.recommendations.present.tuneableAttributes
    )
    tuneableAttributes = _.cloneDeep(tuneableAttributes)
    if tuneableAttributes.durationMs?
        if typeof tuneableAttributes.durationMs is 'object'
            tuneableAttributes.durationMs[0] *= 60000
            tuneableAttributes.durationMs[1] *= 60000
        else
            tuneableAttributes.durationMs *= 60000

    [res, x] = yield all([
        call(
            api.recommendations,
            items,
            tuneableAttributes,
            limit = 100,
            withTuneableAttributes = true
        ),
        put(PlaylistActions.setRecommended(true))
    ])
    unless res.ok
        yield put([
            RecommendationActions.finishApplyingTuning()
        ])
        yield return


    yield put([
        PlaylistActions.setTracks(({ track: t } for t in res.data)),
        RecommendationActions.finishApplyingTuning()
    ])
    return

watchMessages = (socket) ->
    eventChannel((emit) ->
        socket.onmessage = (event) ->
            data = JSON.parse(event.data)
            emit(data)

        return () -> socket.close()
    )


setTracks = (chan) ->
    loop
        data = yield take(chan)
        yield put([
            PlaylistActions.setTracks(({ track: t } for t in data))
            PlaylistActions.applyOrder()
        ])

sendTuneableAttributes = (socket) ->
    loop
        { items } = yield take(RecommendationTypes.APPLY_TUNING_ASYNC)
        tuneableAttributes = yield select(
            (state) -> state.recommendations.present.tuneableAttributes
        )
        tuneableAttributes = _.cloneDeep(tuneableAttributes)
        if tuneableAttributes.durationMs?
            if typeof tuneableAttributes.durationMs is 'object'
                tuneableAttributes.durationMs[0] *= 60000
                tuneableAttributes.durationMs[1] *= 60000
            else
                tuneableAttributes.durationMs *= 60000

        data = {
            items...
            tuneableAttributes
            limit: 100
            withTuneableAttributes: true
        }

        if socket.readyState is WebSocket.OPEN
            yield call([socket, socket.send], JSON.stringify(data))

export openPlaylistTunerWebsocket = () ->
    token = yield select((state) -> state.auth.authToken)
    socket = new WebSocket("#{ config.WS_URL }/playlist-tuner?token=#{ token }")
    socketChannel = yield call(watchMessages, socket)
    yield put(RecommendationActions.setState(playlistTunerWebsocketOpen: true))

    { cancel } = yield race(
        task: all [
            call(setTracks, socketChannel),
            call(sendTuneableAttributes, socket)
        ]
        cancel: take(RecommendationTypes.CLOSE_PLAYLIST_TUNER_WEBSOCKET)
    )

    if cancel
        yield put(RecommendationActions.setState(playlistTunerWebsocketOpen: false))
        socketChannel.close()
