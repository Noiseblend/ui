import { all, takeEvery, takeLatest } from 'redux-saga/effects'

import { ArtistTypes } from '~/redux/artists'
import { AuthTypes } from '~/redux/auth'
import { CacheTypes } from '~/redux/cache'
import { CityTypes } from '~/redux/cities'
import { CountryTypes } from '~/redux/countries'
import { GenreTypes } from '~/redux/genres'
import { PlayerTypes } from '~/redux/player'
import { PlaylistTypes } from '~/redux/playlists'
import { RecommendationTypes } from '~/redux/recommendations'
import SpotifyActions, { SpotifyTypes } from '~/redux/spotify'
import { StartupTypes } from '~/redux/startup'
import { UserTypes } from '~/redux/user'

import API from '~/services/api'

import {
    dislikeArtist,
    fetchArtists,
    likeArtist,
    searchArtists,
    setArtistTimeRange
} from './artists'
import { startAuthentication, alexaAuthentication } from './auth'
import { cache } from './cache'
import {
    dislikeCity,
    fetchCities,
    likeCity,
    setCountry
} from './cities'
import {
    dislikeCountry,
    fetchCountries,
    fetchCountryPlaylists,
    likeCountry
} from './countries'
import {
    dislikeGenre,
    fetchGenrePlaylists,
    fetchGenres,
    likeGenre,
    setGenreTimeRange
} from './genres'
import {
    fade,
    fetchDevices,
    nextTrack,
    openDevicesWatcherWebsocket,
    openPlaybackControllerWebsocket,
    pause,
    play,
    playBlend,
    previousTrack
} from './player'
import {
    clonePlaylist,
    fetchAudioFeatures,
    fetchPlaylist,
    fetchTracks,
    filterPlaylist,
    renamePlaylist,
    reorderPlaylist,
    replaceTracks,
    savePlaylist
} from './playlists'
import { applyTuning, openPlaylistTunerWebsocket } from './recommendations'
import { getUserDetails, setUserDetails } from './spotify'
import startup from './startup'
import {
    fetchDislikes,
    removeDislike
} from './user'


export default getRootSaga = (ctx) ->
    api = API.create(ctx)
    return () ->
        yield all([
            takeLatest(ArtistTypes.DISLIKE_ARTIST, dislikeArtist, api)
            takeLatest(ArtistTypes.FETCH_ARTISTS, fetchArtists, api)
            takeLatest(ArtistTypes.LIKE_ARTIST, likeArtist, api)
            takeLatest(ArtistTypes.SET_TIME_RANGE, setArtistTimeRange, api)
            takeLatest(ArtistTypes.SEARCH_ARTISTS, searchArtists, api)
            takeLatest(AuthTypes.START_AUTHENTICATION, startAuthentication, api)
            takeLatest(AuthTypes.ALEXA_AUTHENTICATION, alexaAuthentication, api)
            takeEvery(CacheTypes.CACHE, cache)
            takeLatest(CityTypes.DISLIKE_CITY, dislikeCity, api)
            takeLatest(CityTypes.FETCH_CITIES, fetchCities, api)
            takeLatest(CityTypes.LIKE_CITY, likeCity, api)
            takeLatest(CityTypes.SET_COUNTRY, setCountry, api)
            takeLatest(CountryTypes.DISLIKE_COUNTRY, dislikeCountry, api)
            takeLatest(CountryTypes.FETCH_COUNTRIES, fetchCountries, api)
            takeLatest(CountryTypes.FETCH_PLAYLISTS, fetchCountryPlaylists, api)
            takeLatest(CountryTypes.LIKE_COUNTRY, likeCountry, api)
            takeLatest(GenreTypes.DISLIKE_GENRE, dislikeGenre, api)
            takeLatest(GenreTypes.FETCH_GENRES, fetchGenres, api)
            takeLatest(GenreTypes.FETCH_PLAYLISTS, fetchGenrePlaylists, api)
            takeLatest(GenreTypes.LIKE_GENRE, likeGenre, api)
            takeLatest(GenreTypes.SET_TIME_RANGE, setGenreTimeRange, api)
            takeLatest(PlaylistTypes.CLONE_PLAYLIST, clonePlaylist, api)
            takeLatest(PlaylistTypes.FETCH_PLAYLIST, fetchPlaylist, api)
            takeLatest(PlaylistTypes.FETCH_TRACKS, fetchTracks, api)
            takeLatest(PlaylistTypes.FETCH_AUDIO_FEATURES, fetchAudioFeatures, api)
            takeLatest(PlaylistTypes.RENAME_PLAYLIST, renamePlaylist, api)
            takeLatest(PlaylistTypes.FILTER_PLAYLIST, filterPlaylist, api)
            takeLatest(PlaylistTypes.REORDER_PLAYLIST, reorderPlaylist, api)
            takeLatest(PlaylistTypes.REPLACE_TRACKS, replaceTracks, api)
            takeLatest(PlaylistTypes.SAVE_PLAYLIST, savePlaylist, api)
            takeLatest(PlaylistTypes.DISLIKE_ARTIST, dislikeArtist, api)
            takeLatest(SpotifyTypes.GET_USER_DETAILS, getUserDetails, api)
            takeLatest(SpotifyTypes.SET_USER_DETAILS, setUserDetails, api)
            takeLatest(StartupTypes.STARTUP, startup, api)
            takeLatest(
                PlayerTypes.OPEN_DEVICES_WATCHER_WEBSOCKET,
                openDevicesWatcherWebsocket
            )
            takeLatest(
                PlayerTypes.OPEN_PLAYBACK_CONTROLLER_WEBSOCKET,
                openPlaybackControllerWebsocket
            )
            takeLatest(PlayerTypes.FETCH_DEVICES, fetchDevices, api)
            # takeLatest(PlayerTypes.PLAY, play, api)
            # takeLatest(PlayerTypes.PAUSE, pause, api)
            # takeLatest(PlayerTypes.NEXT_TRACK, nextTrack, api)
            # takeLatest(PlayerTypes.PREVIOUS_TRACK, previousTrack, api)
            takeLatest(PlayerTypes.FADE, fade, api)
            takeLatest(PlayerTypes.PLAY_BLEND, playBlend, api)
            takeLatest(RecommendationTypes.APPLY_TUNING, applyTuning, api)
            takeLatest(
                RecommendationTypes.OPEN_PLAYLIST_TUNER_WEBSOCKET,
                openPlaylistTunerWebsocket
            )
            takeLatest(UserTypes.FETCH_DISLIKES, fetchDislikes, api)
            takeLatest(UserTypes.REMOVE_DISLIKE, removeDislike, api)
        ])
