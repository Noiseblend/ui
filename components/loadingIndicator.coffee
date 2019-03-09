import React from 'react'
import FlipMove from 'react-flip-move'

import _ from 'lodash'

import colors from '~/styles/colors'

import config from '~/config'

import Equalizer from './equalizer'

class LoadingIndicator extends React.PureComponent
    constructor: (props) ->
        super props
        @loadingTexts = _.shuffle(props.loadingTexts ? config.LOADING_TEXTS)
        @textChanger = null
        @state =
            text: @loadingTexts[0]

    changeText: ->
        text = @loadingTexts.shift()
        @loadingTexts.push(text)
        @setState(text: text)

    componentWillUnmount: ->
        if @textChanger?
            clearInterval(@textChanger)
            @textChanger = null

    componentDidMount: ->
        @textChanger = setInterval((() => @changeText()), 2000)

    render: ->
        <div
            className="
                flex-column-center
                loading-indicator
                #{ @props.className ? '' }"
            style={ @props.style }>
            <Equalizer
                speed={ @props.speed ? 0.7 }
                style={ width: '60px', height: '20px' }
                color={ @props.eqColor } />
            <FlipMove
                duration={ 300 }
                staggerDelayBy={ 150 }
                enterAnimation={
                    from:
                        transform: 'rotateX(180deg)'
                        opacity: 0.1
                    to:
                        transform: ''
                }
                leaveAnimation={
                    from:
                        transform: ''
                    to:
                        transform: 'rotateX(-120deg)'
                        opacity: 0.1
                }
                easing='ease-out'>
                <p key={ @state.text } className='text-center mt-2 loading-text'>
                    { @state.text }
                </p>
            </FlipMove>
            <style jsx>{"""#{} // stylus
                @keyframes fadein-indicator
                    from
                        opacity 0

                    to
                        opacity 1

                .loading-indicator
                    animation 1.5s easeOutCubic fadein-indicator

                .loading-text
                    color #{ @props.textColor ? colors.WHITE } !important
                    width 300px
                    min-width 300px
            """}</style>
        </div>

export default LoadingIndicator
