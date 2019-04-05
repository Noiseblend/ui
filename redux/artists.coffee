import { createActions, createReducer } from 'reduxsauce'

import Immutable from 'seamless-immutable'

import colors from '~/styles/colors'

import config from '~/config'


{ Types, Creators } = createActions(
    fetchArtists: [
        'timeRange',
        'ignore',
        'limit',
        'imageWidth',
        'imageHeight',
        'replace'
    ]
    finishFetchingArtists: null
    nextArtists: null
    previousArtists: null
    selectArtist: ['artist']
    deselectArtist: ['artist']
    removeArtist: ['artist']
    addArtist: ['artist']
    setAllArtists: ['artists']
    setArtists: ['artists', 'saveHistory']
    replaceUnselectedArtists: ['artists', 'saveHistory']
    replaceLoadingArtists: ['artists']
    clearLoadingArtists: null
    setNoMoreArtists: ['noMoreArtists']
    setTimeRange: ['timeRange', 'skipUpdate']
    toggleDropdown: null
    setArtistsLoading: null
    discover: null
    dislikeArtist: ['artist']
    likeArtist: ['artist']
    resetPrevItems: null
    resetNextItems: null
    backupArtists: null
    restoreArtists: ['timeRange']
    searchArtists: ['query', 'limit', 'imageWidth', 'imageHeight']
    finishSearchingArtists: null
    setArtistSearchQuery: ['query']
    setBackedUpBeforeSearch: ['backedUpBeforeSearch']
    focusInput: null
    defocusInput: null
, { prefix: 'artists/' })

export { Types as ArtistTypes }
export default Creators

ARTISTS_LOADING = ({
    name: 'loading'
    temporary: true
    loading: true
    searching: false
    selected: false
    image:
        color: colors.BLACK.alpha(0.9).rgb().string()
        textColor: colors.MAGENTA.rgb().string()
} for i in [1..config.CARD_LIMIT])

export INITIAL_STATE = Immutable(
    allArtists: {}
    artists: ARTISTS_LOADING
    prevItems: []
    nextItems: []
    fetching: true
    noMoreArtists: false
    timeRange: 'medium_term'
    dropdownOpen: false
    backup: {}
    query: ''
    backedUpBeforeSearch: false
    dislikedArtists: []
    inputFocused: false
)

focusInput = (state) -> {
    state...
    inputFocused: true
}

defocusInput = (state) -> {
    state...
    inputFocused: false
}

setBackedUpBeforeSearch = (state, { backedUpBeforeSearch }) -> {
    state...
    backedUpBeforeSearch
}

setArtistSearchQuery = (state, { query }) -> {
    state...
    query: query
}

searchArtists = (state, { query, limit }) -> {
    state...
    searching: true
    query: query
}

finishSearchingArtists = (state) -> {
    state...
    searching: false
}

backupArtists = (state) -> {
    state...
    backup: {
        state.backup...
        "#{ state.timeRange }": {
            prevItems: state.prevItems
            artists: state.artists
            nextItems: state.nextItems
        }
    }
}

restoreArtists = (state, { timeRange }) ->
    backup = state.backup[timeRange ? state.timeRange]
    if not backup?
        return state

    selectedIndices = (
        i for i in [0...config.CARD_LIMIT] when state.artists[i]?.selected
    ) ? []
    unselectedIndices = (
        i for i in [0...config.CARD_LIMIT] when not state.artists[i]?.selected
    ) ? []

    postponedArtists = (
        backup.artists[i] for i in selectedIndices when (
            backup.artists[i]?.id isnt state.artists[i]?.id
        )
    ) ? []

    artists = (null for i in [0...config.CARD_LIMIT])
    for i in [0...config.CARD_LIMIT]
        if i in unselectedIndices
            artists[i] = (
                backup.artists[i] ?
                backup.prevItems.pop() ?
                postponedArtists.shift() ?
                state.artists[i]
            )
        else
            artists[i] = (
                state.artists[i] ?
                backup.prevItems.pop() ?
                postponedArtists.shift() ?
                backup.artists[i]
            )
    {
        state...
        prevItems: backup.prevItems
        artists: artists
        nextItems: [postponedArtists..., backup.nextItems...]
    }

resetPrevItems = (state, ctx) -> {
    state...
    prevItems: []
}

resetNextItems = (state, ctx) -> {
    state...
    nextItems: []
}

previousArtists = (state) ->
    unselectedArtists = (a for a in state.artists when not a.selected)
    previousArtists = state.prevItems[-unselectedArtists.length..]
    {
        state...
        nextItems: [unselectedArtists..., state.nextItems...]
        prevItems: state.prevItems[..-(previousArtists.length + 1)]
        artists: (
            (if a.selected then a else previousArtists.pop() ? a) for a in state.artists
        )
    }

nextArtists = (state) ->
    unselectedArtists = (a for a in state.artists when not a.selected)
    nextArtists = state.nextItems[...unselectedArtists.length]
    {
        state...
        nextItems: state.nextItems[nextArtists.length..]
        prevItems: [state.prevItems..., unselectedArtists...]
        artists: ((if a.selected then a else nextArtists.pop() ? a) for a in state.artists)
    }

setNoMoreArtists = (state, { noMoreArtists }) -> {
    state...
    noMoreArtists
}

