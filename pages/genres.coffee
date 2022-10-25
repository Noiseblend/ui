import React from 'react'
import { connect } from 'react-redux'

import _ from 'lodash'
import Router from 'next/router'

import CardView from '~/components/cardView'
import MoreButton from '~/components/moreButton'
import TimeRangeDropdown from '~/components/timeRangeDropdown'

import GenreActions from '~/redux/genres'
import SpotifyActions from '~/redux/spotify'
import UIActions from '~/redux/ui'
import UserActions from '~/redux/user'

import config from '~/config'
import '~/lib/util'

class Genres extends React.Component
    @getInitialProps: ({ store, query, res, req, isServer, authenticated, user, api }) ->
        allGenres = store.getState().genres?.present?.allGenres
        if allGenres? and Object.keys(allGenres).length
            await return

        genreRes = await api.topGenres({
            all: true
            timeRange: user.artistTimeRange ? config.DEFAULTS.TIME_RANGE
            imageWidth: config.MAX_CARD_SIZE
            imageHeight: config.MAX_CARD_SIZE
        })

        if not genreRes.ok
            await return { error: genreRes }

        genres = genreRes?.data
        for timeRange, genreList of genres
            genres[timeRange] = _.shuffle(genreList)

        await return {
            fetched: { genres }
            fetching: false
        }

    componentDidMount: ->
        if Object.keys(@props.allGenres).length
            @props.finishFetchingGenres()
            return

        user = @props.fetched?.user
        timeRange = if user?.genreTimeRange?.length
            user.genreTimeRange
        else
            config.DEFAULTS.TIME_RANGE
        timeRangeKey = _.camelCase(timeRange)

        actions = []
        if @props.fetched?.genres?
            remainingGenres = @props.fetched.genres[timeRangeKey]?[config.CARD_LIMIT..]
            if remainingGenres?
                actions = [
                    GenreActions.setAllGenres({
                        @props.fetched.genres...
                        "#{ timeRangeKey }": remainingGenres
                    })
                    GenreActions.setGenres(
                        @props.fetched.genres[timeRangeKey][...(config.CARD_LIMIT)]
                    )
                ]
            else
                actions = [
                    GenreActions.setAllGenres({
                        @props.fetched.genres...
                        "#{ timeRangeKey }": []
                    })
                    GenreActions.setGenres([])
                ]

        actions.push(GenreActions.finishFetchingGenres())
        if config.TIME_RANGE_MAPPING[timeRange]?
            actions.push(GenreActions.setTimeRange(timeRange, skipUpdate = true))

        @props.batchActions(actions)

    fetchGenres: ({
        timeRange, limit = config.CARD_LIMIT, replace = 'unselected'
        returnAction = false
    } = {}) ->
        allGenres = [
            (@props.genres ? [])...
            (@props.prevItems ? [])...
            (@props.nextItems ? [])...
        ]
        ignore = (g.name for g in allGenres when not g.temporary)
        fetcher = if returnAction
            GenreActions.fetchGenres
        else
            @props.fetchGenres

        fetcher(
            timeRange ? @props.timeRange,
            ignore = ignore,
            limit = limit,
            imageWidth = config.MAX_CARD_SIZE,
            imageHeight = config.MAX_CARD_SIZE,
            replace = replace)

    onGenreClick: (genre, i) ->
        if genre?
            playlists = genre.playlists
            if @props.user.firstGenreClick and playlists?
                playlist = playlists.find((p) -> p.popularity is config.POPULARITY.INTRO) ?
                    playlists.find((p) -> p.popularity is config.POPULARITY.PULSE) ?
                    playlists.find((p) -> p.popularity is config.POPULARITY.SOUND)
                @props.setUserDetails(firstGenreClick: false)
                Router.push({
                    pathname: '/playlist',
                    query: {
                        id: playlist.id
                        image: btoa(genre.image?.url ? '')
                        user: playlist.owner
                    }
                 })
            else
                actions = [GenreActions.selectGenre(genre)]
                @props.batchActions(actions)

    onDropdownClick: (timeRange) ->
        if timeRange isnt @props.timeRange
            actions = [
                GenreActions.backupGenres()
                GenreActions.resetPrevItems()
                GenreActions.resetNextItems()
                GenreActions.setNoMoreGenres(false)
                GenreActions.setTimeRange(timeRange)
            ]
            if not @props.timeRangeBackup[timeRange]?
                actions = [
                    actions...
                    @fetchGenres({
                        timeRange,
                        replace: 'all'
                        returnAction: true
                    })
                ]
            else
                actions.push(GenreActions.restoreGenres(timeRange))
            @props.batchActions(actions)

    dislike: (genre, { returnActions = false }) ->
        actions = [GenreActions.dislikeGenre(genre)]
        if @props.prevItems.length is 0 and @props.nextItems.length is 0
            actions.push(
                @fetchGenres({
                    timeRange: @props.timeRange
                    limit: 1
                    replace: 'loading'
                    returnAction: true
                })
            )
        if returnActions
            return actions
        else
            @props.batchActions(actions)


    render: ->
        <div
            className='fill-window flex-center'
            style={
                transition: 'filter 0.3s ease'
                maxHeight: '100vh' if @props.selectedGenre?
                maxWidth: '100vw' if @props.selectedGenre?
            }>
            <div id='genres-container' className='
                d-flex flex-column
                justify-content-around
                justify-content-lg-center
                align-items-center
                w-100 content'>
                <h1 className='card-heading'>Your Top Genres</h1>
                <TimeRangeDropdown
                    timeRange={ @props.timeRange }
                    onClick={ (timeRange) => @onDropdownClick(timeRange) }>
                </TimeRangeDropdown>
                <CardView
                    removeDislike={ @props.removeDislike }
                    dislikedItems={ @props.dislikedGenres }
                    items={ @props.genres }
                    cardWidth={ config.MAX_CARD_SIZE }
                    cardHeight={ config.MAX_CARD_SIZE }
                    borderRadius={ config.CARD_RADIUS }
                    overlayColor={ config.CARD_OVERLAY_COLOR }
                    showDislikeButton={ true }
                    showPreviousButton={ @props.prevItems.length > 0 }
                    showNextButton={ @props.nextItems.length > 0 }
                    dislike={ (genre, params) => @dislike(genre, params) }
                    onClick={ (genre, i) => @onGenreClick(genre, i) }
                    onPreviousClick={ () => @props.previousGenres() }
                    onNextClick={ () => @props.nextGenres() }
                    loading={ @props.fetching }
                    itemName='genre'
                    clickedItem={ @props.selectedGenre }
                    deselectItem={ () => @props.deselectGenre() }>
                </CardView>
                <div className='bottom-buttons'>
                    <MoreButton
                        loading={ @props.fetching }
                        noMoreData={ @props.noMoreGenres }
                        itemsName='Genres'
                        onClick={ () => @fetchGenres() }>
                    </MoreButton>
                </div>
            </div>
            <style global jsx>{"""#{} // stylus
                body
                    overflow-x hidden
            """}</style>
            <style jsx>{"""#{} // stylus
                #genres-container
                    margin-top navbarHeightDesktop
                    @media(max-width: $mobile)
                        margin-top navbarHeightMobile + 20px

                .card-heading
                    color mutedRed
                    text-align center
                    margin-bottom 0

                .content
                    margin 2rem auto 100px

                    @media (min-width: #{ config.WIDTH.medium }px)
                        margin-top 5rem
                        margin-bottom 2rem

                @media (max-width: #{ config.WIDTH.medium }px)
                    .bottom-buttons
                        display flex
                        justify-content center
                        align-items center
                        position fixed
                        bottom 0
                        width 100vw
                        height 100px

                        :global(button)
                            max-width 40vw !important
                            opacity 1
            """}</style>
        </div>

