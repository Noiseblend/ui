import React from 'react'

import colors from '~/styles/colors'


Equalizer = ({ className, style, color = colors.WHITE, speed = 1, props... }) ->
    eqStyle = (speedFactor) ->
        backgroundColor: color
        animationDuration: "#{ speedFactor / speed }s"

    <div
        className="
            d-flex flex-row
            justify-content-between
            align-items-end eq
            #{ className ? '' }"
        style={{ style... }}>
        <div className='eq-col'>
           <div style={ eqStyle(0.3) } className='eq-1-1'></div>
           <div style={ eqStyle(0.45) } className='eq-1-2'></div>
        </div>
        <div className='eq-col'>
           <div style={ eqStyle(0.5) } className='eq-2-1'></div>
           <div style={ eqStyle(0.4) } className='eq-2-2'></div>
        </div>
        <div className='eq-col'>
           <div style={ eqStyle(0.3) } className='eq-3-1'></div>
           <div style={ eqStyle(0.35) } className='eq-3-2'></div>
        </div>
        <div className='eq-col'>
           <div style={ eqStyle(0.4) } className='eq-4-1'></div>
           <div style={ eqStyle(0.25) } className='eq-4-2'></div>
        </div>
        <style jsx>{"""#{} // stylus
            .eq
                width 20px
                height 12px
                overflow hidden
                opacity 0.8

                .eq-col
                    flex 1
                    position relative
                    height 100%
                    margin-right 1px

                    div
                        animation-name eq-animation
                        animation-timing-function easeOutCubic
                        animation-iteration-count infinite
                        animation-direction alternate
                        position absolute
                        width 70%
                        height 140%
                        border-radius 2px
                        transform translateY(100%)
                        will-change transform
                        backface-visibility hidden

            @keyframes eq-animation
                0%
                    transform translateY(100%)

                100%
                    transform translateY(0)
        """}</style>
    </div>

export default Equalizer
