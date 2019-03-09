import { createActions, createReducer } from 'reduxsauce'

import Immutable from 'seamless-immutable'

import '~/lib/str'

{ Types, Creators } = createActions(
    getUserDetails: null
    setUserDetails: ['details']
    setUser: ['user']
    setErrorMessage: ['errorMessage']
    setSentryEventId: ['sentryEventId']
    setSuccessMessage: ['successMessage']
    setInfoMessage: ['infoMessage']
    setLoading: ['loading', 'page']
    resetLoading: null
    setEmail: ['email']
, { prefix: 'spotify/' })

export SpotifyTypes = Types
export default Creators

INITIAL_LOADING =
    artists: false
    genres: false
    countries: false
    cities: false

export INITIAL_STATE = Immutable(
    user: null
    sentryEventId: null
    errorMessage: null
    successMessage: null
    infoMessage: null
    loading: INITIAL_LOADING
)

resetLoading = (state) -> {
    state...
    loading: INITIAL_LOADING
}

setLoading = (state, { loading, page }) -> {
    state...
    loading: Immutable.set(state.loading, page, loading)
}

setUser = (state, { user }) -> {
    state...
    user
}

setSentryEventId = (state, { sentryEventId }) -> {
    state...
    sentryEventId
}

setUserDetails = (state, details) -> {
    state...
    user: { state.user..., details... }
}

setErrorMessage = (state, { errorMessage }) -> {
    state...
    errorMessage: if errorMessage?.problem?
        if errorMessage.data?.length > 0
            errorMessage.data
        else
            errorMessage.problem.replace('_', ' ').toTitleCase()
    else
        errorMessage
    sentryEventId: errorMessage?.sentryEventId
}

setSuccessMessage = (state, { successMessage }) -> {
    state...
    successMessage
}

setInfoMessage = (state, { infoMessage }) -> {
    state...
    infoMessage
}

ACTION_HANDLERS =
    "#{ Types.SET_USER }": setUser
    "#{ Types.SET_LOADING }": setLoading
    "#{ Types.RESET_LOADING }": resetLoading
    "#{ Types.SET_ERROR_MESSAGE }": setErrorMessage
    "#{ Types.SET_SUCCESS_MESSAGE }": setSuccessMessage
    "#{ Types.SET_INFO_MESSAGE }": setInfoMessage
    "#{ Types.SET_USER_DETAILS }": setUserDetails
    "#{ Types.SET_SENTRY_EVENT_ID }": setSentryEventId

export reducer = createReducer(INITIAL_STATE, ACTION_HANDLERS)
