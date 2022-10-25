import { createActions, createReducer } from 'reduxsauce'

import _ from 'lodash'
import Immutable from 'seamless-immutable'

filterName = /\s*\(no\s*(explicit|dislikes|explicit\/dislikes)\)/

{ Types, Creators } = createActions(
    setPlaylist: ['playlist']
    setName: ['name']
    setPlaylistName: ['name']
    addTracks: ['tracks']
    setTracks: ['tracks']
    setOrder: ['attribute', 'direction']
    applyOrder: null
    resetOrder: null
    filterPlaylist: [
        'sourcePlaylistId'
        'ownerId'
        'name'
        'order'
        'filterExplicit'
        'filterDislikes'
        'image'
    ]
    clonePlaylist: ['sourcePlaylistId', 'ownerId', 'name', 'order', 'image']
    fetchPlaylist: ['user', 'playlistId', 'limit', 'offset', 'onlyTracks']
    fetchTracks: ['user', 'playlistId', 'limit', 'offset']
    fetchAudioFeatures: ['tracks', 'ownerId', 'playlistId']
    setAudioFeatures: ['audioFeatures']
    setNormalizedAudioFeatures: ['normalizedAudioFeatures']
    finishFetchingAudioFeatures: ['ok']
    renamePlaylist: ['playlistId', 'name']
    reorderPlaylist: ['playlistId', 'order']
    replaceTracks: ['playlistId', 'tracks', 'order']
    savePlaylist: ['name', 'tracks', 'image', 'artists', 'filterExplicit']
    finishCloningPlaylist: ['ok']
    finishFetchingPlaylist: ['ok']
    finishFetchingTracks: ['ok']
    finishRenamingPlaylist: ['ok']
    finishFilteringPlaylist: ['ok']
    finishReorderingPlaylist: ['ok']
    finishReplacingTracks: ['ok']
    finishSavingPlaylist: ['ok']
    resetPlaylist: null
    setFilterExplicit: ['filterExplicit']
    setFilterDislikes: ['filterDislikes']
    toggleSidebar: null
    setRecommended: ['recommended']
    setModified: null
    dislikeArtist: ['artist']
    setSidebarHidden: ['sidebarHidden']
, { prefix: 'playlists/' })

export { Types as PlaylistTypes }
export default Creators

export INITIAL_STATE = Immutable(
    initialPlaylist: null
    name: null
    playlist: null
    loading:
        filteringPlaylist: false
        fetchingPlaylist: false
        fetchingTracks: false
        fetchingAudioFeatures: false
        savingPlaylist: false
        cloningPlaylist: false
        renamingPlaylist: false
        reorderingPlaylist: false
        replacingTracks: false
    modified:
        name: false
        order: false
        tracks: false
        dislikes: false
        explicit: false
    saved:
        filterExplicit: false
        filterDislikes: false
        name: null
        order: {}
    order: {}
    filterExplicit: false
    filterDislikes: false
    sidebarHidden: true
    recommended: false
)

USELESS_FEATURE_VALUES = [undefined, null, 0]

computeHash = (features) ->
    return ("#{ k }_#{ v }".replace('-', '_') for k, v of features).sort().join('_')

computeAudioFeatures = (features, tracks) ->
    hash = computeHash(features)

    audioFeatures = {}
    tracks = Immutable.asMutable(tracks, { deep: true })
    for item, i in tracks
        totals = { (item.track.audioFeatureTotals ? { })... }
        if not totals[hash]?
            adjustedFeatures = {}
            for feature, value of features
                if value not in USELESS_FEATURE_VALUES
                    adjustedFeatures[feature] = (
                        (item.track.normalizedAudioFeatures[feature] ? 0) * value
                    )
            totals[hash] = _.sum(Object.values(adjustedFeatures))
            item.audioFeatureTotals = totals
    return tracks

orderBy = (features, tracks) ->
    hash = computeHash(features)

    tracks = computeAudioFeatures(features, tracks)
    sortedTracks = _.sortBy(tracks, [(track) -> track.audioFeatureTotals[hash]])
    return sortedTracks

