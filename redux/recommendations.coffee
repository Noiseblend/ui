import { createActions, createReducer } from 'reduxsauce'

import Immutable from 'seamless-immutable'


{ Types, Creators } = createActions(
    fetchRecommendations: ['timeRange', 'ignore', 'limit']
    selectRecommendation: ['recommendation']
    deselectRecommendation: ['recommendation']
    removeRecommendation: ['recommendation']
    addRecommendation: ['recommendation']
    setRecommendations: ['recommendations']
    setTuneableAttribute: ['attribute', 'value']
    applyTuning: ['items']
    applyTuningAsync: ['items']
    finishApplyingTuning: null
    resetTuning: null
    toggleDeviceDropdown: null
    closePlaylistTunerWebsocket: null
    openPlaylistTunerWebsocket: null
    setState: ['newState']
, { prefix: 'recommendations/' })

export { Types as RecommendationTypes }
export default Creators

export INITIAL_STATE = Immutable(
    selectedRecommendations: []
    recommendations: []
    tuning: false
    deviceDropdownOpen: false
    tuneableAttributes: {}
    playlistTunerWebsocketOpen: false
)

setState = (state, { newState }) -> {
    state...
    newState...
}

applyTuning = (state) -> {
    state...
    tuning: true
}

finishApplyingTuning = (state) -> {
    state...
    tuning: false
}

selectRecommendation = (state, { recommendation }) -> {
    state...
    selectedRecommendations: state.selectedRecommendations.concat([recommendation])
}

deselectRecommendation = (state, { recommendation }) -> {
    state...
    selectedRecommendations: state.selectedRecommendations.filter(
        (existingRecommendation) -> existingRecommendation isnt recommendation
    )
}

removeRecommendation = (state, { recommendation }) -> {
    state...
    recommendations: state.recommendations.filter(
        (existingRecommendation) -> existingRecommendation isnt recommendation
    )
}

addRecommendation = (state, { recommendation }) -> {
    state...
    recommendations: state.recommendations.concat([recommendation])
}

setRecommendations = (state, { recommendations }) -> {
    state...
    recommendations
}

toggleDeviceDropdown = (state, {}) -> {
    state...
    deviceDropdownOpen: not state.deviceDropdownOpen
}

setTuneableAttribute = (state, { attribute, value }) -> {
    state...
    tuneableAttributes: if value?
        { state.tuneableAttributes..., "#{ attribute }": value }
    else
        Immutable.without(state.tuneableAttributes, attribute)
}

resetTuning = (state, {}) -> {
    state...
    tuneableAttributes: {}
}

ACTION_HANDLERS =
    "#{ Types.SELECT_RECOMMENDATION }": selectRecommendation
    "#{ Types.DESELECT_RECOMMENDATION }": deselectRecommendation
    "#{ Types.REMOVE_RECOMMENDATION }": removeRecommendation
    "#{ Types.ADD_RECOMMENDATION }": addRecommendation
    "#{ Types.SET_RECOMMENDATIONS }": setRecommendations
    "#{ Types.TOGGLE_DEVICE_DROPDOWN }": toggleDeviceDropdown
    "#{ Types.SET_TUNEABLE_ATTRIBUTE }": setTuneableAttribute
    "#{ Types.RESET_TUNING }": resetTuning
    "#{ Types.APPLY_TUNING }": applyTuning
    "#{ Types.FINISH_APPLYING_TUNING }": finishApplyingTuning
    "#{ Types.SET_STATE }": setState

export reducer = createReducer(INITIAL_STATE, ACTION_HANDLERS)
