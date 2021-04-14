import React from "react"
import { connect } from "react-redux"
import { Tooltip } from "react-tippy"

import _ from "lodash"
import Link from "next/link"

import CardView from "~/components/cardView"
import MoreButton from "~/components/moreButton"
import RoundedButton from "~/components/roundedButton"
import SearchInput from "~/components/searchInput"
import TimeRangeDropdown from "~/components/timeRangeDropdown"

import ArtistActions from "~/redux/artists"
import SpotifyActions from "~/redux/spotify"
import UIActions from "~/redux/ui"
import UserActions from "~/redux/user"

import colors from "~/styles/colors"

import config from "~/config"

class Artists extends React.Component
    constructor: (props) ->
        super(props)
        searchFn = (query) => @search(query)
        @searchDeferred = _.debounce(searchFn, config.POLLING.SEARCH)
        @state = discovering: false

    @getInitialProps: ({ store, query, res, req, isServer, authenticated, user, api }) ->
        allArtists = store.getState().artists?.present?.allArtists
        if allArtists? and Object.keys(allArtists).length
            await return

        artistRes =
            await api.topArtists(
                all: true
                timeRange: user.artistTimeRange ? config.DEFAULTS.TIME_RANGE
                imageWidth: config.MAX_CARD_SIZE
                imageHeight: config.MAX_CARD_SIZE
            )

        if not artistRes.ok
            await return error: artistRes

        artists = artistRes?.data
        for timeRange, artistList of artists
            artists[timeRange] = _.shuffle(artistList)

        return fetched: { artists }

    componentDidMount: () ->
        if Object.keys(@props.allArtists).length
            @props.finishFetchingArtists()
            return

        user = @props.fetched.user
        timeRange =
            if user.artistTimeRange?.length
                user.artistTimeRange
            else
                config.DEFAULTS.TIME_RANGE
        timeRangeKey = _.camelCase(timeRange)

        actions = []
        if @props.fetched?.artists?
            remainingArtists = @props.fetched.artists[timeRangeKey]?[config.CARD_LIMIT..]
            if remainingArtists?
                actions = [
                    ArtistActions.setAllArtists({
                        @props.fetched.artists...
                        "#{ timeRangeKey }": remainingArtists
                    })
                    ArtistActions.setArtists(
                        @props.fetched.artists[timeRangeKey][...config.CARD_LIMIT]
                    )
                ]
            else
                actions = [
                    ArtistActions.setAllArtists({
                        @props.fetched.artists...
                        "#{ timeRangeKey }": []
                    })
                    ArtistActions.setArtists([])
                ]

        actions.push(ArtistActions.finishFetchingArtists())
        if config.TIME_RANGE_MAPPING[timeRange]?
            actions.push(ArtistActions.setTimeRange(timeRange, (skipUpdate = true)))

        @props.batchActions(actions)

    fetchArtists: ({ timeRange, limit, replace = "unselected", returnAction = false } = {}) ->
        @search("")
        allArtists = [
            (@props.artists ? [])...
            (@props.prevItems ? [])...
            (@props.nextItems ? [])...
        ]
        ignore = (a.id for a in allArtists when not a.temporary)
        limit = limit ? config.CARD_LIMIT - @props.selectedArtists.length
        fetcher =
            if returnAction
                ArtistActions.fetchArtists
            else
                @props.fetchArtists

        fetcher(
            timeRange ? @props.timeRange
            (ignore = ignore)
            (limit = limit)
            (imageWidth = config.MAX_CARD_SIZE)
            (imageHeight = config.MAX_CARD_SIZE)
            (replace = replace)
        )

    onArtistClick: (artist, i) ->
        if artist.selected
            @props.deselectArtist(artist)
        else
            @props.selectArtist(artist)

    onDropdownClick: (timeRange) ->
        actions = []
        if timeRange isnt @props.timeRange
            if not @props.hasSearchQuery
                actions.push(ArtistActions.backupArtists())
            actions = [
                actions...
                ArtistActions.resetPrevItems()
                ArtistActions.resetNextItems()
                ArtistActions.setNoMoreArtists(false)
                ArtistActions.setTimeRange(timeRange)
            ]
            if not @props.timeRangeBackup[timeRange]?
                actions = [
                    actions...
                    @fetchArtists({
                        timeRange
                        limit: config.CARD_LIMIT
                        replace: "all"
                        returnAction: true
                    })
                ]
            else
                actions = [
                    actions...
                    ArtistActions.restoreArtists(timeRange)
                    @search("", (returnActions = true))...
                ]
        @props.batchActions(actions)

    dislike: (artist, { returnActions = false }) ->
        actions = [ArtistActions.dislikeArtist(artist)]
        if @props.prevItems.length is 0 and @props.nextItems.length is 0
            actions.push(
                @fetchArtists(
                    timeRange: @props.timeRange
                    limit: 1
                    replace: "loading"
                    returnAction: true
                )
            )
        if returnActions
            return actions
        else
            @props.batchActions(actions)

    search: (q, returnActions = false) ->
        limit = config.CARD_LIMIT - @props.selectedArtists.length
        actions = [
            ArtistActions.searchArtists(
                q
                limit
                (imageWidth = config.MAX_CARD_SIZE)
                (imageHeight = config.MAX_CARD_SIZE)
            )
        ]
        if returnActions
            return actions
        else
            @props.batchActions(actions)

    render: () ->
        tooManyArtists = @props.selectedArtists?.length is config.CARD_LIMIT
        buttonWidth =
            if @props.windowWidth <= 576
                140
            else
                200
        <div className="fill-window flex-center">
            <div
                id="artists-container"
                className='
                d-flex flex-column
                justify-content-around
                justify-content-lg-center
                align-items-center
                w-100 content'>
                <h1 className="card-heading">Your Top Artists</h1>
                <Tooltip
                    disabled={ not tooManyArtists }
                    trigger="mouseenter"
                    position="bottom"
                    title="Deselect at least one artist">
                    <TimeRangeDropdown
                        disabled={ @props.fetching or tooManyArtists }
                        timeRange={ @props.timeRange }
                        onClick={ (timeRange) => @onDropdownClick(timeRange) }
                    />
                </Tooltip>
                <Tooltip
                    disabled={ not tooManyArtists }
                    trigger="mouseenter"
                    position="bottom"
                    title="Deselect at least one artist">
                    <SearchInput
                        className="mt-2 mb-3"
                        id="artist-search-input"
                        query={ @props.query }
                        search={ (q) =>
                            @props.setArtistSearchQuery(q)
                            @searchDeferred(q)
                         }
                        disabled={ @props.fetching or tooManyArtists }
                        searching={ @props.searching }
                    />
                </Tooltip>
                <p className="pt-3 text-center text-dark instructions">
                    Choose&nbsp;
                    <b className="mauve">1 to { config.CARD_LIMIT } artists</b>
                    &nbsp;and click
                    <b className="red"> Discover</b> to get a new playlist, carefully crafted
                    for your needs
                </p>
                { if @props.artists?.length > 0
                    <CardView
                        removeDislike={ @props.removeDislike }
                        dislikedItems={ @props.dislikedArtists }
                        items={ @props.artists }
                        cardWidth={ config.MAX_CARD_SIZE }
                        cardHeight={ config.MAX_CARD_SIZE }
                        borderRadius={ config.CARD_RADIUS }
                        overlayColor={ config.CARD_OVERLAY_COLOR }
                        showDislikeButton={ true }
                        showPreviousButton={ @props.prevItems.length > 0 }
                        showNextButton={ @props.nextItems.length > 0 }
                        dislike={ (artist, params) => @dislike(artist, params) }
                        onClick={ (artist, i) => @onArtistClick(artist, i) }
                        onPreviousClick={ () => @props.previousArtists() }
                        onNextClick={ () => @props.nextArtists() }
                        loading={ @props.fetching }
                        itemName="artist"
                    />
                else
                    <div
                        className="d-flex justify-content-center align-items-center"
                        style={height: config.MAX_CARD_SIZE, opacity: 0.9}>
                        <h1 className="display-4 text-light text-center font-weight-bold">
                            No artists found
                        </h1>
                    </div>
                 }
                <div className="flex-center bottom-buttons">
                    <MoreButton
                        width={ buttonWidth }
                        noSelectedArtists={ @props.selectedArtists.length is 0 }
                        disabled={
                            @props.selectedArtists.length is config.CARD_LIMIT or
                            @state.discovering
                         }
                        loading={ @props.fetching }
                        noMoreData={ @props.noMoreArtists }
                        itemsName="Artists"
                        className="mr-1 mb-0 py-2 py-md-3"
                        style={
                            maxWidth: buttonWidth
                            minWidth: buttonWidth
                        }
                        onClick={ () => @fetchArtists() }
                    />
                    <Link
                        prefetch
                        passHref
                        href={
                            pathname: "/playlist"
                            query:
                                artists: (a.id for a in @props.selectedArtists).join(",")
                        }>
                        <RoundedButton
                            width={ buttonWidth }
                            color={ colors.RED }
                            className="ml-1 mt-0 py-2 py-md-3"
                            onClick={ () => @setState(discovering: true) }
                            loading={ @state.discovering }
                            style={
                                maxWidth: buttonWidth
                                minWidth: buttonWidth
                            }
                            disabled={
                                @props.selectedArtists.length is 0 or @props.fetching
                             }>
                            Discover
                        </RoundedButton>
                    </Link>
                </div>
                <style global jsx>{"""#{} // stylus
                    body
                        overflow-x hidden
                """}</style>
                <style jsx>{ """#{} // stylus
                    #artists-container
                        margin-top navbarHeightDesktop
                        @media(max-width: $mobile)
                            margin-top navbarHeightMobile + 20px

                    .card-heading
                        color white
                        text-align center
                        margin-bottom 0

                    .instructions
                        max-width: 400px
                        b
                            &.mauve
                                color mauve
                            &.red
                                color red

                    .content
                        margin 2rem auto 100px


                    @media (min-width: #{ config.WIDTH.medium }px)
                        .content
                            margin-bottom 2rem


                    @media (max-width: #{ config.WIDTH.medium }px)
                        .bottom-buttons :global(button)
                            opacity 1

                        .bottom-buttons
                            display flex
                            align-items center
                            justify-content center
                            position fixed
                            bottom 0px
                            padding-bottom 12px
                            padding-top 12px
                            width 100vw
                            background alpha(white, 70%)
                            backdrop-filter blur(40px)
                            -webkit-backdrop-filter blur(40px)
                """ }</style>
            </div>
        </div>