setOrder = (state, { attribute, direction }) -> {
    state...
    order: if direction?
        { state.order..., "#{ attribute }": direction }
    else
        Immutable.without(state.order, attribute)
}

applyOrder = (state) -> {
    state...
    modified: { state.modified..., order: not _.isEqual(state.order, state.saved.order) }
    playlist: Immutable.setIn(
        state.playlist,
        ['tracks', 'items'],
        orderBy(state.order, state.playlist.tracks.items)
    )
    initialPlaylist: Immutable.setIn(
        state.initialPlaylist,
        ['tracks', 'items'],
        computeAudioFeatures(state.order, state.initialPlaylist.tracks.items)
    )
}

resetOrder = (state) -> {
    state...
    order: {}
    modified: { state.modified..., order: not _.isEqual(state.order, state.saved.order) }
}

addTracks = (state, { tracks }) -> {
    state...
    playlist: Immutable.setIn(
        state.playlist,
        ['tracks', 'items'],
        state.playlist.tracks.items.concat(tracks)
    )
    initialPlaylist: Immutable.setIn(
        state.playlist,
        ['tracks', 'items'],
        state.initialPlaylist.tracks.items.concat(tracks)
    )
}

setTracks = (state, { tracks }) -> {
    state...
    playlist: Immutable.setIn(state.playlist, ['tracks', 'items'], tracks)
    modified: { state.modified..., tracks: true }
}

setAudioFeatures = (state, { audioFeatures }) ->
    tracks = Immutable.asMutable(state.playlist.tracks.items, { deep: true })
    for t in tracks
        if audioFeatures[t.track.id]?
            t.track.audioFeatures = audioFeatures[t.track.id]
    initialTracks = Immutable.asMutable(state.initialPlaylist.tracks.items, { deep: true })
    for t in initialTracks
        if audioFeatures[t.track.id]?
            t.track.audioFeatures = audioFeatures[t.track.id]
    {
        state...
        playlist: Immutable.setIn(state.playlist, ['tracks', 'items'], tracks)
        initialPlaylist: Immutable.setIn(
            state.initialPlaylist,
            ['tracks', 'items'],
            initialTracks
        )
    }

setNormalizedAudioFeatures = (state, { normalizedAudioFeatures }) ->
    tracks = Immutable.asMutable(state.playlist.tracks.items, { deep: true })
    for t in tracks
        t.track.normalizedAudioFeatures = normalizedAudioFeatures[t.track.id]
    initialTracks = Immutable.asMutable(state.initialPlaylist.tracks.items, { deep: true })
    for t in initialTracks
        t.track.normalizedAudioFeatures = normalizedAudioFeatures[t.track.id]
    {
        state...
        playlist: Immutable.setIn(state.playlist, ['tracks', 'items'], tracks)
        initialPlaylist: Immutable.setIn(
            state.initialPlaylist,
            ['tracks', 'items'],
            initialTracks
        )
    }

fetchPlaylist = (state) -> {
    state...
    loading: { state.loading..., fetchingPlaylist: true }
}

fetchTracks = (state) -> {
    state...
    loading: { state.loading..., fetchingTracks: true }
}

fetchAudioFeatures = (state) -> {
    state...
    loading: { state.loading..., fetchingAudioFeatures: true }
}

getPlaylistName = (filterExplicit, filterDislikes, playlistName) ->
    if filterExplicit and filterDislikes
        "#{ playlistName.replace(filterName, '') } (no explicit/dislikes)"
    else if filterExplicit
        "#{ playlistName.replace(filterName, '') } (no explicit)"
    else if filterDislikes
        "#{ playlistName.replace(filterName, '') } (no dislikes)"
    else
        playlistName.replace(filterName, '')

setFilterExplicit = (state, { filterExplicit }) -> {
    state...
    filterExplicit
    name: getPlaylistName(filterExplicit, state.filterDislikes, state.playlist.name)
    modified: {
        state.modified...
        explicit: state.saved.filterExplicit isnt filterExplicit
    }
    playlist: {
        state.playlist...
        name: getPlaylistName(filterExplicit, state.filterDislikes, state.playlist.name)
    }
}

