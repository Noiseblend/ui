import { createActions, createReducer } from 'reduxsauce'

import Immutable from 'seamless-immutable'

{ Types, Creators } = createActions(
    alexaAuthentication: ['queryAlexaParams', 'cookieAlexaParams', 'hasQueryAlexaParams', 'hasCookieAlexaParams']
    startAuthentication: null
    finishAuthentication: ['code', 'state']
    authenticationSuccess: null
    authenticationFailed: null
, { prefix: 'auth/' })

export AuthTypes = Types
export default Creators

export INITIAL_STATE = Immutable(
    authenticating: false
)

startAuthentication = (state) -> {
    state...
    authenticating: true
}

authenticationSuccess = (state) -> {
    state...
    authenticating: false
}

authenticationFailed = (state) -> {
    state...
    authenticating: false
}


ACTION_HANDLERS =
    "#{ Types.START_AUTHENTICATION }": startAuthentication
    "#{ Types.AUTHENTICATION_SUCCESS }": authenticationSuccess
    "#{ Types.AUTHENTICATION_FAILED }": authenticationFailed


export reducer = createReducer(INITIAL_STATE, ACTION_HANDLERS)
