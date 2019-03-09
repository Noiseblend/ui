import { all, call, put, select, take } from 'redux-saga/effects'

import SpotifyActions from '~/redux/spotify'

export getUserDetails = (api) ->
    res = yield call(api.getUserDetails)
    unless res.ok
        return

    yield put(SpotifyActions.setUser(res.data))

export setUserDetails = (api, { details }) ->
    res = yield call(api.setUserDetails, details)
    unless res.ok
        return

    yield put(SpotifyActions.setUser(res.data))
