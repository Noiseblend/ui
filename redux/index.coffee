import "@babel/polyfill"

import { combineReducers } from "redux"
import undoable, { includeAction } from "redux-undo"

import getRootSaga from "~/sagas"

import { ArtistTypes, reducer as artistsReducer } from "./artists"
import { CityTypes, reducer as citiesReducer } from "./cities"
import { CountryTypes, reducer as countriesReducer } from "./countries"
import { GenreTypes, reducer as genresReducer } from "./genres"
import { PlaylistTypes, reducer as playlistsReducer } from "./playlists"
import { RecommendationTypes, reducer as recommendationsReducer } from "./recommendations"
import configureStore from "./store"

createStore = (initialState = {}, ctx) ->
    rootReducer = combineReducers(
        cache: require('./cache').reducer
        ui: require('./ui').reducer
        recommendations: undoable(
            recommendationsReducer,
            {
                limit: 100,
                filter: includeAction(RecommendationTypes.SET_TUNEABLE_ATTRIBUTE),
                syncFilter: true
            }
        )
        artists: undoable(
            artistsReducer,
            {
                limit: 10,
                filter: includeAction(ArtistTypes.DISLIKE_ARTIST),
                syncFilter: true
            }
        )
        genres: undoable(
            genresReducer,
            {
                limit: 10,
                filter: includeAction(GenreTypes.DISLIKE_GENRE),
                syncFilter: true
            }
        )
        countries: undoable(
            countriesReducer,
            {
                limit: 10,
                filter: includeAction(CountryTypes.DISLIKE_COUNTRY),
                syncFilter: true
            }
        )
        cities: undoable(
            citiesReducer,
            {
                limit: 10,
                filter: includeAction(CityTypes.DISLIKE_CITY),
                syncFilter: true
            }
        )
        playlists: undoable(
            playlistsReducer,
            {
                limit: 10,
                filter: includeAction(PlaylistTypes.DISLIKE_ARTIST),
                syncFilter: true
            }
        )
        auth: require('./auth').reducer
        spotify: require('./spotify').reducer
        player: require('./player').reducer
        user: require('./user').reducer
    )

    configureStore(rootReducer, getRootSaga, initialState, ctx)

export default createStore
