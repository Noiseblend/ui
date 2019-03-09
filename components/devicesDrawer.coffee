import '~/styles/fontawesome'
import React from 'react'
import { connect } from 'react-redux'

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'

import _ from 'lodash'

import CloseButton from '~/components/closeButton'
import DeviceItem from '~/components/deviceItem'
import LoadingDots from '~/components/loadingDots'
import RoundedButton from '~/components/roundedButton'
import VolumeFadeDrawer from '~/components/volumeFadeDrawer'

import PlayerActions from '~/redux/player'
import SpotifyActions from '~/redux/spotify'

import colors from '~/styles/colors'

import config from '~/config'

OpenSpotifyButton = ({ uri, onClick }) ->
    uri ?= 'spotify:search:Wait 5-10 seconds for playback'
    <a
        key={ 4 }
        className='d-block w-100 mt-5 text-center'
        href={ uri }>
        <RoundedButton
            className='flex-center mx-auto'
            hoverTextColor={ colors.FLASH_WHITE }
            textColor={ colors.FLASH_WHITE }
            onClick={ onClick }
            color={ colors.GREEN }>
            <FontAwesomeIcon
                className='mr-2'
                style={
                    fontSize: '1.3rem'
                }
                icon={ ['fab', 'spotify'] } />
            Open in Spotify
        </RoundedButton>
    </a>


DevicesDrawer = ({ playUri, props... }) ->
    hasDevices = props.devices?.length > 0
    <div
        style={{
            height: '120vh'
            width: '100vw'
            backgroundColor: colors.PITCH_BLACK
            position: 'relative'
            props.style...
        }}
        className='devices-drawer'>
        <CloseButton
            id='close-device-drawer-button'
            style={ position: 'absolute' }
            onClose={ props.close }
            color={ colors.RED }
        />
        <div
            style={
                overflowY: 'scroll'
                height: '100vh'
            }
            className='d-flex flex-column devices-container'>
            <div className='m-auto'>
                { if hasDevices
                    <h2 className='text-light text-center mt-5'>
                        Devices
                    </h2>
                else
                    [
                        <h2 className='text-light text-center' key={ 1 }>
                            Open Spotify on one of your devices to see it here
                        </h2>
                        <p
                            id='waiting-devices-text'
                            className='text-light text-center mt-5'
                            key={ 2 }>
                            Waiting for Spotify Connect devices
                        </p>
                        <LoadingDots key={ 3 } color={ colors.YELLOW } className='mx-auto' />
                        <OpenSpotifyButton
                            key='open-spotify-button'
                            uri={ playUri }
                            onClick={ props.playOn } />
                    ] }
                {if hasDevices
                    [
                        <div
                            key={ 1 }
                            style={
                                width: '60vw'
                                minWidth: '300px'
                            }
                            className='
                                my-5 d-flex flex-column
                                flex-lg-row flex-lg-wrap
                                justify-content-center
                                align-items-center'>
                            { props.devices.map((device, i) ->
                                <DeviceItem
                                    className='mx-lg-3 p-3'
                                    device={ device }
                                    key={ device.id }
                                    onPlay={ (device) -> props.playOn(device) }
                                />) }
                        </div>
                        <OpenSpotifyButton
                            key='open-spotify-button'
                            uri={ playUri }
                            onClick={ props.playOn } />
                        <VolumeFadeDrawer key={ 2 } className='mb-5' />
                    ]
                }
            </div>
        </div>
        <style global jsx>{"""#{} // stylus
            .devices-drawer
                @media(max-width: $mobile)
                    -webkit-overflow-scrolling touch
                &::-webkit-scrollbar
                    display none
            body
                overflow: #{ if props.isDrawerOpen then 'hidden' else 'initial' }
        """}</style>
        <style jsx>{"""#{} // stylus
            .devices-container
                -webkit-overflow-scrolling: touch
            #waiting-devices-text
                font-size 1.5rem
        """}</style>
    </div>


mapStateToProps = (state) ->
    isDrawerOpen: state.ui.isDrawerOpen
    devices: state.player.devices
    playUri: (
        state.playlists.present.playlist?.uri ?
        state.playlists.present.playlist.tracks.items[0]?.track?.uri)

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)


export default connect(mapStateToProps, mapDispatchToProps)(DevicesDrawer)
