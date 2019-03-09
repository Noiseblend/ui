import React from 'react'
import { connect } from 'react-redux'

import DiscoverItem from '~/components/discoverItem'

import { any, anyObj } from '~/lib/util'

import SpotifyActions from '~/redux/spotify'

import colors from '~/styles/colors'

import config from '~/config'


Discover = (props) ->
    <div
        className='fill-window'
        style={
            overflowX: 'hidden'
            overflowY: 'scroll'
        }>
        <div className='d-flex flex-column flex-lg-row w-100 parts-container'>
            <DiscoverItem
                className='discover-section'
                id='discover-artists'
                href='/artists'
                imageTopic='artist'
                color={ colors.DARK_MAUVE }
                headlineHoverColor={ colors.GRAY_BLUE }
                descriptionHoverColor={ colors.GRAY_BLUE }
                headline='Artist'
                mobileLayout={ props.mediumScreen }
                description='Craft your own playlists by choosing
                             from your most listened artists'
            />
            <DiscoverItem
                className='discover-section'
                id='discover-genres'
                href='/genres'
                imageTopic='genre'
                color={ colors.SEPIA }
                headline='Genre'
                description='Listen to a personalized list of eclectically named genres'
            />
            <DiscoverItem
                className='discover-section'
                id='discover-countries'
                href='/countries'
                imageTopic='country'
                color={ colors.MARS_RED }
                headlineHoverColor={ colors.PEACH }
                descriptionHoverColor={ colors.PEACH.darken(0.7) }
                headline='Country'
                description='See what people from other parts
                             of the world are listening to'
            />
            <DiscoverItem
                className='discover-section'
                id='discover-cities'
                href='/cities'
                imageTopic='city'
                color={ colors.CALM_BLUE }
                headline='City'
                description='Peek into the listening habits of your fellow countrymen'
            />
        </div>
    </div>

mapStateToProps = ({ spotify, ui }) ->
    user       : spotify.user
    mediumScreen: ui.mediumScreen

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    getUserDetails: () -> dispatch(SpotifyActions.getUserDetails())

export default connect(mapStateToProps, mapDispatchToProps)(Discover)
