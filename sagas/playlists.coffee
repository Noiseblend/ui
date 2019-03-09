import { all, call, put, select, take } from 'redux-saga/effects'

import _ from 'lodash'

import PlaylistActions from '~/redux/playlists'
import SpotifyActions from '~/redux/spotify'

import config from '~/config'


export savePlaylist = (api, { name, tracks, image, artists, filterExplicit }) ->
    res = yield call(api.savePlaylist, name, tracks, image, artists, filterExplicit)
    unless res.ok
        yield put([
            PlaylistActions.finishSavingPlaylist(false)
        ])
        yield return

    playlist = yield select((state) -> state.playlists.present.playlist)
    yield put([
        PlaylistActions.setPlaylist({
            (res.data ? playlist)...
            tracks: playlist.tracks ? res.data?.tracks
            image: playlist.image
            discover: playlist.discover
            artistIds: playlist.artistIds
            artistNames: playlist.artistNames
        }),
        PlaylistActions.finishSavingPlaylist(true)
    ])
    return

export renamePlaylist = (api, { playlistId, name }) ->
    res = yield call(api.renamePlaylist, playlistId, name)
    unless res.ok
        yield put([
            PlaylistActions.finishRenamingPlaylist(false)
        ])
        yield return

    yield put(PlaylistActions.finishRenamingPlaylist(true))
    return

export reorderPlaylist = (api, { playlistId, order }) ->
    res = yield call(api.reorderPlaylist, playlistId, order)
    unless res.ok
        yield put([
            PlaylistActions.finishReorderingPlaylist(false)
        ])
        yield return

    yield put(PlaylistActions.finishReorderingPlaylist(true))
    return

export replaceTracks = (api, { playlistId, tracks, order }) ->
    res = yield call(api.replaceTracks, playlistId, tracks, order)
    unless res.ok
        yield put([
            PlaylistActions.finishReplacingTracks(false)
        ])
        yield return

    yield put(PlaylistActions.finishReplacingTracks(true))
    return

export clonePlaylist = (api, { sourcePlaylistId, ownerId, name, order, image }) ->
    res = yield call(api.clonePlaylist, sourcePlaylistId, ownerId, name, order, image)
    unless res.ok
        yield put([
            PlaylistActions.finishCloningPlaylist(false)
        ])
        yield return

    playlist = yield select((state) -> state.playlists.present.playlist)
    yield put([
        PlaylistActions.setPlaylist({
            (res.data ? playlist)...
            tracks: playlist.tracks ? res.data?.tracks
            image: playlist.image
            discover: playlist.discover
            artistIds: playlist.artistIds
            artistNames: playlist.artistNames
        }),
        PlaylistActions.finishCloningPlaylist(true)
    ])
    return

export filterPlaylist = (
    api, { sourcePlaylistId, ownerId, name, order, filterExplicit, filterDislikes, image }
) ->
    res = yield call(
        api.filterPlaylist, sourcePlaylistId, ownerId, name,
        order, filterExplicit, filterDislikes, image
    )
    unless res.ok
        yield put([
            PlaylistActions.finishFilteringPlaylist(false)
        ])
        yield return

    playlist = yield select((state) -> state.playlists.present.playlist)
    yield put([
        PlaylistActions.setPlaylist({
            (res.data ? playlist)...
            tracks: playlist.tracks ? res.data?.tracks
            image: playlist.image
            discover: playlist.discover
            artistIds: playlist.artistIds
            artistNames: playlist.artistNames
        }),
        PlaylistActions.finishFilteringPlaylist(true)
    ])
    return

export fetchPlaylist = (api, { user, playlistId, limit, offset, onlyTracks }) ->
    res = yield call(api.playlist, user, playlistId, limit, offset, onlyTracks)
    unless res.ok
        yield put([
            PlaylistActions.finishFetchingPlaylist(false)
        ])
        yield return

    yield put([
        PlaylistActions.setPlaylist(res.data),
        PlaylistActions.finishFetchingPlaylist(true)
    ])
    return

export fetchTracks = (api, { user, playlistId, limit, offset }) ->
    res = yield call(api.playlist, user, playlistId, limit, offset, true)
    unless res.ok
        yield put([
            PlaylistActions.finishFetchingTracks(false)
        ])
        yield return

    yield put([
        PlaylistActions.addTracks(res.data.tracks.items),
        PlaylistActions.finishFetchingTracks(true)
    ])
    return

export fetchAudioFeatures = (api, { tracks, ownerId, playlistId }) ->
    res = yield call(api.audioFeatures, tracks, ownerId, playlistId)
    unless res.ok
        yield put([
            PlaylistActions.finishFetchingAudioFeatures(false)
        ])
        yield return

    audioFeatures = res.data
    oldAudioFeatures = {}
    tracks = yield select((state) -> state.playlists.present.playlist?.tracks?.items ? [])
    for t in tracks
        if t.track.audioFeatures?
            oldAudioFeatures[t.track.id] = t.track.audioFeatures
        else if audioFeatures[t.track.id]?
            audioFeatures[t.track.id].popularity = t.track.popularity
    normalizedAudioFeatures = normalizeFeatures({ oldAudioFeatures..., audioFeatures... })

    yield put([
        PlaylistActions.setAudioFeatures(audioFeatures),
        PlaylistActions.setNormalizedAudioFeatures(normalizedAudioFeatures),
        PlaylistActions.finishFetchingAudioFeatures(true)
    ])
    return

normalizeFeatures = (features) ->
    features = _.cloneDeep(features)
    featureValues = Object.values(features)

    maxTempo = _.maxBy(featureValues, 'tempo').tempo
    maxDurationMs = _.maxBy(featureValues, 'durationMs').durationMs
    maxTimeSignature = _.maxBy(featureValues, 'timeSignature').timeSignature
    maxKey = config.KEY_MAPPING.length - 1
    maxLoudness = config.TUNEABLE_ATTRIBUTES.loudness.min
    maxPopularity = config.TUNEABLE_ATTRIBUTES.popularity.max

    for trackId, track of features
        track.tempo /= maxTempo
        track.durationMs /= maxDurationMs
        track.timeSignature /= maxTimeSignature
        track.key /= maxKey
        track.popularity /= maxPopularity
        track.loudness = 1 - track.loudness / maxLoudness

    return features
