import { createActions, createReducer } from 'reduxsauce'

import Immutable from 'seamless-immutable'

import colors from '~/styles/colors'

import config from '~/config'


{ Types, Creators } = createActions(
    fetchCities: [
        'country',
        'ignore',
        'limit',
        'imageWidth',
        'imageHeight',
        'replace'
    ]
    finishFetchingCities: null
    selectCity: ['city']
    deselectCity: null
    removeCity: ['city']
    addCity: ['city']
    setAllCities: ['cities']
    setCities: ['cities']
    nextCities: null
    previousCities: null
    setNoMoreCities: ['noMoreCities']
    dislikeCity: ['city']
    likeCity: ['city']
    setCountry: ['country', 'skipUpdate']
    setCitiesLoading: null
    toggleDropdown: null
    setCountries: ['countries']
    resetPrevItems: null
    resetNextItems: null
    backupCities: null
    restoreCities: ['country']
    clearLoadingCities: null
    replaceLoadingCities: ['cities']
, { prefix: 'cities/' })

export { Types as CityTypes }
export default Creators

CITIES_LOADING = ({
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
    selectedCity: null
    noMoreCities: false
    allCities: {}
    cities: CITIES_LOADING
    country: null
    countries: []
    dropdownOpen: false
    backup: {}
    dislikedCities: []
)

backupCities = (state) -> {
    state...
    backup: {
        state.backup...
        "#{ state.country.name }": {
            prevItems: state.prevItems
            cities: state.cities
            nextItems: state.nextItems
        }
    }
}

restoreCities = (state, { country }) -> {
    state...
    prevItems: state.backup[country]?.prevItems ? state.prevItems
    cities: state.backup[country]?.cities ? state.cities
    nextItems: state.backup[country]?.nextItems ? state.nextItems
}

resetPrevItems = (state, ctx) -> {
    state...
    prevItems: []
}

resetNextItems = (state, ctx) -> {
    state...
    nextItems: []
}

toggleDropdown = (state, ctx) -> {
    state...
    dropdownOpen: not state.dropdownOpen
}

setCitiesLoading = (state, ctx) -> {
    state...
    cities: CITIES_LOADING
}

setCountries = (state, { countries }) -> {
    state...
    countries
}

setCountry = (state, { country }) -> {
    state...
    country
}

previousCities = (state) ->
    previousCities = state.prevItems[-3..]
    citiesToReplace = state.cities[..(previousCities.length - 1)]
    remainingCityCount = 3 - previousCities.length
    remainingCities = if remainingCityCount > 0
        state.cities[-remainingCityCount..]
    else
        []
    {
        state...
        nextItems: [citiesToReplace..., state.nextItems...]
        prevItems: state.prevItems[..-(previousCities.length + 1)]
        cities: [previousCities..., remainingCities...]
    }

nextCities = (state) ->
    nextCities = state.nextItems[..2]
    citiesToReplace = state.cities[-nextCities.length..]
    remainingCities = state.cities[..-(nextCities.length + 1)]
    {
        state...
        nextItems: state.nextItems[nextCities.length..]
        prevItems: [state.prevItems..., citiesToReplace...]
        cities: [remainingCities..., nextCities...]
    }

setNoMoreCities = (state, { noMoreCities }) -> {
    state...
    noMoreCities
}

fetchCities = (state, ctx) -> {
    state...
    fetching: true
}

finishFetchingCities = (state) -> {
    state...
    fetching: false
}

selectCity = (state, { city }) -> {
    state...
    selectedCity: city
}

deselectCity = (state) -> {
    state...
    selectedCities: null
}

removeCity = (state, { city }) -> {
    state...
    cities: state.cities.filter((g) -> g.name isnt city.name)
}

addCity = (state, { city }) -> {
    state...
    cities: state.cities.concat([city])
}

setAllCities = (state, { cities }) -> {
    state...
    allCities: cities
}

setCities = (state, { cities }) -> {
    state...
    cities
    prevItems: [state.prevItems..., (g for g in state.cities when not g.temporary)...]
}

dislikeCity = (state, { city }) -> {
    state...
    dislikedCities: [state.dislikedCities..., city]
    prevItems: if state.prevItems.length > 0
        state.prevItems[...-1]
    else
        state.prevItems
    nextItems: if state.prevItems.length is 0 and state.nextItems.length > 0
        state.nextItems[1..]
    else
        state.nextItems
    cities: Immutable.set(
        state.cities,
        state.cities.indexOf(city),
        (
            state.prevItems[state.prevItems.length - 1] ?
            state.nextItems[0] ?
            CITIES_LOADING[0]
        )
    )
}

replaceLoadingCities = (state, { cities }) -> {
    state...
    cities: ((if not g.loading then g else cities.pop() ? g) for g in state.cities)
}

clearLoadingCities = (state) -> {
    state...
    cities: (a for a in state.cities when not a.loading)
}


ACTION_HANDLERS =
  "#{ Types.SELECT_CITY }": selectCity
  "#{ Types.DESELECT_CITY }": deselectCity
  "#{ Types.REMOVE_CITY }": removeCity
  "#{ Types.ADD_CITY }": addCity
  "#{ Types.SET_CITIES }": setCities
  "#{ Types.SET_ALL_CITIES }": setAllCities
  "#{ Types.FETCH_CITIES }": fetchCities
  "#{ Types.FINISH_FETCHING_CITIES }": finishFetchingCities
  "#{ Types.SET_NO_MORE_CITIES }": setNoMoreCities
  "#{ Types.NEXT_CITIES }": nextCities
  "#{ Types.PREVIOUS_CITIES }": previousCities
  "#{ Types.DISLIKE_CITY }": dislikeCity
  "#{ Types.SET_CITIES_LOADING }": setCitiesLoading
  "#{ Types.TOGGLE_DROPDOWN }": toggleDropdown
  "#{ Types.SET_COUNTRY }": setCountry
  "#{ Types.SET_COUNTRIES }": setCountries
  "#{ Types.RESET_PREV_ITEMS }": resetPrevItems
  "#{ Types.RESET_NEXT_ITEMS }": resetNextItems
  "#{ Types.BACKUP_CITIES }": backupCities
  "#{ Types.RESTORE_CITIES }": restoreCities
  "#{ Types.REPLACE_LOADING_CITIES }": replaceLoadingCities
  "#{ Types.CLEAR_LOADING_CITIES }": clearLoadingCities

export reducer = createReducer(INITIAL_STATE, ACTION_HANDLERS)
