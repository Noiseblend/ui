import React from 'react'
import { connect } from 'react-redux'

import _ from 'lodash'

import DislikeListViewDesktop from '~/components/dislikeListViewDesktop'
import DislikeListViewMobile from '~/components/dislikeListViewMobile'
import ImageBackground from '~/components/imageBackground'
import UserHeader from '~/components/userHeader'

import SpotifyActions from '~/redux/spotify'
import UIActions from '~/redux/ui'
import UserActions from '~/redux/user'

import colors from '~/styles/colors'

import config from '~/config'

DEFAULT_TAB = 'artists'

class User extends React.Component
    constructor: (props) ->
        super props
        @state =
            activeTab: DEFAULT_TAB

    @getInitialProps: ({ store, query, res, req, isServer, authenticated, user, api }) ->
        if store.getState().user?.fetchedDislikes
            await return

        dislikeRes = await api.fetchDislikes('all')
        if not dislikeRes.ok
            await return { error: dislikeRes }

        await return {
            dislikes: dislikeRes.data
        }

    componentDidMount: ->
        if @props.fetchedDislikes
            return

        actions = (
            UserActions.setDislikes(
                key, @props.dislikes[key]
            ) for key of @props.dislikes
        )
        actions = [
            actions...
            UserActions.finishFetchingDislikes()
        ]
        @props.batchActions(actions)

    username: ->
        if @props.user?.displayName?.length > 0
            @props.user.displayName
        else
            @props.user?.username

    render: ->
        activeTab = @state?.activeTab ? DEFAULT_TAB
        dislikes =
            artists: @props.dislikedArtists
            genres: @props.dislikedGenres
            countries: @props.dislikedCountries
            cities: @props.dislikedCities
        userImage = @props.user?.images?[0]?.url
        imageProps = if @props.mobile
            {
                overlayColor: colors.PEACH.alpha(0.8).rgb().string()
                blur: 20
                imageStyle:
                    top: '-50%'
            }
        else
            {
                overlayGradient: "
                    linear-gradient(
                        to bottom,
                        #{ config.USER_BACKGROUND },
                        #{ config.DEFAULT_IMAGE_OVERLAY })"
                blur: 40
            }

        <div className='fill-window-exact'>
            <ImageBackground
                fillWindow
                loading={ @props.fetching }
                background={ src: userImage }
                { imageProps... }>
                <div className='
                    d-flex flex-column
                    justify-content-between
                    align-items-center h-100'>
                    <UserHeader height={ 20 } mobile={ @props.mobile } user={ @props.user } />
                    {if not @props.mobile
                        <hr
                            className='m-0'
                            style={
                                backgroundColor: colors.WHITE.alpha(0.3),
                                width: '100vw' } />}
                    {if not @props.mobile
                        <DislikeListViewDesktop
                            fetching={ @props.fetching }
                            removeDislike={
                                (itemType, item) =>
                                    @props.removeDislike(itemType, item)
                            }
                            dislikes={ dislikes }
                        />
                    else
                        <DislikeListViewMobile
                            fetching={ @props.fetching }
                            removeDislike={
                                (itemType, item) =>
                                    @props.removeDislike(itemType, item)
                            }
                            dislikes={ dislikes }
                            activeTab={ activeTab }
                            activateTab={ (tab) => @setState activeTab: tab }
                        />
                    }
                </div>
            </ImageBackground>
        </div>


mapStateToProps = (state) ->
    user: state.spotify.user
    mobile: state.ui.mobile
    fetching: state.user.fetching
    fetchedDislikes: state.user.fetchedDislikes
    dislikedArtists: state.user.dislikedArtists
    dislikedGenres: state.user.dislikedGenres
    dislikedCities: state.user.dislikedCities
    dislikedCountries: state.user.dislikedCountries

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    setUser: (user) -> dispatch(SpotifyActions.setUser(user))
    setDislikes: (key, items) -> dispatch(UserActions.setDislikes(key, items))
    finishFetchingDislikes: () -> dispatch(UserActions.finishFetchingDislikes())
    getUserDetails: () -> dispatch(SpotifyActions.getUserDetails())
    setErrorMessage: (error) -> dispatch(SpotifyActions.setErrorMessage(error))
    removeDislike: (key, item) -> dispatch(UserActions.removeDislike(key, item))


export default connect(mapStateToProps, mapDispatchToProps)(User)
