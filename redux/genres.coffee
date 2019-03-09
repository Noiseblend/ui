import { createActions, createReducer } from 'reduxsauce'

import Immutable from 'seamless-immutable'

import colors from '~/styles/colors'

import config from '~/config'


{ Types, Creators } = createActions(
    fetchGenres: [
        'timeRange',
        'ignore',
        'limit',
        'imageWidth',
        'imageHeight',
        'replace'
    ]
    finishFetchingGenres: null
    fetchPlaylists: ['genre']
    finishFetchingPlaylists: null
    addPlaylists: ['genre', 'playlists']
    selectGenre: ['genre']
    deselectGenre: null
    removeGenre: ['genre']
    addGenre: ['genre']
    setGenres: ['genres', 'saveHistory']
    setAllGenres: ['genres']
    nextGenres: null
    previousGenres: null
    setNoMoreGenres: ['noMoreGenres']
    setTimeRange: ['timeRange', 'skipUpdate']
    toggleDropdown: null
    setGenresLoading: null
    replaceLoadingGenres: ['genres']
    clearLoadingGenres: null
    dislikeGenre: ['genre']
    likeGenre: ['genre']
    resetPrevItems: null
    resetNextItems: null
    backupGenres: null
    restoreGenres: ['timeRange']
, { prefix: 'genres/' })

export { Types as GenreTypes }
export default Creators

GENRES_LOADING = ({
    name: 'loading'
    temporary: true
    loading: true
    image:
        color: colors.BLACK.alpha(0.9).rgb().string()
        textColor: colors.MAGENTA.rgb().string()
} for i in [1..config.CARD_LIMIT])

export INITIAL_STATE = Immutable(
    prevItems: []
    selectedGenre: null
    nextItems: []
    fetching: true
    fetchingPlaylists: false
    playlists: {}
    noMoreGenres: false
    allGenres: {}
    genres: GENRES_LOADING
    dropdownOpen: false
    timeRange: config.DEFAULTS.TIME_RANGE
    backup: {}
    dislikedGenres: []
)

backupGenres = (state) -> {
    state...
    backup: {
        state.backup...
        "#{ state.timeRange }": {
            prevItems: state.prevItems
            genres: state.genres
            nextItems: state.nextItems
        }
    }
}

restoreGenres = (state, { timeRange }) -> {
    state...
    prevItems: state.backup[timeRange]?.prevItems ? state.prevItems
    genres: state.backup[timeRange]?.genres ? state.genres
    nextItems: state.backup[timeRange]?.nextItems ? state.nextItems
}

resetPrevItems = (state, ctx) -> {
    state...
    prevItems: []
}

resetNextItems = (state, ctx) -> {
    state...
    nextItems: []
}

replaceLoadingGenres = (state, { genres }) -> {
    state...
    genres: ((if not g.loading then g else genres.pop() ? g) for g in state.genres)
}

clearLoadingGenres = (state) -> {
    state...
    genres: (a for a in state.genres when not a.loading)
}

previousGenres = (state) ->
    previousGenres = state.prevItems[-3..]
    genresToReplace = state.genres[..(previousGenres.length - 1)]
    remainingGenreCount = 3 - previousGenres.length
    remainingGenres = if remainingGenreCount > 0
        state.genres[-remainingGenreCount..]
    else
        []
    {
        state...
        nextItems: [genresToReplace..., state.nextItems...]
        prevItems: state.prevItems[..-(previousGenres.length + 1)]
        genres: [previousGenres..., remainingGenres...]
    }

nextGenres = (state) ->
    nextGenres = state.nextItems[..2]
    genresToReplace = state.genres[-nextGenres.length..]
    remainingGenres = state.genres[..-(nextGenres.length + 1)]
    {
        state...
        nextItems: state.nextItems[nextGenres.length..]
        prevItems: [state.prevItems..., genresToReplace...]
        genres: [remainingGenres..., nextGenres...]
    }

setNoMoreGenres = (state, { noMoreGenres }) -> {
    state...
    noMoreGenres
}

