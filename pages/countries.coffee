import React from 'react'
import { connect } from 'react-redux'

import _ from 'lodash'
import Router from 'next/router'

import CardView from '~/components/cardView'
import MoreButton from '~/components/moreButton'

import CountryActions from '~/redux/countries'
import SpotifyActions from '~/redux/spotify'
import UIActions from '~/redux/ui'
import UserActions from '~/redux/user'

import config from '~/config'

class Countries extends React.Component
    @getInitialProps: ({ store, query, res, req, isServer, authenticated, user, api }) ->
        allCountries = store.getState().countries?.present?.allCountries
        if allCountries?.length
            await return

        countryRes = await api.countries({
            all: true
            imageWidth: config.MAX_CARD_SIZE
            imageHeight: config.MAX_CARD_SIZE
        })

        if not countryRes.ok
            await return { error: countryRes }
        countries = _.shuffle(countryRes.data)

        await return {
            fetched: { countries }
            fetching: false
        }

    componentDidMount: ->
        if @props.allCountries.length
            @props.finishFetchingCountries()
            return

        actions = []
        if @props.fetched?.countries?
            actions = [
                CountryActions.setAllCountries(
                    @props.fetched.countries[config.CARD_LIMIT..]
                )
                CountryActions.setCountries(
                    @props.fetched.countries[...(config.CARD_LIMIT)]
                )
            ]
        actions.push(CountryActions.finishFetchingCountries())
        @props.batchActions(actions)

    fetchCountries: ({
        limit = config.CARD_LIMIT, returnAction = false,
        replace = 'unselected'
    } = {}) ->
        allCountries = [
            (@props.countries ? [])...
            (@props.prevItems ? [])...
            (@props.nextItems ? [])...
        ]
        ignore = (c.code for c in allCountries when not c.loading)
        fetcher = if returnAction
            CountryActions.fetchCountries
        else
            @props.fetchCountries

        fetcher(
            ignore = ignore,
            limit = limit,
            imageWidth = config.MAX_CARD_SIZE,
            imageHeight = config.MAX_CARD_SIZE,
            replace = replace)

    onCountryClick: (country, i) ->
        if country?
            playlists = country.playlists
            if @props.user.firstCountryClick and playlists?
                playlist = playlists.find((p) -> p.popularity is config.POPULARITY.CURRENT) ?
                    playlists.find((p) -> p.popularity is config.POPULARITY.EMERGING) ?
                    playlists.find((p) -> p.popularity is config.POPULARITY.UNDERGROUND)
                @props.setUserDetails(firstCountryClick: false)
                Router.push({
                    pathname: '/playlist',
                    query: {
                        id: playlist.id
                        image: btoa(country.image?.url ? '')
                        user: playlist.owner
                    }
                })
            else
                actions = [CountryActions.selectCountry(country)]
                @props.batchActions(actions)

    dislike: (country, { returnActions = false }) ->
        actions = [CountryActions.dislikeCountry(country)]
        if @props.prevItems.length is 0 and @props.nextItems.length is 0
            actions.push(
                @fetchCountries(limit: 1, returnAction: true, replace: 'loading')
            )
        if returnActions
            return actions
        else
            @props.batchActions(actions)

    render: ->
        <div className='fill-window flex-center'>
            <div id='countries-container' className='
                d-flex flex-column
                justify-content-around
                justify-content-lg-center
                align-items-center w-100 content'>
                <h1 className='card-heading'>The Sound of Countries</h1>
                <CardView
                    removeDislike={ @props.removeDislike }
                    dislikedItems={ @props.dislikedCountries }
                    items={ @props.countries }
                    cardWidth={ config.MAX_CARD_SIZE }
                    cardHeight={ config.MAX_CARD_SIZE }
                    borderRadius={ config.CARD_RADIUS }
                    overlayColor={ config.CARD_OVERLAY_COLOR }
                    showDislikeButton={ true }
                    showPreviousButton={ @props.prevItems.length > 0 }
                    showNextButton={ @props.nextItems.length > 0 }
                    onClick={ (country, i) => @onCountryClick(country, i) }
                    dislike={ (country, params) => @dislike(country, params) }
                    onPreviousClick={ () => @props.previousCountries() }
                    onNextClick={ () => @props.nextCountries() }
                    loading={ @props.fetching }
                    itemName='country'
                    clickedItem={ @props.selectedCountry }
                    deselectItem={ () => @props.deselectCountry() }>
                </CardView>
                <div className='bottom-buttons'>
                    <MoreButton
                        loading={ @props.fetching }
                        noMoreData={ @props.noMoreCountries }
                        itemsName='Countries'
                        onClick={ () => @fetchCountries() }>
                    </MoreButton>
                </div>
            </div>
            <style global jsx>{"""#{} // stylus
                body
                    overflow-x hidden
            """}</style>
            <style jsx>{"""#{} // stylus
                #countries-container
                    margin-top navbarHeightDesktop
                    @media(max-width: $mobile)
                        margin-top navbarHeightMobile + 20px

                .card-heading
                    color mutedRed
                    text-align center
                    margin-bottom 2rem


                .content
                    margin 2rem auto 100px


                @media (min-width: #{ config.WIDTH.medium }px)
                    .content
                        margin-top 5rem
                        margin-bottom 2rem


                @media (max-width: #{ config.WIDTH.medium }px)
                    .bottom-buttons :global(button)
                        max-width 40vw !important
                        opacity 1

                    .bottom-buttons
                        display flex
                        justify-content center
                        align-items center
                        position fixed
                        bottom 0
                        width 100vw
                        height 100px


            """}</style>
        </div>

mapStateToProps = ({ countries, spotify }) ->
    selectedCountry: countries.present.selectedCountry
    allCountries: countries.present.allCountries
    countries: countries.present.countries
    fetching: countries.present.fetching
    prevItems: countries.present.prevItems
    nextItems: countries.present.nextItems
    noMoreCountries: countries.present.noMoreCountries
    dislikedCountries: countries.present.dislikedCountries
    user: spotify.user

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    nextCountries: () -> dispatch(CountryActions.nextCountries())
    previousCountries: () -> dispatch(CountryActions.previousCountries())
    fetchCountries: (ignore, limit, imageWidth, imageHeight, replace) ->
        dispatch(
            CountryActions.fetchCountries(
                ignore, limit, imageWidth, imageHeight, replace
            )
        )
    selectCountry: (country) -> dispatch(CountryActions.selectCountry(country))
    finishFetchingCountries: () -> dispatch(CountryActions.finishFetchingCountries())
    deselectCountry: () -> dispatch(CountryActions.deselectCountry())
    removeCountry: (country) -> dispatch(CountryActions.removeCountry(country))
    addCountry: (country) -> dispatch(CountryActions.addCountry(country))
    setAllCountries: (countries) -> dispatch(CountryActions.setAllCountries(countries))
    setCountries: (countries) -> dispatch(CountryActions.setCountries(countries))
    getUserDetails: () -> dispatch(SpotifyActions.getUserDetails())
    setUserDetails: (details) -> dispatch(SpotifyActions.setUserDetails(details))
    dislikeCountry: (country) -> dispatch(CountryActions.dislikeCountry(country))
    resetPrevItems: () -> dispatch(CountryActions.resetPrevItems())
    resetNextItems: () -> dispatch(CountryActions.resetNextItems())
    removeDislike: (item) -> dispatch(UserActions.removeDislike('countries', item))


export default connect(mapStateToProps, mapDispatchToProps)(Countries)
