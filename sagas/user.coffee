import { all, call, put, select, take } from 'redux-saga/effects'

import SpotifyActions from '~/redux/spotify'
import UserActions from '~/redux/user'


SINGULAR =
    artists: 'artist'
    genres: 'genre'
    cities: 'city'
    countries: 'country'


export fetchDislikes = (api, { key }) ->
    res = yield call(api.fetchDislikes, key)
    unless res.ok
        yield put([
            UserActions.finishFetchingDislikes()
        ])
        yield return

    yield put([
        UserActions.setDislikes(key, res.data),
        UserActions.finishFetchingDislikes()
    ])
    return

export removeDislike = (api, { key, item }) ->
    idKey = switch key
        when 'artists' then 'id'
        when 'countries' then 'code'
        else 'name'

    if Array.isArray(item)
        responses = yield all(
            call(
                api.like, { "#{SINGULAR[key] }": it[idKey] }
            ) for it in item
        )
        res = responses[0]
    else
        res = yield call(api.like, { "#{SINGULAR[key] }": item[idKey] })

    unless res.ok
        yield return

    return
