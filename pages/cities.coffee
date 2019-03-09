import React from 'react'
import { connect } from 'react-redux'

import _ from 'lodash'
import Router from 'next/router'

import CardView from '~/components/cardView'
import CountryDropdown from '~/components/countryDropdown'
import Layout from '~/components/layout'
import MoreButton from '~/components/moreButton'

import CityActions from '~/redux/cities'
import SpotifyActions from '~/redux/spotify'
import UIActions from '~/redux/ui'
import UserActions from '~/redux/user'

import config from '~/config'

class Cities extends React.Component
    constructor: (props) ->
        super props
        @state =
            cityClicked: false

    @getInitialProps: ({ store, query, res, req, isServer, authenticated, user, api }) ->
        allCities = store.getState().cities?.present?.allCities
        if allCities? and Object.keys(allCities).length
            await return

        cityRes = await api.cities({
            all: true
            withCountries: true
            country: user.preferredCountry ? user.country
            imageWidth: config.MAX_CARD_SIZE
            imageHeight: config.MAX_CARD_SIZE
        })

        if not cityRes.ok
            await return { error: cityRes }
        cities = _.shuffle(cityRes.data.cities)
        countries = cityRes.data.countries

        await return {
            fetched: { cities, countries }
            fetching: false
        }

    componentDidMount: ->
        if Object.keys(@props.allCities).length
            @props.finishFetchingCities()
            return

        user = @props.fetched.user

        country = if user.preferredCountry?.length
            user.preferredCountry
        else
            user.country
        userCountry = _.find(@props.fetched.countries, { code: country })

        actions = []
        if @props.fetched?.cities? and userCountry?
            remainingCities = @props.fetched.cities[config.CARD_LIMIT..]
            actions = [
                CityActions.setAllCities({
                    "#{ userCountry.code }": remainingCities
                })
                CityActions.setCities(
                    @props.fetched.cities[...(config.CARD_LIMIT)]
                )
            ]

        if @props.fetched?.countries?
            actions.push(CityActions.setCountries(@props.fetched.countries))
        if userCountry?
            actions.push(CityActions.setCountry(userCountry, skipUpdate = true))
        actions.push(CityActions.finishFetchingCities())

        @props.batchActions(actions)


    fetchCities: ({
        limit = config.CARD_LIMIT, country,
        returnAction = false, replace = 'unselected'
    } = {}) ->
        allCities = [
            (@props.cities ? [])...
            (@props.prevItems ? [])...
            (@props.nextItems ? [])...
        ]
        ignore = (a.name for a in allCities when not a.temporary)
        fetcher = if returnAction
            CityActions.fetchCities
        else
            @props.fetchCities

        fetcher(
            country ? @props.country.code,
            ignore = ignore,
            limit = limit,
            imageWidth = config.MAX_CARD_SIZE,
            imageHeight = config.MAX_CARD_SIZE,
            replace = replace)

    onCityClick: (city, i) ->
        @setState(cityClicked: true)
        Router.push(
            pathname: '/playlist'
            query:
                user: city.playlist.owner
                id: city.playlist.id
        )

    onDropdownClick: (countryName) ->
        if countryName isnt @props.country.name
            country = @props.countries.find((c) -> c.name is countryName)
            if country?
                actions = [
                    CityActions.backupCities()
                    CityActions.resetPrevItems()
                    CityActions.resetNextItems()
                    CityActions.setNoMoreCities(false)
                    CityActions.setCountry(country)
                ]
                if not @props.countryBackup[country.name]?
                    actions = [
                        actions...
                        CityActions.setCitiesLoading()
                        @fetchCities(country: country.code, returnAction: true)
                    ]
                else
                    actions.push(CityActions.restoreCities(country.name))
                @props.batchActions(actions)

    dislike: (city, { returnActions = false }) ->
        actions = [CityActions.dislikeCity(city)]
        if @props.prevItems.length is 0 and @props.nextItems.length is 0
            actions.push(@fetchCities(limit: 1, returnAction: true, replace: 'loading'))
        if returnActions
            return actions
        else
            @props.batchActions(actions)


    render: ->
        <div className='fill-window flex-center'>
            <div id='cities-container' className='
                d-flex flex-column
                justify-content-around
                justify-content-lg-center
                align-items-center w-100 content'>
                <h1 className="card-heading">The Sound of Cities</h1>
                <CountryDropdown
                    country={ @props.country }
                    countries={ @props.countries }
                    onClick={ (country) => @onDropdownClick(country) }>
                </CountryDropdown>
                <CardView
                    removeDislike={ @props.removeDislike }
                    dislikedItems={ @props.dislikedCities }
                    items={ @props.cities }
                    cardWidth={ config.MAX_CARD_SIZE }
                    cardHeight={ config.MAX_CARD_SIZE }
                    borderRadius={ config.CARD_RADIUS }
                    overlayColor={ config.CARD_OVERLAY_COLOR }
                    showDislikeButton={ true }
                    showPreviousButton={ @props.prevItems.length > 0 }
                    showNextButton={ @props.nextItems.length > 0 }
                    onClick={ (city, i) => @onCityClick(city, i) }
                    dislike={ (city, params) => @dislike(city, params) }
                    onPreviousClick={ () => @props.previousCities() }
                    onNextClick={ () => @props.nextCities() }
                    loading={ @props.fetching }
                    itemName='city'>
                </CardView>
                <div className='bottom-buttons'>
                    <MoreButton
                        loading={ @props.fetching }
                        noMoreData={ @props.noMoreCities }
                        itemsName='Cities'
                        onClick={ () => @fetchCities() }>
                    </MoreButton>
                </div>
            </div>
            <style global jsx>{"""#{} // stylus
                body
                    overflow-x hidden
            """}</style>
            <style jsx>{"""#{} // stylus
                #cities-container
                    margin-top navbarHeightDesktop
                    @media(max-width: $mobile)
                        margin-top navbarHeightMobile + 20px

                .card-heading
                    color white
                    text-align center
                    margin-bottom 0

                .content
                    margin 2rem auto 100px

                    @media (min-width: #{ config.WIDTH.medium }px)
                            margin-top 5rem
                            margin-bottom 2rem

                .bottom-buttons
                    @media (max-width: #{ config.WIDTH.medium }px)
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
    selectedCity: state.cities.present.selectedCity
    allCities: state.cities.present.allCities
    cities: state.cities.present.cities
    fetching: state.cities.present.fetching
    prevItems: state.cities.present.prevItems
    nextItems: state.cities.present.nextItems
    noMoreCities: state.cities.present.noMoreCities
    user: state.spotify.user
    country: state.cities.present.country
    countries: state.cities.present.countries
    countryBackup: state.cities.present.backup
    dislikedCities: state.cities.present.dislikedCities

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    nextCities: () -> dispatch(CityActions.nextCities())
    previousCities: () -> dispatch(CityActions.previousCities())
    fetchCities: (country, ignore, limit, imageWidth, imageHeight, replace) ->
        dispatch(
            CityActions.fetchCities(
                country, ignore, limit, imageWidth, imageHeight, replace
            )
        )
    finishFetchingCities: () -> dispatch(CityActions.finishFetchingCities())
    setCities: (cities) -> dispatch(CityActions.setCities(cities))
    getUserDetails: () -> dispatch(SpotifyActions.getUserDetails())
    dislikeCity: (city) -> dispatch(CityActions.dislikeCity(city))
    setCitiesLoading: () -> dispatch(CityActions.setCitiesLoading())
    setCountry: (country, skipUpdate) ->
        dispatch(CityActions.setCountry(country, skipUpdate))
    setCountries: (countries) -> dispatch(CityActions.setCountries(countries))
    setNoMoreCities: (noMore) -> dispatch(CityActions.setNoMoreCities(noMore))
    resetPrevItems: () -> dispatch(CityActions.resetPrevItems())
    resetNextItems: () -> dispatch(CityActions.resetNextItems())
    backup: () -> dispatch(CityActions.backupCities())
    restore: (country) -> dispatch(CityActions.restoreCities(country))
    removeDislike: (item) -> dispatch(UserActions.removeDislike('cities', item))

export default connect(mapStateToProps, mapDispatchToProps)(Cities)
