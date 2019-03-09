import { all, call, put, select, take } from 'redux-saga/effects'

import CityActions from '~/redux/cities'
import SpotifyActions from '~/redux/spotify'



export fetchCities = (api, { params..., country, replace }) ->
    delete params.type
    actions = []

    allCities = yield select((state) -> state.cities.present.allCities)
    if allCities?[country]?
        cities = allCities[country][...(params.limit)]
        actions.push(CityActions.setAllCities({
            allCities...
            "#{ country }": allCities[country][(params.limit)..]
        }))
    else
        { imageWidth, imageHeight } = params
        res = yield call(api.cities, { country, imageWidth, imageHeight, all: true })
        unless res.ok
            yield put([
                CityActions.finishFetchingCities()
            ])
            yield return

        actions.push(CityActions.setAllCities({
            allCities...
            "#{ country }": res.data[(params.limit)..]
        }))
        cities = res.data[...(params.limit)]

    if cities.length > 0
        if replace is 'loading'
            actions.push(CityActions.replaceLoadingCities(cities))
        else
            actions.push(CityActions.setCities(cities))
    else
        actions.push(CityActions.setNoMoreCities(true))

    yield put([
        actions...
        CityActions.finishFetchingCities()
        CityActions.clearLoadingCities()
    ])
    return

export dislikeCity = (api, { city }) ->
    res = yield call(api.dislike, { city: city.name })
    unless res.ok
        yield return

    return

export likeCity = (api, { city }) ->
    res = yield call(api.like, { city: city.name })
    unless res.ok
        yield return

    return

export setCountry = (api, { country, skipUpdate }) ->
    if skipUpdate
        yield return

    preferredCountry = yield select((state) -> state.spotify.user?.preferredCountry)
    if preferredCountry is country.code
        yield return

    res = yield call(api.setUserDetails, { preferredCountry: country.code })
    unless res.ok
        yield return

    yield put(SpotifyActions.setUser(res.data))
    return
