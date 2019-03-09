import { createActions, createReducer } from 'reduxsauce'

import Immutable from 'seamless-immutable'

import config from '~/config'

{ Types, Creators } = createActions(
    fade: ['stopVolume', 'startVolume', 'direction', 'timeMinutes', 'device']
    setFadeDirection: ['fadeDirection']
    setFadeTimeMinutes: ['fadeTimeMinutes']
    setStartVolume: ['startVolume']
    setStopVolume: ['stopVolume']
    toggleFade: null
    play: ['device', 'items', 'volume', 'filterExplicit', 'fade']
    pause: ['device']
    nextTrack: ['device']
    previousTrack: ['device']
    setDevices: ['devices']
    fetchDevices: null
    setDeviceUnavailable: ['deviceUnavailable']
    setDevicePlaying: ['playing', 'device']
    setPlayback: ['playback']
    openDevicesWatcherWebsocket: ['polling']
    closeDevicesWatcherWebsocket: ['polling']
    changeDevicesWatcherPolling: ['polling']
    openPlaybackControllerWebsocket: null
    closePlaybackControllerWebsocket: null
    setState: ['newState']
    playBlend: ['params', 'token']
, { prefix: 'player/' })

export PlayerTypes = Types
export default Creators


export INITIAL_STATE = Immutable(
    fadeDirection: 1
    fadeTimeMinutes: config.DEFAULTS.FADE_MINUTES
    startVolume: config.DEFAULTS.FADE_VOLUME_MIN
    stopVolume: config.DEFAULTS.FADE_VOLUME_MAX
    fadeEnabled: false
    deviceUnavailable: false
    devices: []
    playback: null
    devicesWatcherWebsocketOpen: false
    playbackControllerWebsocketOpen: false
    noTracks: false
    blendPlaylist: null
    playingBlend: true
)

setState = (state, { newState }) -> {
    state...
    newState...
}

setFadeDirection = (state, { fadeDirection }) -> {
    state...
    fadeDirection
}

setDevicePlaying = (state, { device, playing }) -> {
    state...
    devices: ({
        d...,
        isPlaying: if d.id is device
            playing
        else
            false
    } for d in state.devices)
}

setPlayback = (state, { playback }) -> {
    state...
    playback
}

setDeviceUnavailable = (state, { deviceUnavailable }) -> {
    state...
    deviceUnavailable
}

toggleFade = (state) -> {
    state...
    fadeEnabled: not state.fadeEnabled
}


setFadeTimeMinutes = (state, { fadeTimeMinutes }) -> {
    state...
    fadeTimeMinutes
}

setStartVolume = (state, { startVolume }) -> {
    state...
    startVolume: Math.max(0, Math.min(100, startVolume))
}

setStopVolume = (state, { stopVolume }) -> {
    state...
    stopVolume: Math.max(0, Math.min(100, stopVolume))
}

setDevices = (state, { devices }) -> {
    state...
    devices
}

playBlend = (state) -> {
    state...
    playingBlend: true
}

ACTION_HANDLERS =
    "#{ Types.SET_FADE_DIRECTION }": setFadeDirection
    "#{ Types.SET_DEVICE_UNAVAILABLE }": setDeviceUnavailable
    "#{ Types.SET_FADE_TIME_MINUTES }": setFadeTimeMinutes
    "#{ Types.SET_START_VOLUME }": setStartVolume
    "#{ Types.SET_STOP_VOLUME }": setStopVolume
    "#{ Types.TOGGLE_FADE }": toggleFade
    "#{ Types.SET_DEVICES }": setDevices
    "#{ Types.SET_DEVICE_PLAYING }": setDevicePlaying
    "#{ Types.SET_PLAYBACK }": setPlayback
    "#{ Types.SET_STATE }": setState
    "#{ Types.PLAY_BLEND }": playBlend

export reducer = createReducer(INITIAL_STATE, ACTION_HANDLERS)