fetchGenres = (state, ctx) -> {
    state...
    fetching: true
}

fetchPlaylists = (state, ctx) -> {
    state...
    fetchingPlaylists: true
}

finishFetchingGenres = (state) -> {
    state...
    fetching: false
}

finishFetchingPlaylists = (state) -> {
    state...
    fetchingPlaylists: false
}

addPlaylists = (state, { genre, playlists }) -> {
    state...
    playlists: { state.playlists..., "#{ genre }": playlists }
}

selectGenre = (state, { genre }) -> {
    state...
    selectedGenre: genre
}

deselectGenre = (state) -> {
    state...
    selectedGenre: null
}

removeGenre = (state, { genre }) -> {
    state...
    genres: state.genres.filter((g) -> g.name isnt genre.name)
}

addGenre = (state, { genre }) -> {
    state...
    genres: state.genres.concat([genre])
}

setGenres = (state, { genres, saveHistory = true }) -> {
    state...
    genres
    prevItems: if saveHistory
        [state.prevItems..., (g for g in state.genres when not g.temporary)...]
    else
        state.prevItems
}

setAllGenres = (state, { genres }) -> {
    state...
    allGenres: genres
}

setTimeRange = (state, { timeRange }) -> {
    state...
    timeRange
}

toggleDropdown = (state, ctx) -> {
    state...
    dropdownOpen: not state.dropdownOpen
}

setGenresLoading = (state, ctx) -> {
    state...
    genres: GENRES_LOADING
}

dislikeGenre = (state, { genre }) -> {
    state...
    dislikedGenres: [state.dislikedGenres..., genre]
    prevItems: if state.prevItems.length > 0
        state.prevItems[...-1]
    else
        state.prevItems
    nextItems: if state.prevItems.length is 0 and state.nextItems.length > 0
        state.nextItems[1..]
    else
        state.nextItems
    genres: Immutable.set(
        state.genres,
        state.genres.indexOf(genre),
        (
            state.prevItems[state.prevItems.length - 1] ?
            state.nextItems[0] ?
            GENRES_LOADING[0]
        )
    )
}


ACTION_HANDLERS =
    "#{ Types.SELECT_GENRE }": selectGenre
    "#{ Types.DESELECT_GENRE }": deselectGenre
    "#{ Types.REMOVE_GENRE }": removeGenre
    "#{ Types.ADD_GENRE }": addGenre
    "#{ Types.SET_GENRES }": setGenres
    "#{ Types.SET_ALL_GENRES }": setAllGenres
    "#{ Types.FETCH_GENRES }": fetchGenres
    "#{ Types.FINISH_FETCHING_GENRES }": finishFetchingGenres
    "#{ Types.FETCH_PLAYLISTS }": fetchPlaylists
    "#{ Types.FINISH_FETCHING_PLAYLISTS }": finishFetchingPlaylists
    "#{ Types.SET_NO_MORE_GENRES }": setNoMoreGenres
    "#{ Types.NEXT_GENRES }": nextGenres
    "#{ Types.PREVIOUS_GENRES }": previousGenres
    "#{ Types.SET_TIME_RANGE }": setTimeRange
    "#{ Types.SET_GENRES_LOADING }": setGenresLoading
    "#{ Types.TOGGLE_DROPDOWN }": toggleDropdown
    "#{ Types.REPLACE_LOADING_GENRES }": replaceLoadingGenres
    "#{ Types.DISLIKE_GENRE }": dislikeGenre
    "#{ Types.RESET_PREV_ITEMS }": resetPrevItems
    "#{ Types.RESET_NEXT_ITEMS }": resetNextItems
    "#{ Types.ADD_PLAYLISTS }": addPlaylists
    "#{ Types.BACKUP_GENRES }": backupGenres
    "#{ Types.RESTORE_GENRES }": restoreGenres
    "#{ Types.CLEAR_LOADING_GENRES }": clearLoadingGenres

export reducer = createReducer(INITIAL_STATE, ACTION_HANDLERS)
