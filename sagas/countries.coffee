import { all, call, put, select, take } from 'redux-saga/effects'

import CountryActions from '~/redux/countries'
import SpotifyActions from '~/redux/spotify'



export fetchCountries = (api, { params..., replace }) ->
    delete params.type
    actions = []

    allCountries = yield select((state) -> state.countries.present.allCountries)
    if allCountries?.length
        countries = allCountries[...(params.limit)]
        actions.push(CountryActions.setAllCountries(allCountries[(params.limit)..]))
    else
        res = yield call(api.countries, params)
        unless res.ok
            yield put([
                CountryActions.finishFetchingCountries()
            ])
            yield return
        countries = res.data

    if countries.length > 0
        if replace is 'loading'
            actions.push(CountryActions.replaceLoadingCountries(countries))
        else
            actions.push(CountryActions.setCountries(countries))
    else
        actions.push(CountryActions.setNoMoreCountries(true))

    yield put([
        actions...
        CountryActions.clearLoadingCountries()
        CountryActions.finishFetchingCountries()
    ])
    return

export fetchCountryPlaylists = (api, { country }) ->
    unless typeof country is 'string'
        res = yield call(api.fetchPlaylists, { countries: country })
    else
        res = yield call(api.fetchPlaylists, { country })
    if not res?
        return

    unless res.ok
        yield put([
            CountryActions.finishFetchingPlaylists()
        ])
        yield return

    if res.data.length > 0
        actions = unless typeof country is 'string'
            [
                CountryActions.addPlaylists(
                    c, res.data.filter((fp) -> fp.country is c)
                ) for c in country
            ]
        else
            [CountryActions.addPlaylists(country, res.data)]

        yield put([
            actions...
            CountryActions.finishFetchingPlaylists()
        ])

    return

export dislikeCountry = (api, { country }) ->
    res = yield call(api.dislike, { country: country.code })
    unless res.ok
        yield return

    return

export likeCountry = (api, { country }) ->
    res = yield call(api.like, { country: country.name })
    unless res.ok
        yield return

    return
