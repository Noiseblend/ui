import { createActions, createReducer } from 'reduxsauce'

import Immutable from 'seamless-immutable'

import colors from '~/styles/colors'

import config from '~/config'


{ Types, Creators } = createActions(
    fetchCountries: [
        'ignore',
        'limit',
        'imageWidth',
        'imageHeight',
        'replace'
    ]
    finishFetchingCountries: null
    fetchPlaylists: ['country']
    finishFetchingPlaylists: null
    addPlaylists: ['country', 'playlists']
    selectCountry: ['country']
    deselectCountry: null
    removeCountry: ['country']
    addCountry: ['country']
    setAllCountries: ['countries']
    setCountries: ['countries']
    nextCountries: null
    previousCountries: null
    setNoMoreCountries: ['noMoreCountries']
    replaceLoadingCountries: ['countries']
    dislikeCountry: ['country']
    likeCountry: ['country']
    resetPrevItems: null
    resetNextItems: null
    clearLoadingCountries: null
, { prefix: 'countries/' })

export { Types as CountryTypes }
export default Creators

COUNTRIES_LOADING = ({
    name: 'loading'
    temporary: true
    loading: true
    image:
        color: colors.BLACK.alpha(0.9).rgb().string()
        textColor: colors.MAGENTA.rgb().string()
} for i in [1..config.CARD_LIMIT])

export INITIAL_STATE = Immutable(
    prevItems: []
    nextItems: []
    fetching: true
    selectedCountry: null
    noMoreCountries: false
    allCountries: []
    countries: COUNTRIES_LOADING
    fetchingPlaylists: false
    playlists: {}
    dislikedCountries: []
)

resetPrevItems = (state, ctx) -> {
    state...
    prevItems: []
}

resetNextItems = (state, ctx) -> {
    state...
    nextItems: []
}

replaceLoadingCountries = (state, { countries }) -> {
    state...
    countries: ((if not a.loading then a else countries.pop() ? a) for a in state.countries)
}

clearLoadingCountries = (state) -> {
    state...
    countries: (a for a in state.countries when not a.loading)
}

previousCountries = (state) ->
    previousCountries = state.prevItems[-3..]
    countriesToReplace = state.countries[..(previousCountries.length - 1)]
    remainingCountryCount = 3 - previousCountries.length
    remainingCountries = if remainingCountryCount > 0
        state.countries[-remainingCountryCount..]
    else
        []
    {
        state...
        nextItems: [countriesToReplace..., state.nextItems...]
        prevItems: state.prevItems[..-(previousCountries.length + 1)]
        countries: [previousCountries..., remainingCountries...]
    }

nextCountries = (state) ->
    nextCountries = state.nextItems[..2]
    countriesToReplace = state.countries[-nextCountries.length..]
    remainingCountries = state.countries[..-(nextCountries.length + 1)]
    {
        state...
        nextItems: state.nextItems[nextCountries.length..]
        prevItems: [state.prevItems..., countriesToReplace...]
        countries: [remainingCountries..., nextCountries...]
    }

setNoMoreCountries = (state, { noMoreCountries }) -> {
    state...
    noMoreCountries
}

fetchCountries = (state, ctx) -> {
    state...
    fetching: true
}

fetchPlaylists = (state, ctx) -> {
    state...
    fetchingPlaylists: true
}

finishFetchingCountries = (state) -> {
    state...
    fetching: false
}

finishFetchingPlaylists = (state) -> {
    state...
    fetchingPlaylists: false
}

addPlaylists = (state, { country, playlists }) -> {
    state...
    playlists: { state.playlists..., "#{ country }": playlists }
}

selectCountry = (state, { country }) -> {
    state...
    selectedCountry: country
}

deselectCountry = (state) -> {
    state...
    selectedCountry: null
}

removeCountry = (state, { country }) -> {
    state...
    countries: state.countries.filter((g) -> g.name isnt country.name)
}

addCountry = (state, { country }) -> {
    state...
    countries: state.countries.concat([country])
}

setCountries = (state, { countries }) -> {
    state...
    countries
    prevItems: [state.prevItems..., (g for g in state.countries when not g.temporary)...]
}

setAllCountries = (state, { countries }) -> {
    state...
    allCountries: countries
}

dislikeCountry = (state, { country }) -> {
    state...
    dislikedCountries: [state.dislikedCountries..., country]
    prevItems: if state.prevItems.length > 0
        state.prevItems[...-1]
    else
        state.prevItems
    nextItems: if state.prevItems.length is 0 and state.nextItems.length > 0
        state.nextItems[1..]
    else
        state.nextItems
    countries: Immutable.set(
        state.countries,
        state.countries.indexOf(country),
        (
            state.prevItems[state.prevItems.length - 1] ?
            state.nextItems[0] ?
            COUNTRIES_LOADING[0]
        )
    )
}


ACTION_HANDLERS =
  "#{ Types.SELECT_COUNTRY }": selectCountry
  "#{ Types.DESELECT_COUNTRY }": deselectCountry
  "#{ Types.REMOVE_COUNTRY }": removeCountry
  "#{ Types.ADD_COUNTRY }": addCountry
  "#{ Types.SET_ALL_COUNTRIES }": setAllCountries
  "#{ Types.SET_COUNTRIES }": setCountries
  "#{ Types.FETCH_COUNTRIES }": fetchCountries
  "#{ Types.FINISH_FETCHING_COUNTRIES }": finishFetchingCountries
  "#{ Types.SET_NO_MORE_COUNTRIES }": setNoMoreCountries
  "#{ Types.NEXT_COUNTRIES }": nextCountries
  "#{ Types.PREVIOUS_COUNTRIES }": previousCountries
  "#{ Types.REPLACE_LOADING_COUNTRIES }": replaceLoadingCountries
  "#{ Types.DISLIKE_COUNTRY }": dislikeCountry
  "#{ Types.RESET_PREV_ITEMS }": resetPrevItems
  "#{ Types.RESET_NEXT_ITEMS }": resetNextItems
  "#{ Types.FETCH_PLAYLISTS }": fetchPlaylists
  "#{ Types.FINISH_FETCHING_PLAYLISTS }": finishFetchingPlaylists
  "#{ Types.ADD_PLAYLISTS }": addPlaylists
  "#{ Types.CLEAR_LOADING_COUNTRIES }": clearLoadingCountries

export reducer = createReducer(INITIAL_STATE, ACTION_HANDLERS)