setFilterDislikes = (state, { filterDislikes }) -> {
    state...
    filterDislikes
    name: getPlaylistName(state.filterExplicit, filterDislikes, state.playlist.name)
    modified: {
        state.modified...
        dislikes: state.saved.filterDislikes isnt filterDislikes
    }
    playlist: {
        state.playlist...
        name: getPlaylistName(state.filterExplicit, filterDislikes, state.playlist.name)
    }
}

toggleSidebar = (state) -> {
    state...
    sidebarHidden: not state.sidebarHidden
}

setSidebarHidden = (state, { sidebarHidden }) -> {
    state...
    sidebarHidden
}

setRecommended = (state, { recommended }) -> {
    state...
    recommended
}

renamePlaylist = (state) -> {
    state...
    loading: { state.loading..., renamingPlaylist: true }
}

reorderPlaylist = (state) -> {
    state...
    loading: { state.loading..., reorderingPlaylist: true }
}

replaceTracks = (state) -> {
    state...
    loading: { state.loading..., replacingTracks: true }
}

savePlaylist = (state) -> {
    state...
    loading: { state.loading..., savingPlaylist: true }
}

clonePlaylist = (state) -> {
    state...
    loading: { state.loading..., cloningPlaylist: true }
}

filterPlaylist = (state) -> {
    state...
    loading: { state.loading..., filteringPlaylist: true }
}

finishFetchingPlaylist = (state, { ok }) -> {
    state...
    loading: { state.loading..., fetchingPlaylist: false }
}

finishFetchingTracks = (state, { ok }) -> {
    state...
    loading: { state.loading..., fetchingTracks: false }
}

finishFetchingAudioFeatures = (state, { ok }) -> {
    state...
    loading: { state.loading..., fetchingAudioFeatures: false }
}

finishRenamingPlaylist = (state, { ok }) -> {
    state...
    saved: {
        state.saved...
        order: if ok then state.order else state.saved.order
        name: if ok then state.playlist.name else state.saved.name
    }
    modified: { state.modified..., name: not ok }
    loading: { state.loading..., renamingPlaylist: false }
}

finishReorderingPlaylist = (state, { ok }) -> {
    state...
    saved: {
        state.saved...
        order: if ok then state.order else state.saved.order
        name: if ok then state.playlist.name else state.saved.name
    }
    modified: { state.modified..., order: not ok }
    loading: { state.loading..., reorderingPlaylist: false }
}

finishReplacingTracks = (state, { ok }) -> {
    state...
    saved: {
        state.saved...
        order: if ok then state.order else state.saved.order
        name: if ok then state.playlist.name else state.saved.name
    }
    modified: { state.modified..., order: not ok, tracks: not ok }
    loading: { state.loading..., replacingTracks: false }
}

finishSavingPlaylist = (state, { ok }) -> {
    state...
    saved: {
        state.saved...
        order: if ok then state.order else state.saved.order
        name: if ok then state.playlist.name else state.saved.name
    }
    modified: { state.modified..., name: not ok, order: not ok, tracks: not ok }
    loading: { state.loading..., savingPlaylist: false }
}

finishCloningPlaylist = (state, { ok }) -> {
    state...
    saved: {
        state.saved...
        order: if ok then state.order else state.saved.order
        name: if ok then state.playlist.name else state.saved.name
    }
    modified: { state.modified..., name: not ok, order: not ok, tracks: not ok }
    loading: { state.loading..., cloningPlaylist: false }
}

finishFilteringPlaylist = (state, { ok }) -> {
    state...
    modified: {
        state.modified...
        name: not ok
        order: not ok
        tracks: not ok
        explicit: not ok
        dislikes: not ok
    }
    loading: { state.loading..., filteringPlaylist: false }
    saved: {
        state.saved...
        filterExplicit: state.filterExplicit
        filterDislikes: state.filterDislikes
        order: if ok then state.order else state.saved.order
        name: if ok then state.playlist.name else state.saved.name
    }
}

