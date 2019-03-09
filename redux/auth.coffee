import { createActions, createReducer } from 'reduxsauce'

import Immutable from 'seamless-immutable'

{ Types, Creators } = createActions(
    setAuthToken: ['authToken']
    setBlendToken: ['blendToken']
    setAuthenticated: ['authenticated']
    getAuthStatus: ['ctx']
    startAuthentication: null
    finishAuthentication: ['code', 'state']
    authenticationSuccess: null
    authenticationFailed: null
, { prefix: 'auth/' })

export AuthTypes = Types
export default Creators

export INITIAL_STATE = Immutable(
    authToken: null
    blendToken: null
    authenticated: false
    authenticating: false
)

setBlendToken = (state, { blendToken }) -> {
    state...
    blendToken: blendToken
}

setAuthToken = (state, { authToken }) -> {
    state...
    authToken: authToken
}

setAuthenticated = (state, { authenticated }) -> {
    state...
    authenticated: authenticated
}

startAuthentication = (state) -> {
    state...
    authenticated: false
    authenticating: true
}

authenticationSuccess = (state) -> {
    state...
    authenticated: true
    authenticating: false
}

authenticationFailed = (state) -> {
    state...
    authenticated: false
    authenticating: false
}


ACTION_HANDLERS =
    "#{ Types.SET_AUTH_TOKEN }": setAuthToken
    "#{ Types.SET_BLEND_TOKEN }": setBlendToken
    "#{ Types.SET_AUTHENTICATED }": setAuthenticated
    "#{ Types.START_AUTHENTICATION }": startAuthentication
    "#{ Types.AUTHENTICATION_SUCCESS }": authenticationSuccess
    "#{ Types.AUTHENTICATION_FAILED }": authenticationFailed


export reducer = createReducer(INITIAL_STATE, ACTION_HANDLERS)