mapStateToProps = (state) ->
    selectedGenre: state.genres.present.selectedGenre
    allGenres: state.genres.present.allGenres
    genres: state.genres.present.genres
    fetching: state.genres.present.fetching
    prevItems: state.genres.present.prevItems
    nextItems: state.genres.present.nextItems
    noMoreGenres: state.genres.present.noMoreGenres
    timeRange: state.genres.present.timeRange
    dropdownOpen: state.genres.present.dropdownOpen
    timeRangeBackup: state.genres.present.backup
    dislikedGenres: state.genres.present.dislikedGenres
    user: state.spotify.user

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    nextGenres: () -> dispatch(GenreActions.nextGenres())
    previousGenres: () -> dispatch(GenreActions.previousGenres())
    fetchGenres: (timeRange, ignore, limit, imageWidth, imageHeight, replace) ->
        dispatch(
            GenreActions.fetchGenres(
                timeRange, ignore, limit, imageWidth, imageHeight, replace
            )
        )
    selectGenre: (genre) -> dispatch(GenreActions.selectGenre(genre))
    finishFetchingGenres: () -> dispatch(GenreActions.finishFetchingGenres())
    deselectGenre: () -> dispatch(GenreActions.deselectGenre())
    removeGenre: (genre) -> dispatch(GenreActions.removeGenre(genre))
    addGenre: (genre) -> dispatch(GenreActions.addGenre(genre))
    setGenres: (genres) -> dispatch(GenreActions.setGenres(genres))
    setAllGenres: (genres) -> dispatch(GenreActions.setAllGenres(genres))
    getUserDetails: () -> dispatch(SpotifyActions.getUserDetails())
    setUserDetails: (details) -> dispatch(SpotifyActions.setUserDetails(details))
    toggleDropdown: () -> dispatch(GenreActions.toggleDropdown())
    setGenresLoading: () -> dispatch(GenreActions.setGenresLoading())
    setTimeRange: (timeRange, skipUpdate) ->
        dispatch(GenreActions.setTimeRange(timeRange, skipUpdate))
    dislikeGenre: (genre) -> dispatch(GenreActions.dislikeGenre(genre))
    setNoMoreGenres: (noMore) -> dispatch(GenreActions.setNoMoreGenres(noMore))
    backup: () -> dispatch(GenreActions.backupGenres())
    restore: (timeRange) -> dispatch(GenreActions.restoreGenres(timeRange))
    resetPrevItems: () -> dispatch(GenreActions.resetPrevItems())
    resetNextItems: () -> dispatch(GenreActions.resetNextItems())
    removeDislike: (item) -> dispatch(UserActions.removeDislike('genres', item))

export default connect(mapStateToProps, mapDispatchToProps)(Genres)