mapStateToProps = ({ artists, spotify, ui }) ->
    artistList = artists.present?.artists ? []
    selectedArtists = (a for a in artistList when a?.selected)
    selectedArtists: selectedArtists
    allArtists: artists.present.allArtists
    artists: artists.present.artists
    fetching: artists.present.fetching
    searching: artists.present.searching
    prevItems: artists.present.prevItems
    nextItems: artists.present.nextItems
    noMoreArtists: artists.present.noMoreArtists
    timeRange: artists.present.timeRange
    timeRangeBackup: artists.present.backup
    dislikedArtists: artists.present.dislikedArtists
    user: spotify.user
    windowWidth: ui.windowWidth
    hasSearchQuery: artists.present.query?.length isnt 0

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    nextArtists: () -> dispatch(ArtistActions.nextArtists())
    previousArtists: () -> dispatch(ArtistActions.previousArtists())
    finishFetchingArtists: () -> dispatch(ArtistActions.finishFetchingArtists())
    fetchArtists: (timeRange, ignore, limit, imageWidth, imageHeight, replace) ->
        dispatch(
            ArtistActions.fetchArtists(
                timeRange
                ignore
                limit
                imageWidth
                imageHeight
                replace
            )
        )
    setArtists: (artists) -> dispatch(ArtistActions.setArtists(artists))
    selectArtist: (artist) -> dispatch(ArtistActions.selectArtist(artist))
    deselectArtist: (artist) -> dispatch(ArtistActions.deselectArtist(artist))
    removeArtist: (artist) -> dispatch(ArtistActions.removeArtist(artist))
    addArtist: (artist) -> dispatch(ArtistActions.addArtist(artist))
    getUserDetails: () -> dispatch(SpotifyActions.getUserDetails())
    toggleDropdown: () -> dispatch(ArtistActions.toggleDropdown())
    setTimeRange: (timeRange, skipUpdate) ->
        dispatch(ArtistActions.setTimeRange(timeRange, skipUpdate))
    setArtistsLoading: () -> dispatch(ArtistActions.setArtistsLoading())
    dislikeArtist: (artist) -> dispatch(ArtistActions.dislikeArtist(artist))
    setNoMoreArtists: (noMore) -> dispatch(ArtistActions.setNoMoreArtists(noMore))
    backup: () -> dispatch(ArtistActions.backupArtists())
    restore: (timeRange) -> dispatch(ArtistActions.restoreArtists(timeRange))
    resetPrevItems: () -> dispatch(ArtistActions.resetPrevItems())
    resetNextItems: () -> dispatch(ArtistActions.resetNextItems())
    setArtistSearchQuery: (query) -> dispatch(ArtistActions.setArtistSearchQuery(query))
    removeDislike: (item) -> dispatch(UserActions.removeDislike("artists", item))
    searchArtists: (query, limit, imageWidth, imageHeight) ->
        dispatch(ArtistActions.searchArtists(query, limit, imageWidth, imageHeight))

export default connect(mapStateToProps, mapDispatchToProps)(Artists)
