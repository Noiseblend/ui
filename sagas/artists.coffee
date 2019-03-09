import { all, call, put, select, take } from 'redux-saga/effects'

import _ from 'lodash'

import redirect from '~/lib/redirect'

import ArtistActions from '~/redux/artists'
import SpotifyActions from '~/redux/spotify'



export fetchArtists = (api, { params..., replace }) ->
    delete params.type
    actions = []

    allArtists = yield select((state) -> state.artists.present.allArtists)
    timeRangeKey = _.camelCase(params.timeRange)
    if allArtists?[timeRangeKey]?
        artists = allArtists[timeRangeKey][...(params.limit)]
        actions.push(ArtistActions.setAllArtists({
            allArtists...
            "#{ timeRangeKey }": allArtists[timeRangeKey][(params.limit)..]
        }))
    else
        res = yield call(api.topArtists, params)
        unless res.ok
            yield put([
                ArtistActions.finishFetchingArtists()
            ])
            yield return
        artists = res.data

    if artists.length > 0
        if replace is 'loading'
            actions.push(ArtistActions.replaceLoadingArtists(artists))
        else if replace is 'all'
            actions.push(ArtistActions.setArtists(artists, saveHistory = false))
        else
            actions.push(
                ArtistActions.replaceUnselectedArtists(
                    artists, saveHistory = true
                )
            )
    else
        actions.push(
            ArtistActions.setNoMoreArtists(true)
        )

    yield put([
        actions...
        ArtistActions.clearLoadingArtists()
        ArtistActions.finishFetchingArtists()
    ])
    return

export dislikeArtist = (api, { artist }) ->
    if Array.isArray(artist)
        responses = yield all(
            call(api.dislike, { artist: a.id }) for a in artist
        )
        res = responses[0]
    else
        res = yield call(api.dislike, { artist: artist.id })

    unless res.ok
        yield return

    return

export likeArtist = (api, { artist }) ->
    if Array.isArray(artist)
        responses = yield all(
            call(api.like, { artist: a.id }) for a in artist
        )
        res = responses[0]
    else
        res = yield call(api.like, { artist: artist.id })

    unless res.ok
        yield return

    return

export setArtistTimeRange = (api, { timeRange, skipUpdate }) ->
    if skipUpdate
        yield return

    artistTimeRange = yield select((state) -> state.spotify.user?.artistTimeRange)
    if artistTimeRange is timeRange
        yield return

    res = yield call(api.setUserDetails, { artistTimeRange: timeRange })
    unless res.ok
        yield return

    yield put(SpotifyActions.setUser(res.data))
    return

export searchArtists = (api, { query, limit, imageWidth, imageHeight }) ->
    if query?.length
        res = yield call(api.search, query, 'artist', limit, imageWidth, imageHeight)
        unless res.ok
            yield return

        backedUpBeforeSearch = yield select(
            (state) -> state.artists.present.backedUpBeforeSearch
        )
        if not backedUpBeforeSearch
            yield put([
                ArtistActions.backupArtists(),
                ArtistActions.resetPrevItems(),
                ArtistActions.resetNextItems(),
                ArtistActions.setBackedUpBeforeSearch(true)
            ])

        yield put([
            ArtistActions.replaceUnselectedArtists(res.data, saveHistory = false),
            ArtistActions.finishSearchingArtists()
        ])
    else
        backedUpBeforeSearch = yield select(
            (state) -> state.artists.present.backedUpBeforeSearch
        )
        if backedUpBeforeSearch
            yield put([
                ArtistActions.restoreArtists(),
                ArtistActions.setBackedUpBeforeSearch(false)
                ArtistActions.finishSearchingArtists()
            ])
        else
            yield put(ArtistActions.finishSearchingArtists())
    return
