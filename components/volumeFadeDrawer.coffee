import { connect } from 'react-redux'

import NativeSlider from '~/components/nativeSlider'
import ToggleButton from '~/components/toggleButton'
import ToggleTextButton from '~/components/toggleTextButton'

import PlayerActions from '~/redux/player'

import colors from '~/styles/colors'

import config from '~/config'


CONTAINER_SIZE = 300
SLIDER_WIDTH = 250
SLIDER_HEIGHT = 8
THUMB_SIZE = 24

setVolumeRange = (range, props) ->
    props.setStartVolume(range[0])
    props.setStopVolume(range[1])


VolumeFadeDrawer = (props) ->
    <div className="
        d-flex flex-column mt-4
        justify-content-center
        align-items-center
        #{ props.className ? '' }">
        <ToggleButton
            className='mb-3 fade-button'
            color={ colors.YELLOW }
            textColor={ colors.WHITE }
            width={ 170 }
            onClick={ props.toggleFade }
            toggled={ props.fadeEnabled }
            style={
                minHeight: '52px'
            }>
            Volume fade
        </ToggleButton>
        <div
            style={
                minHeight: if props.fadeEnabled then CONTAINER_SIZE else 0
                maxHeight: if props.fadeEnabled then CONTAINER_SIZE else 0
                transition: '
                    min-height 0.7s easeOutExpo,
                    max-height 0.7s easeOutExpo'
                overflow: 'hidden'
            }>
            <div
                style={
                    minHeight: CONTAINER_SIZE
                    minWidth: CONTAINER_SIZE
                }
                className='
                    d-flex flex-column
                    justify-content-around
                    align-items-center
                    volume-fade-container'>
                <div className='
                    d-flex
                    flex-column
                    justify-content-center
                    align-items-center
                    fade-directions'>
                    <ToggleTextButton
                        shadow
                        style={
                            fontSize: '2rem'
                        }
                        onColor={ colors.MAGENTA }
                        offColor={ colors.DARK_GRAY }
                        toggled={ props.fadeDirection is 1 }
                        onClick={ () -> props.setFadeDirection(1) }
                        >
                        UP
                    </ToggleTextButton>
                    <ToggleTextButton
                        shadow
                        style={
                            fontSize: '2rem'
                        }
                        onColor={ colors.MAGENTA }
                        offColor={ colors.DARK_GRAY }
                        toggled={ props.fadeDirection is -1 }
                        onClick={ () -> props.setFadeDirection(-1) }
                        >
                        DOWN
                    </ToggleTextButton>
                </div>
                <div className='volume-slider' style={
                    width: SLIDER_WIDTH
                }>
                    <h6 className='text-center text-light mb-4'>Volume Range</h6>
                    <NativeSlider
                        value={ [
                            props.startVolume ? config.DEFAULTS.FADE_VOLUME_MIN
                            props.stopVolume ? config.DEFAULTS.FADE_VOLUME_MAX
                        ] }
                        min={ 0 }
                        max={ 100 }
                        step={ 1 }
                        reversed={ props.fadeDirection is -1 }
                        showMarks showTooltip hideReset range
                        trackWidth={ SLIDER_WIDTH }
                        trackHeight={ SLIDER_HEIGHT }
                        thumbSize={ THUMB_SIZE }
                        trackColor={ colors.DARK_GRAY }
                        trackFillColor={ colors.MAGENTA.mix(colors.RED).desaturate(0.1) }
                        tooltipProps={
                            theme: 'light'
                        }
                        modified={ props.fadeTimeMinutes isnt config.DEFAULTS.FADE_MINUTES }
                        onChange={ (range) -> setVolumeRange(range, props) } />
                </div>
                <div className='mb-2 duration-slider' style={
                    width: SLIDER_WIDTH
                }>
                    <h6 className='text-center text-light mb-4'>
                        Duration (minutes)
                    </h6>
                    <NativeSlider
                        value={ props.fadeTimeMinutes }
                        min={ config.DEFAULTS.FADE_MIN }
                        max={ config.DEFAULTS.FADE_MAX }
                        step={ 1 }
                        showMarks showTooltip hideReset
                        trackWidth={ SLIDER_WIDTH }
                        trackHeight={ SLIDER_HEIGHT }
                        thumbSize={ THUMB_SIZE }
                        trackColor={ colors.DARK_GRAY }
                        trackFillColor={ colors.MAGENTA.mix(colors.RED).desaturate(0.1) }
                        tooltipProps={
                            theme: 'light'
                        }
                        modified={ props.fadeTimeMinutes isnt config.DEFAULTS.FADE_MINUTES }
                        onChange={ props.setFadeTimeMinutes } />
                </div>
            </div>
        </div>
    </div>

mapStateToProps = (state) ->
    startVolume: state.player.startVolume
    stopVolume: state.player.stopVolume
    fadeDirection: state.player.fadeDirection
    fadeTimeMinutes: state.player.fadeTimeMinutes
    fadeEnabled: state.player.fadeEnabled

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    setFadeTimeMinutes: (fadeTimeMinutes) ->
        dispatch(PlayerActions.setFadeTimeMinutes(fadeTimeMinutes))
    setFadeDirection: (fadeDirection) ->
        dispatch(PlayerActions.setFadeDirection(fadeDirection))
    setStartVolume: (startVolume) -> dispatch(PlayerActions.setStartVolume(startVolume))
    setStopVolume: (stopVolume) -> dispatch(PlayerActions.setStopVolume(stopVolume))
    toggleFade: () -> dispatch(PlayerActions.toggleFade())
    fade: (stopVolume, startVolume, fadeDirection, fadeTimeMinutes, device) ->
        dispatch(
            PlayerActions.fade(
                stopVolume, startVolume, fadeDirection, fadeTimeMinutes, device
            )
        )

export default connect(mapStateToProps, mapDispatchToProps)(VolumeFadeDrawer)