fetchArtists = (state) -> {
    state...
    fetching: true
}

discover = (state) -> {
    state...
    fetching: true
}

finishFetchingArtists = (state) -> {
    state...
    fetching: false
}

selectArtist = (state, { artist }) -> {
    state...
    artists: ({ a..., selected: if a is artist
        true
    else
        a.selected
    } for a in state.artists)
}

deselectArtist = (state, { artist }) -> {
    state...
    artists: ({ a..., selected: if a is artist
        false
    else
        a.selected
    } for a in state.artists)
}

removeArtist = (state, { artist }) -> {
    state...
    artists: state.artists.filter((existingArtist) -> existingArtist isnt artist)
    prevItems: [state.prevItems..., artist]
}

addArtist = (state, { artist }) -> {
    state...
    artists: [artist, state.artists...]
}

setAllArtists = (state, { artists }) -> {
    state...
    allArtists: artists
}

setArtists = (state, { artists, saveHistory = true }) -> {
    state...
    artists
    prevItems: if saveHistory
        [state.prevItems..., (a for a in state.artists when not a.temporary)...]
    else
        state.prevItems
}

replaceUnselectedArtists = (state, { artists, saveHistory }) -> {
    state...
    prevItems: if saveHistory
        [
            state.prevItems...,
            (a for a in state.artists when not a.selected and not a.loading)...
        ]
    else
        state.prevItems
    artists: ((if a.selected then a else artists.shift() ? a) for a in state.artists)
}

replaceLoadingArtists = (state, { artists }) -> {
    state...
    artists: ((if not a.loading then a else artists.shift() ? a) for a in state.artists)
}

clearLoadingArtists = (state) -> {
    state...
    artists: (a for a in state.artists when a? and not a.loading)
}

setTimeRange = (state, { timeRange }) -> {
    state...
    timeRange
}

toggleDropdown = (state, ctx) -> {
    state...
    dropdownOpen: not state.dropdownOpen
}

setArtistsLoading = (state, ctx) -> {
    state...
    artists: ((
        if state.artists[i]?.selected
            state.artists[i]
        else
            ARTISTS_LOADING[i]
        ) for i in [0...ARTISTS_LOADING.length]
    )
}

dislikeArtist = (state, { artist }) -> {
    state...
    dislikedArtists: [state.dislikedArtists..., artist]
    prevItems: if state.prevItems.length > 0
        state.prevItems[...-1]
    else
        state.prevItems
    nextItems: if state.prevItems.length is 0 and state.nextItems.length > 0
        state.nextItems[1..]
    else
        state.nextItems
    artists: Immutable.set(
        state.artists,
        state.artists.indexOf(artist),
        (
            state.prevItems[state.prevItems.length - 1] ?
            state.nextItems[0] ?
            ARTISTS_LOADING[0]
        )
    )
}

ACTION_HANDLERS =
  "#{ Types.SELECT_ARTIST }": selectArtist
  "#{ Types.DESELECT_ARTIST }": deselectArtist
  "#{ Types.REMOVE_ARTIST }": removeArtist
  "#{ Types.ADD_ARTIST }": addArtist
  "#{ Types.SET_ARTISTS }": setArtists
  "#{ Types.SET_ALL_ARTISTS }": setAllArtists
  "#{ Types.FETCH_ARTISTS }": fetchArtists
  "#{ Types.FINISH_FETCHING_ARTISTS }": finishFetchingArtists
  "#{ Types.REPLACE_UNSELECTED_ARTISTS }": replaceUnselectedArtists
  "#{ Types.REPLACE_LOADING_ARTISTS }": replaceLoadingArtists
  "#{ Types.CLEAR_LOADING_ARTISTS }": clearLoadingArtists
  "#{ Types.SET_NO_MORE_ARTISTS }": setNoMoreArtists
  "#{ Types.NEXT_ARTISTS }": nextArtists
  "#{ Types.PREVIOUS_ARTISTS }": previousArtists
  "#{ Types.SET_TIME_RANGE }": setTimeRange
  "#{ Types.TOGGLE_DROPDOWN }": toggleDropdown
  "#{ Types.SET_ARTISTS_LOADING }": setArtistsLoading
  "#{ Types.DISCOVER }": discover
  "#{ Types.DISLIKE_ARTIST }": dislikeArtist
  "#{ Types.RESET_PREV_ITEMS }": resetPrevItems
  "#{ Types.RESET_NEXT_ITEMS }": resetNextItems
  "#{ Types.BACKUP_ARTISTS }": backupArtists
  "#{ Types.RESTORE_ARTISTS }": restoreArtists
  "#{ Types.SEARCH_ARTISTS }": searchArtists
  "#{ Types.FINISH_SEARCHING_ARTISTS }": finishSearchingArtists
  "#{ Types.SET_ARTIST_SEARCH_QUERY }": setArtistSearchQuery
  "#{ Types.SET_BACKED_UP_BEFORE_SEARCH }": setBackedUpBeforeSearch
  "#{ Types.FOCUS_INPUT }": focusInput
  "#{ Types.DEFOCUS_INPUT }": defocusInput

export reducer = createReducer(INITIAL_STATE, ACTION_HANDLERS)
