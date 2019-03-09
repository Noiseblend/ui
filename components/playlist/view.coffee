import '~/lib/sets'

import React from 'react'
import FlipMove from 'react-flip-move'
import InfiniteScroll from 'react-infinite-scroller'
import { connect } from 'react-redux'

import anime from 'animejs'
import _ from 'lodash'

import DislikeButton from '~/components/dislikeButton'
import Equalizer from '~/components/equalizer'
import LoadingDots from '~/components/loadingDots'
import PreviewTimer from '~/components/previewTimer'
import TextButton from '~/components/textButton'
import Undo from '~/components/undo'

import { classif } from '~/lib/util'

import PlaylistActions from '~/redux/playlists'
import RecommendationActions from '~/redux/recommendations'
import SpotifyActions from '~/redux/spotify'
import UIActions from '~/redux/ui'
import UserActions from '~/redux/user'

import colors from '~/styles/colors'
import { PlayCircle, Settings } from '~/styles/icons'

import config from '~/config'

import Actions from './actions'
import Filters from './filters'
import ResetTuningButton from './resetTuningButton'
import Title from './title'


class PlaylistView extends React.Component
    constructor: (props) ->
        super props
        @lastDisliked = null
        @clickedPreview = false
        @state =
            previewingId: null
            preview: null
            fadingOut: false
            pausing: false
            remainingSeconds: 30

    componentWillUnmount: ->
        @stopPreview()

    stopPreview: (audio) ->
        (audio ? @state.preview)?.pause()
        @setState(
            preview: null
            previewingId: null
            fadingOut: false
            pausing: false
            remainingSeconds: 30
        )

    preview: (track) ->
        if not track.previewUrl?
            return

        timeline = anime.timeline(autoplay: false)
        lastPreviewingId = @state.previewingId
        lastPreview = @state.preview
        if @state.previewingId?
            timeline = timeline.add(
                begin: () =>
                    @setState
                        fadingOut: true
                        pausing: true
                        remainingSeconds: 30
                targets: lastPreview
                volume: [1.0, 0.01]
                duration: 800
                easing: 'easeOutCubic'
                complete: (anim) =>
                    lastPreview.pause()
                    @setState(
                        preview: null
                        previewingId: null
                        fadingOut: false
                        pausing: false
                    )
                    @clickedPreview = false
            )
        if lastPreviewingId isnt track.id
            if track.previewUrl?
                audio = new Audio(track.previewUrl)
                stopPreview = () => @stopPreview(audio)

                audio.volume = 0
                audio.onstalled = stopPreview
                audio.onerror = stopPreview
                audio.onended = stopPreview
                audio.onabort = stopPreview
                audio.ontimeupdate = () => (
                    remainingSeconds = audio.duration - audio.currentTime

                    intRemainingSeconds = Math.floor(remainingSeconds)
                    if intRemainingSeconds isnt @state.remainingSeconds
                        @setState
                            remainingSeconds: intRemainingSeconds

                    if remainingSeconds <= 2 and not @state.fadingOut
                        @setState(fadingOut: true)
                        anime(
                            targets: audio
                            volume: [1.0, 0.01]
                            duration: remainingSeconds * 1000
                            easing: 'easeOutCubic'
                        )
                )

                timeline = timeline.add(
                    begin: (anim) =>
                        lastPreview?.pause()
                        @setState(preview: audio, previewingId: track.id, fadingOut: false)
                        audio.play()
                    targets: audio
                    volume: [0.01, 1.0]
                    duration: 1200
                    easing: 'easeInCubic'
                    complete: () =>
                        @clickedPreview = false
                )
            else
                @props.setInfoMessage(
                    "Track \"#{ track.name }\" cannot be previewed",
                    format = false
                )
                setTimeout((() => @props.setInfoMessage(null)), 3000)

        timeline.play()

    previewIcon: (track) ->
        if track?
            previewing = @state.previewingId is track.id and not @state.pausing
            icon = if previewing
                <PreviewTimer
                    color={ colors.WHITE }
                    remainingSeconds={ @state.remainingSeconds }
                    hoverColor={ colors.MAGENTA } />
            else
                <PlayCircle />

            <TextButton
                className='
                    px-1 py-0 mx-auto flex-column-center
                    preview-button'
                shadow={ if previewing then 2 else 1 }
                color={ colors.WHITE }
                hoverColor={ colors.MAGENTA }
                disabledColor={ colors.DARK_GRAY }
                disabled={ not track.previewUrl? }
                style={
                    background: 'transparent'
                    border: 'none'
                    marginBottom: -16
                }
                onClick={ () =>
                    if not @clickedPreview
                        @clickedPreview = true
                        @preview(track)
                }>
                { icon }
                <span className='text-center' style={
                    fontSize: 12
                    opacity: if previewing then 1 else 0
                    transition: 'opacity 0.3s ease-in'
                }>
                    Preview
                </span>
            </TextButton>

    dislike: (track) ->
        if track.artists.length > 1
            @props.dislikeArtist(track.artists)
            @lastDisliked = track.artists
        else
            @props.dislikeArtist(track.artists[0])
            @lastDisliked = track.artists[0]

        @props.showUndo()
        @props.hideUndoIn5Seconds()

    like: (track) ->
        if track.artists.length > 1
            @props.likeArtist(track.artists)
        else
            @props.likeArtist(track.artists[0])

    onUndo: ->
        if @lastDisliked?
            @props.likeArtist(@lastDisliked)
        @props.hideUndo()

    render: ->
        navbarHeight = if @props.mobile
            config.NAVBAR_HEIGHT.mobile + 10
        else
            config.NAVBAR_HEIGHT.desktop + 20
        <div
            className="playlist-container #{ @props.className ? '' }"
            style={{
                minHeight: '100vh'
                @props.style...
                marginTop: navbarHeight
            }}>
            <Undo
                top
                show={ not @props.undoHidden }
                onClick={ () => @onUndo() } />
            <Title style={ marginLeft: 10 } />
            <Actions
                style={ marginLeft: 10 }
                onSavePlaylist={ @props.onSavePlaylist } />
            <Filters style={ marginLeft: 12 } />
            {if @props.tracks.length > 0
                <table className='w-100 track-table'>
                     <thead>
                         <tr>
                             <th></th>
                             <th className='text-center px-0'>#</th>
                             <th>Title</th>
                             <th>Artist</th>
                             <th></th>
                             <th></th>
                             <th>Album</th>
                         </tr>
                     </thead>
                     <InfiniteScroll
                         element='tbody'
                         initialLoad={ false }
                         pageStart={ 0 }
                         loadMore={ @props.fetchTracks }
                         hasMore={ @props.hasMore }>
                         <FlipMove
                             typeName={ null }
                             enterAnimation='fade'
                             leaveAnimation={ null }>
                             {@props.tracks.map((track, i) =>
                                 <tr
                                    style={
                                        backgroundColor: if track.disliked
                                            colors.MAGENTA.alpha(0.2)
                                        else
                                            'transparent'
                                    }
                                     key={ track.id }>
                                     <td className='p-1 text-center'>
                                        { @previewIcon(track) }
                                    </td>
                                    <th
                                        className='text-center'
                                        style={
                                            width: 34
                                            minWidth: 34
                                            paddingLeft: 0
                                            paddingRight: 0
                                        }
                                        scope='row'>
                                        {if @state.previewingId is track.id
                                            <Equalizer color={ colors.MAGENTA } />
                                         else
                                             i+1 }
                                     </th>
                                     <td className='text-truncate'>{ track.name }</td>
                                     <td className='text-truncate'>
                                        { (a.name for a in track.artists).join(' & ') }
                                    </td>
                                    <td
                                        style={
                                            width: 20
                                            maxWidth: 20
                                            minWidth: 20
                                        }
                                        className='p-0 explicit-tag'>
                                        { if track.explicit
                                            color = colors.DARK_GRAY.mix(colors.RED, 0.5)
                                            <div
                                                className='
                                                    font-heading
                                                    mx-auto text-center
                                                    d-flex justify-content-center
                                                    align-items-center'
                                                style={
                                                    color: color
                                                    border: "2px solid #{ color }"
                                                    borderRadius: 4
                                                    fontWeight: 700
                                                    fontSize: 14
                                                    width: 18
                                                    maxWidth: 18
                                                    minWidth: 18
                                                }>
                                                E
                                            </div>
                                        }
                                    </td>
                                    <td>
                                        <DislikeButton
                                            id={ i }
                                            flip={ 'vertical' if track.disliked }
                                            onClick={ () =>
                                                if track.disliked
                                                    @like(track)
                                                else
                                                    @dislike(track)
                                                if @props.user.firstDislike
                                                    @props.setUserDetails({
                                                        firstDislike: false
                                                    })
                                                    @props.showProfileTooltipInHalfSecond()
                                                    @props.setFocusProfile(true)
                                                    @props.defocusProfileIn8Seconds()
                                                    @props.hideProfileTooltipIn8Seconds()
                                            }
                                            backgroundColor='transparent'
                                            color={ colors.WHITE } />
                                    </td>
                                    <td className='text-truncate'>{ track.album.name }</td>
                             </tr>)}
                         </FlipMove>
                    </InfiniteScroll>
                </table>
            else
                <div
                    style={
                        marginTop: '20vh'
                    }
                    className="
                        d-flex flex-column h-100 w-100
                        justify-content-center
                        align-items-center
                        text-light">
                    <h4
                        style={
                            color: colors.LIGHT_GRAY
                        }
                        className='text-center mb-4 w-75'>
                        Well, you've got some high expectations!
                    </h4>
                    <h5 className='text-center w-75'>
                        There are no songs within the values you chose
                    </h5>
                    <div className="
                        d-flex flex-column flex-lg-row mt-4
                        justify-content-center
                        align-items-center">
                        <Undo
                            className='py-3 px-5'
                            disabled={ not @props.hasPastStates }
                            style={
                                zIndex: null
                            }
                            width={ 220 }
                            onClick={ () =>
                                @props.applyTuningAsync(@props.artists)
                            }>
                            Undo last action
                        </Undo>
                        <ResetTuningButton
                            width={ 220 }
                            color={ colors.WHITE } >
                            Reset attributes
                        </ResetTuningButton>
                    </div>
                </div>
            }
            { if @props.tuning
                <div
                    style={
                        position: 'fixed'
                        top: 0
                        left: 0
                        width: if @props.sidebarHidden
                            '100vw'
                        else
                            "calc(100vw - #{ config.SIDEBAR_WIDTH }px)"
                     }
                    className='
                        flex-center fill-height
                        tuning-indicator-container'>
                    <h2 id='tuning-indicator'>Tuning</h2>
                </div>
            }
            { if @props.loading.fetchingTracks
                <LoadingDots key={ 3 } color={ colors.YELLOW } className='mx-auto' />
            }
            <style global jsx>{"""#{} // stylus
                .dislike-button
                    margin 0
                    width 2.5rem !important
                    height 2.5rem !important
                    border-radius 2rem !important
                    font-size 1rem !important

            """}</style>
            <style jsx>{"""#{} // stylus
                .tuning-indicator-container
                    background-color alpha(black, 0.6)
                    absolute top left
                    height 100vh
                    #tuning-indicator
                        color white
                        opacity 0.5
                        pulse 1s

                .playlist-container
                    @media (min-width: #{ config.WIDTH.medium }px)
                        width 100%

                .track-table
                    position relative
                    ease-out 'opacity'
                    @media (min-width: #{ config.WIDTH.medium }px)
                        width 100%

                    thead
                        tr
                            td, th
                                color magenta
                                font-size 1.3rem
                                font-style normal
                                font-weight bold
                                padding 20px 10px
                                text-align left
                                vertical-align middle
                                ease-out width
                    :global(tbody)
                        position relative !important
                        tr
                            ease-out 0.15s background-color
                            padding-left 13px
                            padding-bottom 5px
                            padding-top 5px

                            &:last-of-type
                                td, th
                                    border-bottom none

                            td, th
                                border-bottom solid 1px (black + 5%)
                                color white
                                font-size 1rem
                                font-style normal
                                font-weight normal
                                padding 10px 5px
                                text-align left
                                vertical-align middle
                                max-width 30vw
                                @media(max-width: $mobile)
                                    max-width 40vw
            """}</style>
        </div>

