import React from 'react'
import { Tooltip } from 'react-tippy'

import _ from 'lodash'

import RoundedButton from '~/components/roundedButton'

import { classif } from '~/lib/util'

import colors from '~/styles/colors'

DEFAULT_TRACK_WIDTH = 250

# coffeelint: disable=max_line_length
Slider = ({
    value, modified, onChange,
    trackColor = colors.MAUVE, trackFillColor = colors.YELLOW, thumbColor,
    markColor = colors.DARK_GRAY, trackHeight = 6, trackWidth = DEFAULT_TRACK_WIDTH,
    thumbSize = 20, thumbRadius, thumbInner, thumbInnerColor = colors.WHITE,
    trackRadius, lowerLimit, upperLimit, containerStyle, props...
}) ->
    thumbRadius ?= Math.round(thumbSize / 2)
    thumbInner ?= Math.round(thumbSize * 0.7)
    trackRadius ?= Math.round(trackHeight / 2)
    <div style={{
        width: trackWidth
        height: trackHeight * 3
        containerStyle...
    }}>
        <input
            type='range'
            className="#{ classif(modified, 'modified') }"
            value={ value }
            onChange={ (e) ->
                if (not lowerLimit? and not upperLimit?) or
                (lowerLimit? and e.target.value > lowerLimit) or
                (upperLimit? and e.target.value < upperLimit)
                    onChange(e.target.value)
            }
            { props... } />
        <style jsx>{"""#{} // stylus
            $thumb-shadow-size ?= 0
            $thumb-shadow-blur ?= 0
            $thumb-shadow-color ?= transparent
            $thumb-border-width ?= 0px
            $thumb-border-color ?= transparent

            $track-shadow-size ?= 0
            $track-shadow-blur ?= 0
            $track-shadow-color ?= transparent
            $track-border-width ?= 0px
            $track-border-color ?= transparent

            shadow($shadow-size, $shadow-blur, $shadow-color)
                box-shadow $shadow-size $shadow-size $shadow-blur $shadow-color, 0 0 $shadow-size lighten($shadow-color, 5%)

            track()
                height #{ trackHeight }px
                width #{ trackWidth }px
                cursor pointer
                transition all .2s ease

            thumb()
                shadow($thumb-shadow-size, $thumb-shadow-blur, $thumb-shadow-color)
                border-radius 100px
                background #{ thumbInnerColor }
                border $track-border-width solid $track-border-color
                box-shadow inset 0 0 0 #{ (thumbSize - thumbInner) / 2 }px #{ thumbColor ? trackColor }
                cursor pointer
                height #{ thumbSize }px
                width #{ thumbSize }px
                pointer-events all

            input[type='range']
                appearance none
                margin 0
                width #{ trackWidth }px
                height #{ thumbSize }px
                background none

                &[disabled]
                    filter grayscale(80%) !important
                    cursor auto !important

                &.modified
                    &::-webkit-slider-runnable-track
                        background #{ trackFillColor }
                    &::-webkit-slider-thumb
                    &::-moz-range-thumb
                    &::-ms-thumb
                        box-shadow inset 0 0 0 #{ (thumbSize - thumbInner) / 2 }px #{ thumbColor ? trackFillColor } !important

                &:focus
                    outline 0

                    &::-webkit-slider-runnable-track
                        background #{ trackFillColor }
                    &::-webkit-slider-thumb
                    &::-moz-range-thumb
                    &::-ms-thumb
                        box-shadow inset 0 0 0 #{ (thumbSize - thumbInner) / 2 }px #{ thumbColor ? trackFillColor } !important

                &::-ms-fill-lower
                    background #{ trackColor }

                &::-ms-fill-upper
                    background #{ trackColor }

                &::-webkit-slider-runnable-track
                    track()
                    shadow($track-shadow-size, $track-shadow-blur, $track-shadow-color)
                    background #{ trackColor }
                    border $track-border-width solid $track-border-color
                    border-radius 100px

                &::-webkit-slider-thumb
                    thumb()
                    appearance none
                    margin-top #{ trackHeight / 2 - thumbSize / 2 }px

                &::-moz-range-track
                    track()
                    shadow($track-shadow-size, $track-shadow-blur, $track-shadow-color)
                    background #{ trackColor }
                    border $track-border-width solid $track-border-color
                    border-radius 100px

                &::-moz-range-thumb
                    thumb()

                &::-ms-track
                    track()
                    background transparent
                    border-color transparent
                    border-width #{ thumbSize / 2 }px 0
                    color transparent

                &::-ms-fill-lower
                    shadow($track-shadow-size, $track-shadow-blur, $track-shadow-color)
                    background #{ trackColor }
                    border $track-border-width solid $track-border-color
                    border-radius 100px

                &::-ms-fill-upper
                    shadow($track-shadow-size, $track-shadow-blur, $track-shadow-color)
                    background #{ trackColor }
                    border $track-border-width solid $track-border-color
                    border-radius 100px

                &::-ms-thumb
                    thumb()
                    margin-top 0
        """}</style>
    </div>


