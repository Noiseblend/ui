import { all, call, put, select, take } from 'redux-saga/effects'

import { setAuthTokenCookie } from '~/lib/session'

import AuthActions from '~/redux/auth'
import CacheActions from '~/redux/cache'
import SpotifyActions from '~/redux/spotify'

import config from '~/config'


export watchAuthToken = ({ authToken }) ->
    yield call(setAuthTokenCookie, authToken)
    # yield put(CacheActions.cache(config.CACHE.keys.AUTH_TOKEN, authToken))

    return

export startAuthentication = (api) ->
    res = yield call(api.authorizationUrl)
    unless res.ok
        return

    { authorizationUrl } = res.data
    window.location.replace(authorizationUrl)

    return
