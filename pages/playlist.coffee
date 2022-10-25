import '~/lib/sets'
import React from 'react'
import { connect } from 'react-redux'

import anime from 'animejs'
import _ from 'lodash'

import LoadingIndicator from '~/components/loadingIndicator'
import Controls from '~/components/playlist/controls'
import Sidebar from '~/components/playlist/sidebar'
import PlaylistView from '~/components/playlist/view'

import { getMoment } from '~/lib/time'
import { anyObj } from '~/lib/util'

import PlayerActions from '~/redux/player'
import PlaylistActions from '~/redux/playlists'
import RecommendationActions from '~/redux/recommendations'
import SpotifyActions from '~/redux/spotify'
import UIActions from '~/redux/ui'
import UserActions from '~/redux/user'

import colors from '~/styles/colors'

import config from '~/config'


class Playlist extends React.Component
    constructor: (props) ->
        super props
        @trackArtistSets = {}
        @state =
            deviceFetcher: null
            clicked: null

    @getInitialProps: ({ store, query, res, req, isServer, authenticated, user, api }) ->
        playlist = store.getState().playlists.present.playlist

        image = if query.image?.length > 0
            if isServer
                Buffer.from(query.image, 'base64').toString('ascii')
            else
                atob(query.image)
        else
            null

        if query.artists?
            artistIds = query.artists.split(',')
            if playlist?.artistIds?.length
                artistSet = new Set(playlist.artistIds)
                wantedArtistSet = new Set(artistIds)
                if artistSet.equals(wantedArtistSet)
                    return

            dislikeRequest = api.fetchDislikes('artists')
            recommendationsRequest = api.recommendations({ seedArtists: artistIds })
            artistsRequest = api.artistDetails(artistIds)

            [dislikeRes, recommendationsRes, artistsRes] = await Promise.all([
                dislikeRequest
                recommendationsRequest
                artistsRequest
            ])

            if not recommendationsRes.ok
                await return { error: recommendationsRes }

            if not artistsRes.ok
                await return { error: artistsRes }
            artistNames = (a.name for a in artistsRes.data ? [])
            if artistNames.length > 1
                name = "
                    #{ artistNames[..-2].join(', ') } &
                    #{ artistNames[artistNames.length - 1] }"
            else
                name = artistNames[0]

            playlist =
                artistIds: artistIds
                artistNames: artistNames
                image: image
                discover: true
                name: "Blend: #{ name }"
                tracks:
                    items: (track: t for t in recommendationsRes.data)
                    total: recommendationsRes.data.length
        else
            owner = query.user
            playlistId = query.id
            if playlist?.owner?.id is owner and playlist?.id is playlistId
                return

            dislikeRequest = api.fetchDislikes('artists')
            playlistRequest = api.playlist(owner, playlistId)
            [dislikeRes, playlistRes] = await Promise.all([
                dislikeRequest
                playlistRequest
            ])

            if not playlistRes.ok
                await return { error: playlistRes }
            playlist = playlistRes.data
            playlist = {
                playlist...
                image
                discover: false
            }

        if not dislikeRes.ok
            await return { error: dislikeRes }
        dislikedArtists = dislikeRes.data


        await return {
            fetched:
                playlist: playlist
                dislikedArtists: dislikedArtists
        }

    componentDidMount: ->
        @startDeviceFetcher(config.POLLING.DEVICE_FETCHER_SLOW)
        if not @props.fetched?.playlist?
            return

        actions = [
            PlaylistActions.setPlaylist(@props.fetched.playlist)
            UserActions.setDislikes('artists', @props.fetched.dislikedArtists)
        ]

        if not @props.mobile
            @props.showSidebarIn200ms()

        if @props.fetched.user.firstPlaylist
            actions = [
                actions...
                SpotifyActions.setUserDetails({ firstPlaylist: false })
            ]
            @props.showSidebarIn2Seconds()
        else if @props.fetched.user.secondPlaylist
            actions = [
                actions...
                SpotifyActions.setUserDetails({ secondPlaylist: false })
            ]

        @props.batchActions(actions)
        if @props.fetched.playlist?.owner?.id?
            @props.fetchAudioFeatures(
                null,
                @props.fetched.playlist.owner.id,
                @props.fetched.playlist.id)
        else if @props.fetched.playlist.tracks.items.length > 0
            @props.fetchAudioFeatures(
                (t.track.id for t in @props.fetched.playlist.tracks.items)
            )

    componentWillUnmount: ->
        @stopDeviceFetcher()

    componentDidUpdate: (prevProps, prevState, snapshot) ->
        if @props.playlist?.discover
            if prevProps.sidebarHidden and not @props.sidebarHidden
                @props.openPlaylistTunerWebsocket()
            if not prevProps.sidebarHidden and @props.sidebarHidden
                @props.closePlaylistTunerWebsocket()

    openDevicesDrawer: ->
        @props.openPlaybackControllerWebsocket()
        anime(
            targets: ['#playlist-controls']
            translateY: '-100vh'
            duration: 600
            elasticity: 100
            complete: =>
                @props.setUIState(isDrawerOpen: true)
                @startDeviceFetcher(config.POLLING.DEVICE_FETCHER_FAST)
        )

    closeDevicesDrawer: ->
        @props.closePlaybackControllerWebsocket()
        anime(
            targets: '#playlist-controls'
            translateY: 0
            duration: 600
            elasticity: 100
            complete: =>
                @props.setUIState(isDrawerOpen: false)
                @startDeviceFetcher(config.POLLING.DEVICE_FETCHER_SLOW)
        )

    stopDeviceFetcher: ->
        @props.closeDevicesWatcherWebsocket()

    startDeviceFetcher: (polling) ->
        polling /= 1000
        if not @props.devicesWatcherWebsocketOpen
            @props.openDevicesWatcherWebsocket(polling)
        else
            @props.changeDevicesWatcherPolling(polling)

    playlistView: () ->
        if @props.playlist?
            padding = if not @props.mediumScreen then 20 else 0
            <PlaylistView
                image={ @props.playlist.image }
                fetchTracks={ (page) => @fetchTracks(page) }
                style={
                    width: '100%'
                    marginTop: '2rem'
                    paddingLeft: padding
                    paddingRight: padding
                }
                artists={ @props.playlist.artistIds }
                onSavePlaylist={ () => @savePlaylist() }
                className='playlist-view'
            />
        else
            <div className='w-100vw h-100vh d-flex justify-content-center align-items-center'>
                <LoadingIndicator className='w-100vw' />
            </div>

    fetchTracks: (page) ->
        maxPage = Math.floor((@props.playlist?.tracks?.total ? 0) / 100)
        if (
            @props.playlist?.owner?.id? and
            @props.playlist?.id? and
            page > 0 and page <= maxPage
        )
            limit = 100
            offset = page * limit
            @props.fetchTracks(@props.playlist.owner.id, @props.playlist.id, limit, offset)

    trackHasDislikedArtists: (track) ->
        if track.artists.length is 1
            return @props.dislikedArtistsSet.has(track.artists[0].id)

        unless @trackArtistSets[track.id]?
            @trackArtistSets[track.id] = new Set(a.id for a in track.artists)

        return @trackArtistSets[track.id].intersects(@props.dislikedArtistsSet)

    filteredTracks: ->
        tracks = []
        if @props.playlist?.tracks?
            for t in @props.playlist.tracks.items
                track = t.track
                track = {
                    track...
                    disliked: @trackHasDislikedArtists(track)
                }
                if @props.filterDislikes and track.disliked
                    continue
                if @props.tuneableAttributes?.key? and track.audioFeatures?.key? and @props.tuneableAttributes?.key isnt track.audioFeatures?.key
                    continue
                if @props.tuneableAttributes?.mode? and track.audioFeatures?.mode? and @props.tuneableAttributes?.mode isnt track.audioFeatures?.mode
                    continue

                tracks.push(track)

        return tracks

    savePlaylist: () ->
        playlist = @props.playlist
        hasOrder = Object.keys(@props.order ? {}).length
        if @props.modified.order and hasOrder and playlist.id
            @props.reorderPlaylist(playlist.id, @props.order)
        else if not playlist.owner?.id?
            tracks = (t.id for t in @filteredTracks())
            @props.savePlaylist(
                playlist.name
                tracks
                @props.playlist.image
                @props.playlist.artistNames
                @props.filterExplicit
            )
        else if @props.modified.explicit or @props.modified.dislikes
            @props.filterPlaylist(
                playlist.id
                playlist.owner.id
                playlist.name
                @props.order
                @props.filterExplicit
                @props.filterDislikes
                @props.playlist.image
            )
        else if playlist.owner.id isnt @props.user.username
            @props.clonePlaylist(
                playlist.id
                playlist.owner.id
                playlist.name
                @props.order
                @props.playlist.image
            )
        else if @props.modified.tracks or
        (@props.modified.order and not hasOrder and playlist.id)
            tracks = (t.id for t in @filteredTracks())
            @props.replaceTracks(playlist.id, tracks, @props.order)
        else if @props.modified.name
            @props.renamePlaylist(playlist.id, playlist.name)
        return

    getFadeParams: ->
        if @props.fadeDirection is 1
            start = Math.min(@props.startVolume, @props.stopVolume)
            stop = Math.max(@props.startVolume, @props.stopVolume)
        else
            start = Math.max(@props.startVolume, @props.stopVolume)
            stop = Math.min(@props.startVolume, @props.stopVolume)

        volume = if not @props.fadeEnabled
            null
        else
            if @props.fadeDirection is 1
                start
            else
                stop

        fadeParams = if not @props.fadeEnabled
            null
        else
            {
                limit: stop
                start: start
                step: @props.fadeDirection * 3
                seconds: @props.fadeTimeMinutes * 60
            }
        return { volume, fadeParams }

    playOn: (device) ->
        if device?.id isnt 0
            user = @props.user
            if not @props.playlist?.uri? or anyObj(@props.modified)
                items =
                    tracks: (track.id for track in @filteredTracks())
            else
                items =
                    playlist: @props.playlist?.uri

            { volume, fadeParams } = @getFadeParams()

            actions = [
                PlayerActions.play(
                    device?.id
                    items
                    volume
                    @props.filterExplicit
                    fadeParams
                )
            ]
            if user.firstPlay
                actions = [
                    actions...
                    SpotifyActions.setUserDetails({ firstPlay: false })
                ]
                @props.focusHomeIn2Seconds(true)
                @props.defocusHomeIn8Seconds()
                @props.showHomeTooltipInHalfSecond()
                @props.hideHomeTooltipIn8Seconds()
            @props.batchActions(actions)

    render: ->
        <div className='fill-window'>
            <div
                className='
                    d-flex flex-column
                    justify-content-start
                    align-items-start
                    list-container'
                id='list-container'
                style={
                    height: '80%'
                    width: '100vw'
                    height: '100vh'
                }>
                { @playlistView() }
            </div>
            { if @props.playlist?
                <>
                    <Sidebar
                        key={ 1 }
                        id='sidebar'
                        width={ config.SIDEBAR_WIDTH }
                        artists={ @props.playlist.artistIds }
                        playlist={ @props.playlist } />
                    { if @props.user?.spotifyPremium
                        <Controls
                            key={ 2 }
                            style={
                                position: 'fixed'
                                bottom: '-120vh'
                                left: 0
                            }
                            id='playlist-controls'
                            playButtonId='play-button'
                            onPlayButtonClick={ () => @openDevicesDrawer() }
                            playOn={ (device) => @playOn(device) }
                            closeDrawer={ () => @closeDevicesDrawer() } />
                    }
                </>
            }
            <style global jsx>{"""#{} // stylus
                body
                    overflow-x hidden !important
            """}</style>
        </div>

