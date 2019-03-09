import { connect } from 'react-redux'

import anime from 'animejs'
import Color from 'color'

import Palette from '~/components/palette'

import { randomInt } from '~/lib/util'

import UIActions from '~/redux/ui'

import colors from '~/styles/colors'
import { Settings } from '~/styles/icons'

import config from '~/config'

PATHS =
    reset: 'M150,275 C219,275 275,219 275,150 C275,81 219,25
            150,25 C81,25 25,81 25,150 C25,219 81,275 150,275 Z'
    active:'M150,285 C230,285 240,225.6 240,150 C240,74.4 230,15
            150,15 C70,15 60,74.4 60,150 C60,225.6 70,285 150,285 Z'

fallbackImage = ->
    "#{ config.STATIC }/img/bg/artist/\
    bg_#{ randomInt(1, 5) }_#{ config.WIDTH.toothbrush }.jpg"

color = (image) ->
    if not image?
        return colors.BLACK
    if typeof image.color is 'object'
        image.color
    else
        Color(image.color)

toggle = ->
    anime.timeline(targets: ['#img-path', '#img-overlay-path', '#img-clip-path']).add(
        d: PATHS.active
        duration: 200
        easing: 'easeInQuad'
    ).add(
        d: PATHS.reset
        duration: 1000
        elasticity: 800
    )


ProfilePicture = ({
    className, id, style, user, setFallbackUserImage,
    fallbackUserImage, batchActions, children, onToggle, props...
}) ->
    colorTop = colors.SUNFLOWER
    colorBottom = colors.CALM_BLUE
    image = user?.images?[0]
    size = size ? 60
    <button
        className="trigger #{ className ? '' }"
        id={ id ? '' }
        style={ style }
        onClick={ () ->
            onToggle?()
            toggle()
        }
        { props... }>
        <span className='morph-shape' data-morph-active={ PATHS.active }>
            <svg
                width='100%'
                height='100%'
                viewBox='0 0 300 300'
                preserveAspectRatio='none'>
                <path
                    d={ PATHS.reset }
                    id='img-path'
                    fill='url(#user-img)' />
                <path
                    d={ PATHS.reset }
                    id='img-overlay-path'
                    fill={ if image? then 'url(#user-img-overlay)' else '' } />
                <defs>
                    <clipPath id='elastic-circle'>
                        <path d={ PATHS.reset } id='img-clip-path' />
                    </clipPath>
                    { if image?.url?
                        <Palette image={ image.url }>
                            {(palette) ->
                                <linearGradient
                                    id='user-img-overlay'
                                    x1='70%'y1='0%'
                                    x2='0%'y2='100%'>
                                    <stop
                                        offset='0%'
                                        style={
                                            stopColor: palette?.muted,
                                            stopOpacity: 0.6
                                        } />
                                    <stop
                                        offset='100%'
                                        style={
                                            stopColor: palette?.vibrant,
                                            stopOpacity: 0.6
                                        } />
                                </linearGradient>
                            }
                        </Palette>
                    }
                    <pattern
                        id='user-img'
                        patternUnits='userSpaceOnUse'
                        width='300' height='300'>
                        <image
                            xlinkHref={ fallbackUserImage ? image?.url }
                            x='0' y='0'
                            onError={ () -> setFallbackUserImage(fallbackImage()) }
                            width='300' height='300'
                            clipPath='url(#elastic-circle)' />
                    </pattern>
                </defs>
            </svg>
        </span>
        <style jsx>{"""#{} // stylus
            .trigger
                cursor pointer
                background none
                border-radius 100px
                padding 0
                margin 0
                border none
                outline none
                text-align center
                font-size 1.5em
                position relative
                color alpha(white, 0.5)
                ease-out color
                width navbarHeightDesktop
                height navbarHeightDesktop
                @media(max-width: $mobile)
                    width navbarHeightMobile
                    height navbarHeightMobile

                &:hover
                &:focus
                    color white

            .morph-shape
                absolute top left
                width 100%
                height 100%

                svg
                    filter: grayscale(40%) drop-shadow(2px -1px 2px alpha(black, 0.1)) drop-shadow(-1px 2px 2px alpha(black, 0.2))
                    ease-out 'filter' 'opacity'
                    opacity 0.9

                    & > #img-overlay-path
                        ease-out 'transform'

                &.menu--open #img-overlay-path
                &:hover #img-overlay-path
                    transform none !important

                &.menu--open svg
                &:hover svg
                svg:hover
                    filter: grayscale(0%) drop-shadow(3px -2px 4px alpha(black, 0.3)) drop-shadow(-3px 4px 4px alpha(black, 0.4)) !important
                    opacity 1

        """}</style>
    </button>

mapStateToProps = (state) ->
    user              : state.spotify.user
    fallbackUserImage : state.ui.fallbackUserImage

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    setFallbackUserImage: (image) -> dispatch(UIActions.setFallbackUserImage(image))

export default connect(mapStateToProps, mapDispatchToProps)(ProfilePicture)