trackHasDislikedArtists = (track, dislikedArtists) ->
    if track.artists.length is 1
        return dislikedArtists.has(track.artists[0].id)

    trackArtists = new Set(a.id for a in track.artists)

    return trackArtists.intersects(dislikedArtists)

filterTracks = (tracks, filterExplicit, filterDislikes, dislikedArtists) ->
    filteredTracks = []
    if tracks?
        for t in tracks
            track = t.track
            track = {
                track...
                disliked: trackHasDislikedArtists(track, dislikedArtists)
            }

            if filterExplicit and track.explicit
                continue

            if filterDislikes and track.disliked
                continue

            filteredTracks.push(track)

    return filteredTracks


mapStateToProps = (state) ->
    hasPastStates     : state.recommendations.past?.length > 0
    tuning            : state.recommendations.present.tuning
    dislikedArtists   : state.user.dislikedArtists
    modified          : state.playlists.present.modified
    loading           : state.playlists.present.loading
    user              : state.spotify.user
    sidebarHidden     : state.playlists.present.sidebarHidden
    undoHidden        : state.ui.undoHidden
    mobile            : state.ui.mobile
    tracks            : filterTracks(
        state.playlists.present.playlist?.tracks?.items,
        state.playlists.present.filterExplicit,
        state.playlists.present.filterDislikes
        new Set(a.id for a in state.user.dislikedArtists)
    )
    hasMore           : (
        state.playlists.present.playlist?.tracks?.items.length <
        state.playlists.present.playlist?.tracks?.total
    )


mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    hideUndoIn5Seconds: _.debounce(
        (() -> dispatch(UIActions.setUndoHidden(true))), 5000)
    showUndo: () -> dispatch(UIActions.setUndoHidden(false))
    hideUndo: () -> dispatch(UIActions.setUndoHidden(true))
    dislikeArtist: (artist) ->
        dispatch([
            PlaylistActions.dislikeArtist(artist)
            UserActions.addDislike('artists', artist)
            UserActions.invalidateDislikes()
        ])
    setPlaylistName: (name) ->
        dispatch(PlaylistActions.setPlaylistName(name))
    likeArtist: (artist) ->
        dispatch([
            UserActions.removeDislike('artists', artist)
            UserActions.invalidateDislikes()
        ])
    setInfoMessage: (info, format = true) ->
        dispatch(SpotifyActions.setInfoMessage(info, format))
    applyTuning: (artists) ->
        dispatch(RecommendationActions.applyTuning({ seedArtists: artists }))
    applyTuningAsync: (artists) ->
        dispatch(RecommendationActions.applyTuningAsync({ seedArtists: artists }))
    applyOrder: () ->
        dispatch(PlaylistActions.applyOrder())
    setUserDetails: (details) ->
        dispatch(SpotifyActions.setUserDetails(details))
    setFocusProfile: (focusProfile) ->
        dispatch(UIActions.setFocusProfile(focusProfile))
    defocusProfileIn8Seconds: _.debounce(
        (() -> dispatch(UIActions.setFocusProfile(false))), 8000)
    showProfileTooltipInHalfSecond: _.debounce(
        (() -> dispatch(UIActions.setShowTooltipProfile(true))), 500)
    hideProfileTooltipIn8Seconds: _.debounce(
        (() -> dispatch(UIActions.setShowTooltipProfile(false))), 8000)

export default connect(mapStateToProps, mapDispatchToProps)(PlaylistView)
