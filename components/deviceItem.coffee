import React from 'react'
import { connect } from 'react-redux'

import Card from '~/components/card'
import TextButton from '~/components/textButton'

import PlayerActions from '~/redux/player'

import colors from '~/styles/colors'
import { PauseCircle, PlayCircle, SkipBack, SkipForward } from '~/styles/icons'
import {
    HardDrive,
    Headphones,
    Monitor,
    Smartphone,
    Speaker,
    Tablet,
    Truck,
    Tv,
    Volume1
} from '~/styles/icons'

import config from '~/config'

SIZE = 200

deviceIconProps = (device, active, size) ->
    className = "device-icon #{ device }-device-icon"
    color = (if active then colors.YELLOW else colors.WHITE).rgb().string()
    darkGray = colors.DARK_GRAY.rgb().string()
    yellow = colors.YELLOW.rgb().string()
    lightBlack = colors.BLACK.lighten(0.1).rgb().string()
    switch device
        when 'Computer'
            className: className
            strokeWidth: 1
            color: color
            size: size
        when 'Speaker'
            className: className
            color: 'black'
            fill: color
            size: size
        when 'TV'
            className: className
            color: color
            size: size
        when 'Smartphone'
            className: className
            color: 'black'
            fill: color
            size: size
        when 'Tablet'
            className: className
            color: 'black'
            fill: color
            size: size
        when 'Car'
            className: className
            color: lightBlack
            fill: color
            size: size
        when 'Console'
            className: className
            color: 'black'
            fill: color
            size: size
        else
            className: className
            color: color
            size: size

deviceIcon = (device, active, size) ->
    className = "device-icon #{ device }-device-icon"
    color = (if active then colors.GREEN else colors.WHITE).rgb().string()
    darkGray = colors.DARK_GRAY.rgb().string()
    yellow = colors.YELLOW.rgb().string()
    lightBlack = colors.BLACK.lighten(0.1).rgb().string()
    switch device
        when 'Computer' then Monitor
        when 'Speaker' then Speaker
        when 'TV' then Tv
        when 'Smartphone' then Smartphone
        when 'Tablet' then Tablet
        when 'Car' then Truck
        when 'Console' then HardDrive
        else Headphones

TrackTitle = ({ device, playback }) ->
    <div
        className='d-flex justify-content-start my-1 align-items-center'
        style={
            color: colors.WHITE
            fontSize: '0.7rem'
            maxWidth: '65%'
        }>
        { if device.isPlaying
            <img
                className='eq-anim'
                width={ 20 }
                height={ 12 }
                src="#{ config.STATIC }/img/equalizer.gif" />
        }
        <span className='text-truncate track-name'>
            { if device.id is playback?.device.id
                playback?.item?.name
            else
                '\u00a0'}
        </span>
    </div>


DeviceItem = (props) ->
    buttonColor =  if props.device.isActive
        colors.PEACH.lighten(0.1)
    else
        colors.WHITE

    <div className="device-item-container">
        <Card
            backgroundColor={ colors.BLACK.alpha(0) }
            size={ 200 }
            color={ colors.YELLOW }
            style={{
                cursor: 'auto'
                props.style...
            }}
            className="
                font-heading device-button
                #{ props.className ? '' }"
            iconProps={ deviceIconProps(props.device.type, props.device.isActive, 90) }
            icon={ deviceIcon(props.device.type, props.device.isActive, 90) }
            title={ props.device.name }
        >
            <TrackTitle device={ props.device } playback={ props.playback } />
            <div
                className='d-flex justify-content-center align-items-center device-volume'
                style={
                    position: 'absolute'
                    top: -10
                    right: -6
                    fontSize: '0.7rem'
                    fontWeight: 'bold'
                }>
                <Volume1 size={ 15 } />
                { props.device.volumePercent }
            </div>
        </Card>
        <div className='
            d-flex mt-2
            align-items-center
            justify-content-center
            device-controls'>
            <TextButton
                color={ buttonColor }
                width='40px'
                className="previous-button mx-2"
                disabled={ props.device.isRestricted or not props.device.isPlaying }
                onClick={ () -> props.previousTrack(props.device) }>
                <SkipBack size={ 30 } />
            </TextButton>
            <TextButton
                className='mx-2'
                color={ buttonColor }
                onClick={ () ->
                    if not props.device.isPlaying
                        props.onPlay(props.device)
                    else
                        props.pause(props.device)
                }>
                { if props.device.isPlaying
                    <PauseCircle size={ 50 } />
                else
                    <PlayCircle size={ 50 } />
                }
            </TextButton>
            <TextButton
                className='mx-2'
                onClick={ () -> props.nextTrack(props.device) }
                disabled={ props.device.isRestricted or not props.device.isPlaying }
                color={ buttonColor }>
                <SkipForward size={ 30 } />
            </TextButton>
        </div>

        <style global jsx>{"""#{} // stylus
            .device-item-container
                .button-content
                    overflow visible !important

                &:hover
                &:focus
                    .device-button
                        glow 30px alpha(yellow, 0.7)

                .device-button
                    .card-title
                        overflow-wrap break-word

                    .device-volume
                    .track-name
                        color lightGray !important
                        stroke lightGray !important
                        ease-out color stroke

                    &:hover
                    &:focus
                        .device-volume
                        .track-name
                            color darkGray !important
                            stroke darkGray !important

                        .eq-anim
                            ease-out 0.3s 'opacity'
                            opacity 0

                        .device-icon
                            ease-out 0.3s stroke fill

                        .Speaker-device-icon
                        .Console-device-icon
                        .Smartphone-device-icon
                        .Tablet-device-icon
                            stroke yellow
                            fill white

                        .Computer-device-icon
                        .Car-device-icon
                            stroke white
                            fill none
        """}</style>
    </div>

mapStateToProps = (state) ->
    playback: state.player.playback

mapDispatchToProps = (dispatch) ->
    pause: (device) -> dispatch(PlayerActions.pause(device))
    nextTrack: (device) -> dispatch(PlayerActions.nextTrack(device))
    previousTrack: (device) -> dispatch(PlayerActions.previousTrack(device))

export default connect(mapStateToProps, mapDispatchToProps)(DeviceItem)
