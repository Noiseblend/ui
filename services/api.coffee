import apisauce from "apisauce"
import axios from "axios"
import getConfig from "next/config"
import uuid4 from "uuid/v4"

import cacheAdapterEnhancer from "~/lib/cache"
import { fixColors } from "~/lib/img"
import redirect from "~/lib/redirect"
import Sentry from "~/lib/sentry"
import { getAuthTokenCookie, setAuthTokenCookie } from "~/lib/session"
import { any } from "~/lib/util"

import SpotifyActions from "~/redux/spotify"

{ serverRuntimeConfig, publicRuntimeConfig } = getConfig()

UUID_PATTERN = new RegExp(/[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}/, "i")

getAuthToken = (ctx) ->
    cookieToken = getAuthTokenCookie(ctx)
    if UUID_PATTERN.test(cookieToken)
        cookieToken
    else
        authToken = uuid4()
        setAuthTokenCookie(authToken, ctx)
        authToken

getHeaders = (ctx) ->
    headers = Authorization: "Bearer #{ getAuthToken(ctx) }"

    if ctx.blendToken?
        headers.BlendToken = "#{ ctx.blendToken }"


create = (ctx, baseURL) ->
    baseURL =
        if ctx.isServer
            publicRuntimeConfig.localApiURL
        else
            publicRuntimeConfig.remoteApiURL

    adapter =
        if not ctx.isServer
            null
        else
            cacheAdapterEnhancer(axios.defaults.adapter,
                enabledByDefault: true
                defaultCache: ctx.cache)

    api = apisauce.create({
        baseURL
        adapter
        timeout: 60000
    })
    api.addMonitor((response) ->
        request = response.originalError?.request
        if response.status in [403, 401] and request?.path isnt "/logout"
            redirect({target: "/?logout=true", res: ctx.res, isServer: ctx.isServer}))

    api.addRequestTransform((request) ->
        request.headers = {
            (request.headers ? {})...
            getHeaders()...
        }
    )

    api.addResponseTransform((response) ->
        if not response.status? or response.status >= 400
            console.error(response.originalError)
            responseContext =
                responseData: response.data
                responseStatus: response.status
                responseHeaders: response.headers
                axiosConfig: response.config
                responseDuration: response.duration

            Sentry.configureScope((scope) ->
                scope.setExtra(responseContext))

            eventId = Sentry.captureException(response.originalError ? response.problem)
            eventId = eventId?._lastEventId ? eventId
            response.sentryEventId = eventId

            request = response.originalError?.request
            if response.status isnt 404 and request?.path isnt "/blend"
                ctx.store?.dispatch(SpotifyActions.setErrorMessage(response)))

    oauthCode = () -> api.get("oauth-code")
    isAuthenticated = () -> api.get("is-authenticated")
    blendToken = (blend) -> api.get("blend-token", { blend })
    authorizationUrl = () -> api.get("authorization-url")
    authenticate = (code, state) ->
        api.get('authenticate', { code, state }).then((res) ->
            if res.ok and res.data?.authToken?
                setAuthTokenCookie(res.data.authToken, ctx)
                return res.data
            return null)

    logOut = () -> api.get("logout")

    getUserDetails = () ->
        api.get("me").then((res) ->
            if res.ok
                res.data.countryOriginalName = res.data.countryName
                if res.data.countryName?
                    res.data.countryName = res.data.countryName.split(",")[0]

                fixColors([res.data])
            return res)

    confirmEmail = (token) ->
        api.post("confirm-email", token: token)

    setUserDetails = (details) -> api.put("user-details", details)

    topArtists = (args) ->
        if args.ignore?.length
            args.ignore = args.ignore.join(",")

        api.get("artists", args)

    recommendations = (
        seeds
        tuneableAttributes
        limit = 100
        withTuneableAttributes = false
    ) ->
        api.post("recommendations", {
            seeds...
            tuneableAttributes
            limit
            withTuneableAttributes
        })

    devices = () -> api.get("devices")

    play = (device, items, volume, filterExplicit, fade) ->
        api.post("play", {
            items...
            device
            volume
            filterExplicit
            fade
            deviceId
        })

    blend = ({ blend, device, volume, filterExplicit, fade, deviceId, play }) ->
        api.post("blend", {
            blend
            device
            volume
            filterExplicit
            fade
            deviceId
            play
        })

    pause = (device) -> api.post("pause", { device })
    nextTrack = (device) -> api.post("next-track", { device })
    previousTrack = (device) -> api.post("previous-track", { device })

    artistDetails = (ids) -> api.get("artist-details", ids: ids.join(","))

    savePlaylist = (name, tracks, image, artists, filterExplicit) ->
        api.post("save-playlist", {
            name
            tracks
            image
            artists
            filterExplicit
        })

    replaceTracks = (playlistId, tracks, order) ->
        api.post("replace-tracks", {
            id: playlistId
            tracks
            order
        })

    renamePlaylist = (playlistId, name) ->
        api.post("rename-playlist", {
            id: playlistId
            name
        })

    reorderPlaylist = (playlistId, order) ->
        api.post("reorder-playlist", {
            id: playlistId
            order
        })

    fetchDislikes = (type) ->
        api.get('fetch-dislikes', {type}).then((res) ->
            countries = if type is 'all'
                res.data.countries ? []
            else if type is 'countries'
                res.data ? []
            else
                []
            for country in countries
                country.originalName = country.name
                country.name = country.name.split(",")[0]
            return res)

    clonePlaylist = (sourcePlaylistId, ownerId, name, order, image) ->
        api.post("clone-playlist", {
            id: sourcePlaylistId
            ownerId
            name
            order
            image
        })

    filterPlaylist = (
        sourcePlaylistId
        ownerId
        name
        order
        filterExplicit
        filterDislikes
        image
    ) ->
        api.post("filter-playlist", {
            id: sourcePlaylistId
            ownerId
            name
            order
            filterExplicit
            filterDislikes
            image
        })

    audioFeatures = (tracks, ownerId, playlistId) ->
        if tracks?
            tracks = tracks.join(",")
        api.get("audio-features", {
            tracks
            ownerId
            playlistId
        })

    topGenres = (args) ->
        if args.ignore?.length
            args.ignore = args.ignore.join(",")

        api.get("genres", args)

    countries = (args) ->
        if args.ignore?.length
            args.ignore = args.ignore.join(",")

        api.get("countries", args).then((res) ->
            if res.ok
                for country in res.data
                    country.originalName = country.name
                    country.name = country.name.split(",")[0]
                res.data = fixColors(res.data)
            return res)

    cities = (args) ->
        if args.ignore?.length
            args.ignore = args.ignore.join(",")

        api.get("cities", args).then((res) ->
            if res.ok
                if res.data?.countries?
                    for country in res.data.countries
                        country.originalName = country.name
                        country.name = country.name.split(",")[0]
                    res.data.cities = fixColors(res.data.cities)
                else
                    res.data = fixColors(res.data)
            return res)

    playlist = (
        user
        id
        limit = 100
        offset = 0
        onlyTracks = false
        withTuneableAttributes = false
    ) ->
        api.get("playlist", {
            user
            id
            limit
            offset
            onlyTracks
            withTuneableAttributes
        })

    dislike = ({ artist, genre, country, city }) ->
        api.post("dislike", { artist, genre, country, city })

    like = ({ artist, genre, country, city }) ->
        api.post("like", { artist, genre, country, city })

    fetchPlaylists = ({ genre, country, city, genres, countries }) ->
        if not any([genre, country, city, genres, countries])
            return null

        if genres?
            genres = genres.join(",")

        if countries?
            countries = countries.join(",")

        api.get("playlists", { genre, country, city, genres, countries })

    fade = (stopVolume, startVolume, direction, timeMinutes, device) ->
        api.post("fade", { stopVolume, startVolume, direction, timeMinutes, device })

    search = (query, type, limit, imageWidth = null, imageHeight = null) ->
        api.post('search', {
            query
            type
            limit
            imageWidth
            imageHeight
        }).then((res) ->
            if res.ok
                for item in res.data
                    item.fromSearch = true
                    item.selected = false
            res)

    clientToken = () -> api.get("client-token")

    return {
        artistDetails
        authenticate
        authorizationUrl
        cities
        clonePlaylist
        countries
        devices
        dislike
        getUserDetails
        isAuthenticated
        like
        logOut
        play
        playlist
        recommendations
        renamePlaylist
        reorderPlaylist
        replaceTracks
        savePlaylist
        setUserDetails
        topArtists
        topGenres
        fetchPlaylists
        fade
        search
        audioFeatures
        fetchDislikes
        confirmEmail
        filterPlaylist
        pause
        nextTrack
        previousTrack
        clientToken
        blend
        blendToken
        oauthCode
        setHeader: api.setHeader
    }

export default { create }
