import { all, call, put, select, take } from 'redux-saga/effects'

import _ from 'lodash'

import GenreActions from '~/redux/genres'
import SpotifyActions from '~/redux/spotify'



export fetchGenres = (api, { params..., replace }) ->
    delete params.type
    actions = []

    allGenres = yield select((state) -> state.genres.present.allGenres)
    timeRangeKey = _.camelCase(params.timeRange)
    if allGenres?[timeRangeKey]?
        genres = allGenres[timeRangeKey][...(params.limit)]
        actions.push(GenreActions.setAllGenres({
            allGenres...
            "#{ timeRangeKey }": allGenres[timeRangeKey][(params.limit)..]
        }))
    else
        res = yield call(api.topGenres, params)
        unless res.ok
            yield put([
                GenreActions.finishFetchingGenres()
            ])
            yield return
        genres = res.data

    if genres.length > 0
        if replace is 'loading'
            actions.push(GenreActions.replaceLoadingGenres(genres))
        else if replace is 'all'
            actions.push(GenreActions.setGenres(genres, saveHistory = false))
        else
            actions.push(GenreActions.setGenres(genres))
    else
        actions.push(GenreActions.setNoMoreGenres(true))

    yield put([
        actions...
        GenreActions.clearLoadingGenres()
        GenreActions.finishFetchingGenres()
    ])
    return

export fetchGenrePlaylists = (api, { genre }) ->
    unless typeof genre is 'string'
        res = yield call(api.fetchPlaylists, { genres: genre })
    else
        res = yield call(api.fetchPlaylists, { genre })
    if not res?
        return

    unless res.ok
        yield put([
            GenreActions.finishFetchingPlaylists()
        ])
        yield return

    if res.data.length > 0
        actions = unless typeof genre is 'string'
            [
                GenreActions.addPlaylists(
                    g, res.data.filter((fp) -> fp.genre is g)
                ) for g in genre
            ]
        else
            [GenreActions.addPlaylists(genre, res.data)]

        yield put([
            actions...
            GenreActions.finishFetchingPlaylists()
        ])
    else
        yield put(GenreActions.finishFetchingPlaylists())
    return

export dislikeGenre = (api, { genre }) ->
    res = yield call(api.dislike, { genre: genre.name })
    unless res.ok
        yield return

    return

export likeGenre = (api, { genre }) ->
    res = yield call(api.like, { genre: genre.name })
    unless res.ok
        yield return

    return

export setGenreTimeRange = (api, { timeRange, skipUpdate }) ->
    if skipUpdate
        yield return

    genreTimeRange = yield select((state) -> state.spotify.user?.genreTimeRange)
    if genreTimeRange is timeRange
        yield return

    res = yield call(api.setUserDetails, { genreTimeRange: timeRange })
    unless res.ok
        yield return

    yield put(SpotifyActions.setUser(res.data))
    return
