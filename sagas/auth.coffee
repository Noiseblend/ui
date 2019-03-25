import { all, call, put, select, take } from 'redux-saga/effects'

import { setAuthTokenCookie } from '~/lib/session'

import CacheActions from '~/redux/cache'
import SpotifyActions from '~/redux/spotify'

import config from '~/config'


export startAuthentication = (api) ->
    res = yield call(api.authorizationUrl)
    unless res.ok
        return

    { authorizationUrl } = res.data
    window.location.replace(authorizationUrl)

    return