setPlaylist = (state, { playlist }) -> {
    state...
    playlist
    name: playlist.name
    initialPlaylist: playlist
    saved: { state.saved..., name: if playlist?.id? then playlist.name else null }
    modified: { state.modified..., name: not playlist?.id?, tracks: not playlist?.id? }
}

setName = (state, { name }) -> {
    state...
    name
}

setPlaylistName = (state, { name }) -> {
    state...
    name
    modified: { state.modified..., name: name isnt state.saved.name }
    playlist: { state.playlist..., name: name }
    initialPlaylist: { state.initialPlaylist..., name: name }
}

dislikeArtist = (state, { artist }) -> {
    state...
    modified: { state.modified..., tracks: true }
}

resetPlaylist = (state) -> {
    state...
    playlist: state.initialPlaylist
    modified: { state.modified..., order: not _.isEqual(state.order, state.saved.order) }
}

setModified = (state) -> {
    state...
    modified: { state.modified..., tracks: true }
}


ACTION_HANDLERS =
    "#{ Types.ADD_TRACKS }": addTracks
    "#{ Types.APPLY_ORDER }": applyOrder
    "#{ Types.CLONE_PLAYLIST }": clonePlaylist
    "#{ Types.DISLIKE_ARTIST }": dislikeArtist
    "#{ Types.FETCH_AUDIO_FEATURES }": fetchAudioFeatures
    "#{ Types.FETCH_PLAYLIST }": fetchPlaylist
    "#{ Types.FETCH_TRACKS }": fetchTracks
    "#{ Types.FINISH_CLONING_PLAYLIST }": finishCloningPlaylist
    "#{ Types.FINISH_FETCHING_AUDIO_FEATURES }": finishFetchingAudioFeatures
    "#{ Types.FINISH_FETCHING_PLAYLIST }": finishFetchingPlaylist
    "#{ Types.FINISH_FETCHING_TRACKS }": finishFetchingTracks
    "#{ Types.FINISH_RENAMING_PLAYLIST }": finishRenamingPlaylist
    "#{ Types.FINISH_REORDERING_PLAYLIST }": finishReorderingPlaylist
    "#{ Types.FINISH_REPLACING_TRACKS }": finishReplacingTracks
    "#{ Types.FINISH_SAVING_PLAYLIST }": finishSavingPlaylist
    "#{ Types.RENAME_PLAYLIST }": renamePlaylist
    "#{ Types.REORDER_PLAYLIST }": reorderPlaylist
    "#{ Types.REPLACE_TRACKS }": replaceTracks
    "#{ Types.RESET_ORDER }": resetOrder
    "#{ Types.RESET_PLAYLIST }": resetPlaylist
    "#{ Types.SAVE_PLAYLIST }": savePlaylist
    "#{ Types.SET_AUDIO_FEATURES }": setAudioFeatures
    "#{ Types.SET_FILTER_DISLIKES }": setFilterDislikes
    "#{ Types.SET_FILTER_EXPLICIT }": setFilterExplicit
    "#{ Types.SET_NORMALIZED_AUDIO_FEATURES }": setNormalizedAudioFeatures
    "#{ Types.SET_ORDER }": setOrder
    "#{ Types.SET_PLAYLIST }": setPlaylist
    "#{ Types.SET_PLAYLIST_NAME }": setPlaylistName
    "#{ Types.SET_NAME }": setName
    "#{ Types.SET_RECOMMENDED }": setRecommended
    "#{ Types.SET_TRACKS }": setTracks
    "#{ Types.SET_MODIFIED }": setModified
    "#{ Types.TOGGLE_SIDEBAR }": toggleSidebar
    "#{ Types.SET_SIDEBAR_HIDDEN }": setSidebarHidden
    "#{ Types.FILTER_PLAYLIST }": filterPlaylist
    "#{ Types.FINISH_FILTERING_PLAYLIST }": finishFilteringPlaylist


export reducer = createReducer(INITIAL_STATE, ACTION_HANDLERS)