SingleSlider = ({
    showTooltip, disabled, modified, tooltipProps, onChange,
    value, props...
}) ->
    <Tooltip
        disabled={ not showTooltip or disabled }
        trigger='mouseenter'
        touchHold={ true }
        position='left'
        size='regular'
        title={ value }
        { tooltipProps... }>
        <Slider
            value={ value }
            disabled={ disabled }
            modified={ modified }
            onChange={ onChange }
            { props... } />
    </Tooltip>


RangeSlider = ({
    showTooltip, disabled, modified, tooltipProps, onChange,
    value, reversed, props...
}) ->
    <div className='w-100' style={
        height: props.trackHeight * 3
        position: 'relative'
        direction: 'rtl' if reversed
    }>
        <Tooltip
            disabled={ not showTooltip or disabled }
            trigger='mouseenter focus'
            touchHold={ true }
            position={ 'left' }
            size='regular'
            title={ value[0] }
            { tooltipProps... }>
            <Slider
                value={ value[0] }
                upperLimit={ value[1] }
                disabled={ disabled }
                modified={ modified }
                onChange={ (val) -> onChange([val, value[1]]) }
                containerStyle={
                    pointerEvents: 'none'
                }
                style={
                    pointerEvents: 'none'
                    position: 'absolute'
                    top: 0
                    left: 0
                }
                { props... }
                thumbColor={ props.thumbColor ? props.trackColor }
                trackColor={ props.trackFillColor ? props.trackColor } />
        </Tooltip>
        <Tooltip
            disabled={ not showTooltip or disabled }
            trigger='mouseenter focus'
            touchHold={ true }
            position={ 'left' }
            size='regular'
            offset={ -props.trackHeight * 3 }
            title={ value[1] }
            { tooltipProps... }>
            <Slider
                value={ value[1] }
                lowerLimit={ value[0] }
                disabled={ disabled }
                modified={ modified }
                onChange={ (val) -> onChange([value[0], val]) }
                containerStyle={
                    pointerEvents: 'none'
                }
                style={
                    pointerEvents: 'none'
                    position: 'absolute'
                    top: 0
                    left: 0
                }
                { props... }
                thumbColor={ props.thumbColor ? props.trackColor }
                trackColor={ colors.BLACK.alpha(0) }
                trackFillColor={ colors.BLACK.alpha(0) }
            />
        </Tooltip>
    </div>


class NativeSlider extends React.Component
    constructor: (props) ->
        super props
        @state =
            initialValue: props.value
            value: props.value
        @onChangeDeferred = null
        if props.onChange?
            @onChangeDeferred = _.debounce(props.onChange, props.defer ? 500)

    componentDidUpdate: (prevProps, prevState, snapshot) ->
        if prevProps.onChange isnt @props.onChange or
        prevProps.defer isnt @props.defer
            if @props.onChange?
                @onChangeDeferred = _.debounce(@props.onChange, @props.defer ? 500)
            else
                @onChangeDeferred = null
        if @props.value isnt prevProps.value and
        @props.value isnt @state.value
            @setState
                value: @props.value
                initialValue: @state.initialValue ? @props.value

    setValue: (value) ->
        @setState({ value })
        @onChangeDeferred?(value)

    render: ->
        {
            onChange, value, modified, showMarks, markStyle,
            hideReset, range, disabled, resetColor = colors.GRAY_MAUVE, props...
        } = @props

        markStyle ?=
            fontSize: 12

        <div
            style={
                width: props.trackWidth ? DEFAULT_TRACK_WIDTH
            }
            className='flex-column-center slider-container'>
            {if range
                if props.reversed
                    <RangeSlider
                        reversed={ true }
                        disabled={ disabled }
                        modified={ modified }
                        value={ @state.value }
                        onChange={ (value) => @setValue(value) }
                        { props... }
                    />
                else
                    <RangeSlider
                        disabled={ disabled }
                        modified={ modified }
                        value={ @state.value }
                        onChange={ (value) => @setValue(value) }
                        { props... }
                    />
            else
                <SingleSlider
                    disabled={ disabled }
                    modified={ modified }
                    value={ @state.value }
                    onChange={ (value) => @setValue(value) }
                    { props... }
                />
            }
            {if showMarks
                <div className='flex-center w-100 justify-content-between'>
                    <span style={ markStyle } className='font-heading mx-2'>
                        { if not props.reversed then props.min else props.max }
                    </span>
                    <span style={ markStyle } className='font-heading mx-2'>
                        { if not props.reversed then props.max else props.min }
                    </span>
                </div>
            }
            {if modified and not hideReset
                <RoundedButton
                    className='p-1'
                    disabled={ not modified or disabled }
                    color={ resetColor ? props.thumbColor ? props.trackColor }
                    onClick={ () => @setValue(@state.initialValue) }
                    style={
                        marginTop: 12 if not showMarks
                        minWidth: 60
                        maxWidth: 60
                        fontSize: 13
                    }>
                    Reset
                </RoundedButton>
            }
        </div>

export default NativeSlider
