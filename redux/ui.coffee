import { createActions, createReducer } from 'reduxsauce'

import Immutable from 'seamless-immutable'

import colors from '~/styles/colors'

import config from '~/config'


{ Types, Creators } = createActions(
    setOpenLinksVisible: ['openLinksVisible']
    setMobile: ['mobile']
    setMediumScreen: ['mediumScreen']
    setUndoHidden: ['undoHidden']
    setCircularMenuOpen: ['circularMenuOpen']
    setWindowWidth: ['windowWidth']
    setShowAdditionalPlaylists: ['showAdditionalPlaylists']
    setFocusProfile: ['focusProfile']
    setFocusHome: ['focusHome']
    setShowTooltipHome: ['showTooltipHome']
    setShowTooltipProfile: ['showTooltipProfile']
    setShowMoreAttributes: ['showMoreAttributes']
    setFallbackUserImage: ['fallbackUserImage']
    setBackground: ['background']
    setIcon: ['icon']
    setColor: ['color']
    setHideBrand: ['hideBrand']
    setBrandColors: ['brandColors']
    setState: ['newState']
    setNextState: ['nextState']
, { prefix: 'ui/' })

export { Types as UITypes }
export default Creators

export INITIAL_STATE = Immutable(
    windowWidth: config.WIDTH.onekay
    mobile: false
    mediumScreen: false
    undoHidden: true
    openLinksVisible: false
    circularMenuOpen: false
    showAdditionalPlaylists: false
    focusProfile: false
    focusHome: false
    showTooltipProfile: false
    showTooltipHome: false
    showMoreAttributes: false
    fallbackUserImage: null
    background: null
    icon: null
    color: null
    hideBrand: null
    title: null
    description: null
    brandColors:
        color: colors.WHITE.s()
        hoverColor: colors.YELLOW.s()
    navbar:
        background: colors.WHITE.alpha(0).s()
        color: colors.WHITE.s()
    nextState: {}
    loading: false
    isDrawerOpen: false
)

setNextState = (state, { nextState }) -> {
    state...
    nextState
}

setState = (state, { newState }) -> {
    state...
    newState...
}

setBrandColors = (state, { brandColors }) -> {
    state...
    brandColors
}

setHideBrand = (state, { hideBrand }) -> {
    state...
    hideBrand
}

setBackground = (state, { background }) -> {
    state...
    background
}

setIcon = (state, { icon }) -> {
    state...
    icon
}

setColor = (state, { color }) -> {
    state...
    color
}

setShowAdditionalPlaylists = (state, { showAdditionalPlaylists }) -> {
    state...
    showAdditionalPlaylists
}

setShowMoreAttributes = (state, { showMoreAttributes }) -> {
    state...
    showMoreAttributes
}

setFocusProfile = (state, { focusProfile }) -> {
    state...
    circularMenuOpen: focusProfile
    focusProfile: focusProfile
}

setFallbackUserImage = (state, { fallbackUserImage }) -> {
    state...
    fallbackUserImage
}

setFocusHome = (state, { focusHome }) -> {
    state...
    circularMenuOpen: focusHome
    focusHome: focusHome
}

setShowTooltipHome = (state, { showTooltipHome }) -> {
    state...
    showTooltipHome
}

setShowTooltipProfile = (state, { showTooltipProfile }) -> {
    state...
    showTooltipProfile
}

setWindowWidth = (state, { windowWidth }) -> {
    state...
    windowWidth
}

setCircularMenuOpen = (state, { circularMenuOpen }) -> {
    state...
    circularMenuOpen
}

setOpenLinksVisible = (state, { openLinksVisible }) -> {
    state...
    openLinksVisible
}

setUndoHidden = (state, { undoHidden }) -> {
    state...
    undoHidden
}

setMobile = (state, { mobile }) -> {
    state...
    mobile
}

setMediumScreen = (state, { mediumScreen }) -> {
    state...
    mediumScreen
}

ACTION_HANDLERS =
    "#{ Types.SET_OPEN_LINKS_VISIBLE }": setOpenLinksVisible
    "#{ Types.SET_MOBILE }": setMobile
    "#{ Types.SET_MEDIUM_SCREEN }": setMediumScreen
    "#{ Types.SET_UNDO_HIDDEN }": setUndoHidden
    "#{ Types.SET_CIRCULAR_MENU_OPEN }": setCircularMenuOpen
    "#{ Types.SET_WINDOW_WIDTH }": setWindowWidth
    "#{ Types.SET_SHOW_ADDITIONAL_PLAYLISTS }": setShowAdditionalPlaylists
    "#{ Types.SET_FOCUS_PROFILE }": setFocusProfile
    "#{ Types.SET_FOCUS_HOME }": setFocusHome
    "#{ Types.SET_SHOW_TOOLTIP_PROFILE }": setShowTooltipProfile
    "#{ Types.SET_SHOW_TOOLTIP_HOME }": setShowTooltipHome
    "#{ Types.SET_SHOW_MORE_ATTRIBUTES }": setShowMoreAttributes
    "#{ Types.SET_FALLBACK_USER_IMAGE }": setFallbackUserImage
    "#{ Types.SET_BACKGROUND }": setBackground
    "#{ Types.SET_ICON }": setIcon
    "#{ Types.SET_COLOR }": setColor
    "#{ Types.SET_HIDE_BRAND }": setHideBrand
    "#{ Types.SET_BRAND_COLORS }": setBrandColors
    "#{ Types.SET_STATE }": setState
    "#{ Types.SET_NEXT_STATE }": setNextState

export reducer = createReducer(INITIAL_STATE, ACTION_HANDLERS)
