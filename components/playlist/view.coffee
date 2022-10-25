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

COLUMN_WIDTH = 200
AUDIO_FEATURE_KEYS = [
        "acousticness",
        "danceability",
        "durationMs",
        "energy",
        "instrumentalness",
        "liveness",
        "loudness",
        "speechiness",
        "tempo",
        "timeSignature",
        "valence"
]
AUDIO_FEATURE_KEY_HEADINGS = [
        "Acoustic",
        "Danceable",
        "Duration",
        "Energy",
        "Instrumental",
        "Live",
        "Loud",
        "Vocal",
        "Tempo",
        "Time",
        "Happy"
]

msToTime = (duration) ->
    milliseconds = Math.floor((duration % 1000) / 100)
    seconds = Math.floor((duration / 1000) % 60)
    minutes = Math.floor((duration / (1000 * 60)) % 60)
    hours = Math.floor((duration / (1000 * 60 * 60)) % 24)

    hoursStr = if (hours < 10) then "0" + hours else hours
    minutesStr = if (minutes < 10) then "0" + minutes else minutes
    secondsStr = if (seconds < 10) then "0" + seconds else seconds

    if hours > 0
        hoursStr + ":" + minutesStr + ":" + secondsStr
    else
        minutesStr + ":" + secondsStr

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
                }
                onClick={ () =>
                    if not @clickedPreview
                        @clickedPreview = true
                        @preview(track)
                }>
                { icon }
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
            <Title style={ marginLeft: 0 } />
            <div className='d-flex flex-center justify-content-between'>
                <Actions
                    style={ marginLeft: 4 }
                    onSavePlaylist={ @props.onSavePlaylist } />
                <Filters style={ marginRight: 4 } />
            </div>
            {if @props.tracks.length > 0
                <div
                    style={{
                        overflowX: 'scroll'
                        height: '80vh'
                    }}
                    className="playlist-table-container">
                    <table
                        style={{
                            width: if @props.sidebarHidden then '97vw' else "calc(100vw - #{ config.SIDEBAR_WIDTH }px)"
                        }}
                        className='track-table'>
                         <thead>
                             <tr>
                                 <th key="play"></th>
                                 <th key="#" className='text-center px-0'>#</th>
                                 <th key="Title">Title</th>
                                 <th key="Artist">Artist</th>
                                 <th key="explicit"></th>
                                 <th key="dislike"></th>
                                 <th key="Album">Album</th>
                                 <th
                                     style={
                                         width: 40
                                         maxWidth: 40
                                         minWidth: 40
                                     }
                                     key="Key">
                                     Key
                                 </th>
                                 {AUDIO_FEATURE_KEY_HEADINGS.map((k) ->
                                     <th
                                         key={ k } className='text-truncate'>
                                         { k }
                                     </th>
                                 )}
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
                                         <td
                                            style={
                                                width: 40
                                                maxWidth: 40
                                                minWidth: 40
                                            }
                                             className='p-1 text-center'>
                                            { @previewIcon(track) }
                                        </td>
                                        <td
                                            className='text-center'
                                            style={
                                                width: 18
                                                minWidth: 18
                                                paddingLeft: 0
                                                paddingRight: 0
                                                opacity: 0.7
                                                fontWeight: 700
                                            }
                                            scope='row'>
                                            {if @state.previewingId is track.id
                                                <Equalizer color={ colors.MAGENTA } />
                                             else
                                                 i+1 }
                                         </td>
                                         <td
                                            style={
                                                width: if @props.sidebarHidden or @props.mobile then COLUMN_WIDTH else (COLUMN_WIDTH * 0.6)
                                                maxWidth: if @props.sidebarHidden or @props.mobile then COLUMN_WIDTH else (COLUMN_WIDTH * 0.6)
                                                minWidth: if @props.sidebarHidden or @props.mobile then COLUMN_WIDTH else (COLUMN_WIDTH * 0.6)
                                            }
                                            className='text-truncate'>{ track.name }</td>
                                         <td
                                            style={
                                                width: if @props.sidebarHidden or @props.mobile then COLUMN_WIDTH else (COLUMN_WIDTH * 0.6)
                                                maxWidth: if @props.sidebarHidden or @props.mobile then COLUMN_WIDTH else (COLUMN_WIDTH * 0.6)
                                                minWidth: if @props.sidebarHidden or @props.mobile then COLUMN_WIDTH else (COLUMN_WIDTH * 0.6)
                                            }
                                            className='text-truncate'>
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
                                        <td
                                            style={
                                                width: 50
                                                maxWidth: 50
                                                minWidth: 50
                                            }
                                        >
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
                                        <td
                                            style={
                                                width: if @props.sidebarHidden or @props.mobile then COLUMN_WIDTH else (COLUMN_WIDTH * 0.6)
                                                maxWidth: if @props.sidebarHidden or @props.mobile then COLUMN_WIDTH else (COLUMN_WIDTH * 0.6)
                                                minWidth: if @props.sidebarHidden or @props.mobile then COLUMN_WIDTH else (COLUMN_WIDTH * 0.6)
                                            }
                                            className='text-truncate'>{ track.album.name }</td>
                                        <td className='text-truncate'>
                                            { "#{ config.KEY_MAPPING[track.audioFeatures?.key] ? "" }#{ if track.audioFeatures?.mode is 0 then "m" else "" }" }
                                        </td>
                                        {AUDIO_FEATURE_KEYS.map((k) ->
                                            <td key={ k } className='text-truncate'>
                                                { if k is 'tempo'
                                                    "#{ Math.round(track.audioFeatures?[k] ? 0) } BPM"
                                                else if k is 'durationMs'
                                                    msToTime(track.audioFeatures?[k] ? 0)
                                                else if k is 'loudness'
                                                    "#{ Math.round(track.audioFeatures?[k] ? 0) } dB"
                                                else if k is 'timeSignature'
                                                    "#{ track.audioFeatures?[k] ? 4 }/4"
                                                else
                                                    <meter
                                                       min="0" max="1"
                                                       low="33" high="66" optimum="80"
                                                       value="#{ track.audioFeatures?[k] ? 0 }">
                                                    </meter>
                                                }
                                            </td>
                                        )}
                                 </tr>)}
                             </FlipMove>
                        </InfiniteScroll>
                    </table>
                </div>
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
                body
                    overflow-y: hidden !important
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
                    border-collapse collapse
                    ease-out 'opacity'
                    @media (min-width: #{ config.WIDTH.medium }px)
                        width 100%

                    thead
                        background-color: black
                        tr
                            th
                                background-color: black
                                position sticky
                                top 0
                                z-index 1
                        tr
                            td, th
                                color magenta
                                font-size .8rem
                                font-style normal
                                font-weight bold
                                padding 10px 4px
                                padding-right 10px
                                text-align left
                                vertical-align middle
                    :global(tbody)
                        position relative !important
                        tr
                            ease-out 0.05s background-color
                            padding-left 13px
                            padding-bottom 5px
                            padding-top 5px

                            &:hover
                                background-color: alpha(peach, 0.3) !important
                                border-radius 6px !important

                            &:last-of-type
                                td, th
                                    border-bottom none

                            td, th
                                border-bottom solid 1px (black + 5%)
                                color white
                                font-size 1rem
                                font-style normal
                                font-weight normal
                                padding 3px 4px
                                text-align left
                                vertical-align middle
                                text-overflow ellipsis
                                overflow hidden
                                white-space nowrap
            """}</style>
        </div>

trackHasDislikedArtists = (track, dislikedArtists) ->
    if track.artists.length is 1
        return dislikedArtists.has(track.artists[0].id)

    trackArtists = new Set(a.id for a in track.artists)

    return trackArtists.intersects(dislikedArtists)

filterTracks = (tracks, filterExplicit, filterDislikes, tuneableAttributes, dislikedArtists) ->
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

            if tuneableAttributes?.key? and track.audioFeatures?.key? and tuneableAttributes?.key isnt track.audioFeatures?.key
                continue
            if tuneableAttributes?.mode? and track.audioFeatures?.mode? and tuneableAttributes?.mode isnt track.audioFeatures?.mode
                continue

            filteredTracks.push(track)

    return filteredTracks


mapStateToProps = (state) ->
    tuneableAttributes: state.recommendations.present.tuneableAttributes
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
        state.playlists.present.filterDislikes,
        state.recommendations.present.tuneableAttributes,
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