mapStateToProps = (state) ->
    tuneableAttributes: state.recommendations.present.tuneableAttributes
    playlist                   : state.playlists.present.playlist
    loading                    : state.playlists.present.loading
    modified                   : state.playlists.present.modified
    order                      : state.playlists.present.order
    filterExplicit             : state.playlists.present.filterExplicit
    filterDislikes             : state.playlists.present.filterDislikes
    sidebarHidden              : state.playlists.present.sidebarHidden
    user                       : state.spotify.user
    mobile                     : state.ui.mobile
    mediumScreen               : state.ui.mediumScreen
    devices                    : state.player.devices
    startVolume                : state.player.startVolume
    stopVolume                 : state.player.stopVolume
    fadeDirection              : state.player.fadeDirection
    fadeTimeMinutes            : state.player.fadeTimeMinutes
    fadeEnabled                : state.player.fadeEnabled
    devicesWatcherWebsocketOpen: state.player.devicesWatcherWebsocketOpen
    focusHome                  : state.ui.focusHome
    dislikedArtistsSet         : new Set(a.id for a in (state?.user?.dislikedArtists ? []))

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    getUserDetails: () ->
        dispatch(SpotifyActions.getUserDetails())
    savePlaylist: (name, tracks, image, artists, filterExplicit) ->
        dispatch(PlaylistActions.savePlaylist(name, tracks, image, artists, filterExplicit))
    filterPlaylist: (id, ownerId, name, order, filterExplicit, filterDislikes, image) ->
        dispatch(
            PlaylistActions.filterPlaylist(
                id, ownerId, name, order, filterExplicit, filterDislikes, image
            )
        )
    clonePlaylist: (id, ownerId, name, order, image) ->
        dispatch(PlaylistActions.clonePlaylist(id, ownerId, name, order, image))
    setPlaylist: (playlist) ->
        dispatch(PlaylistActions.setPlaylist(playlist))
    fetchTracks: (user, playlistId, limit, offset) ->
        dispatch(PlaylistActions.fetchTracks(user, playlistId, limit, offset))
    fetchAudioFeatures: (tracks, ownerId, playlistId) ->
        dispatch(PlaylistActions.fetchAudioFeatures(tracks, ownerId, playlistId))
    replaceTracks: (playlistId, tracks, order) ->
        dispatch(PlaylistActions.replaceTracks(playlistId, tracks, order))
    renamePlaylist: (playlistId, name) ->
        dispatch(PlaylistActions.renamePlaylist(playlistId, name))
    reorderPlaylist: (playlistId, order) ->
        dispatch(PlaylistActions.reorderPlaylist(playlistId, order))
    fetchDevices: () ->
        dispatch(PlayerActions.fetchDevices())
    play: (device, items, volume, filterExplicit, fade) ->
        dispatch(PlayerActions.play(device, items, volume, filterExplicit, fade))
    setFadeTimeMinutes: (fadeTimeMinutes) ->
        dispatch(PlayerActions.setFadeTimeMinutes(fadeTimeMinutes))
    setFadeDirection: (fadeDirection) ->
        dispatch(PlayerActions.setFadeDirection(fadeDirection))
    setStartVolume: (startVolume) ->
        dispatch(PlayerActions.setStartVolume(startVolume))
    setStopVolume: (stopVolume) ->
        dispatch(PlayerActions.setStopVolume(stopVolume))
    setRecommended: (recommended) ->
        dispatch(PlaylistActions.setRecommended(recommended))
    setFilterExplicit: (filterExplicit) ->
        dispatch(PlaylistActions.setFilterExplicit(filterExplicit))
    setDislikedArtists: (artists) ->
        dispatch(UserActions.setDislikes('artists', artists))
    toggleFade: () ->
        dispatch(PlayerActions.toggleFade())
    openDevicesWatcherWebsocket: (polling) ->
        dispatch(PlayerActions.openDevicesWatcherWebsocket(polling))
    closeDevicesWatcherWebsocket: () ->
        dispatch(PlayerActions.closeDevicesWatcherWebsocket())
    openPlaybackControllerWebsocket: () ->
        dispatch(PlayerActions.openPlaybackControllerWebsocket())
    closePlaybackControllerWebsocket: () ->
        dispatch(PlayerActions.closePlaybackControllerWebsocket())
    openPlaylistTunerWebsocket: () ->
        dispatch(RecommendationActions.openPlaylistTunerWebsocket())
    closePlaylistTunerWebsocket: () ->
        dispatch(RecommendationActions.closePlaylistTunerWebsocket())
    changeDevicesWatcherPolling: (polling) ->
        dispatch(PlayerActions.changeDevicesWatcherPolling(polling))
    setUIState: (newState) ->
        dispatch(UIActions.setState(newState))
    fade: (stopVolume, startVolume, fadeDirection, fadeTimeMinutes, device) ->
        dispatch(
            PlayerActions.fade(
                stopVolume, startVolume, fadeDirection, fadeTimeMinutes, device
            )
        )
    setUserDetails: (details) ->
        dispatch(SpotifyActions.setUserDetails(details))
    focusHomeIn2Seconds: _.debounce(
        (() -> dispatch(UIActions.setFocusHome(true))), 2000)
    defocusHomeIn8Seconds: _.debounce(
        (() -> dispatch(UIActions.setFocusHome(false))), 8000)
    showSidebarIn200ms: _.debounce(
        (() -> dispatch(PlaylistActions.setSidebarHidden(false))), 200)
    showSidebarIn2Seconds: _.debounce(
        (() -> dispatch(PlaylistActions.setSidebarHidden(false))), 2000)
    showHomeTooltipInHalfSecond: _.debounce(
        (() -> dispatch(UIActions.setShowTooltipHome(true))), 2500)
    hideHomeTooltipIn8Seconds: _.debounce(
        (() -> dispatch(UIActions.setShowTooltipHome(false))), 8000)


export default connect(mapStateToProps, mapDispatchToProps)(Playlist)
