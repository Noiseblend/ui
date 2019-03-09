import { connect } from 'react-redux'

import anime from 'animejs'
import Link from 'next/link'

import Card from '~/components/card'
import TextButton from '~/components/textButton'

import colors from '~/styles/colors'
import {
    Music,
    Sliders,
    User
} from '~/styles/icons'

import config from '~/config'


WIDTH = 180

Placeholder = ({ className, id, style, children, visible, height, width, props... }) ->
    <div
        className={ className ? '' }
        id={ id ? '' }
        style={{
            height: height
            minHeight: height
            maxHeight: height
            width: width
            minWidth: width
            maxWidth: width
            style...
        }}
        { props... }>
    </div>

INITIAL_SLIDER_VALUES = [
    { x1: 4, x2: 4, y1: 21, y2: 14 }
    { x1: 4, x2: 4, y1: 10, y2: 3 }
    { x1: 12, x2: 12, y1: 21, y2: 12 }
    { x1: 12, x2: 12, y1: 8, y2: 3 }
    { x1: 20, x2: 20, y1: 21, y2: 16 }
    { x1: 20, x2: 20, y1: 12, y2: 3 }
    { x1: 1, x2: 7, y1: 14, y2: 14 }
    { x1: 9, x2: 15, y1: 8, y2: 8 }
    { x1: 17, x2: 23, y1: 16, y2: 16 }
]

HOVER_SLIDER_VALUES = [
    { x1: 4, x2: 4, y1: 21, y2: 12 }
    { x1: 4, x2: 4, y1: 8, y2: 3 }
    { x1: 12, x2: 12, y1: 21, y2: 14 }
    { x1: 12, x2: 12, y1: 10, y2: 3 }
    { x1: 20, x2: 20, y1: 21, y2: 10 }
    { x1: 20, x2: 20, y1: 6, y2: 3 }
    { x1: 1, x2: 7, y1: 8, y2: 8 }
    { x1: 9, x2: 15, y1: 14, y2: 14 }
    { x1: 17, x2: 23, y1: 10, y2: 10 }
]
SLIDER_LINES = '.blend-card svg line'
USER_HEAD = '.user-card svg circle'
USER_BODY = '.user-card svg path'

onBlendHover = () ->
    anime.remove(SLIDER_LINES)
    anime(
        targets: SLIDER_LINES
        x1: (el, i) -> HOVER_SLIDER_VALUES[i].x1
        x2: (el, i) -> HOVER_SLIDER_VALUES[i].x2
        y1: (el, i) -> HOVER_SLIDER_VALUES[i].y1
        y2: (el, i) -> HOVER_SLIDER_VALUES[i].y2
    )

onBlendLeave = () ->
    anime.remove(SLIDER_LINES)
    anime(
        targets: SLIDER_LINES
        x1: (el, i) -> INITIAL_SLIDER_VALUES[i].x1
        x2: (el, i) -> INITIAL_SLIDER_VALUES[i].x2
        y1: (el, i) -> INITIAL_SLIDER_VALUES[i].y1
        y2: (el, i) -> INITIAL_SLIDER_VALUES[i].y2
    )

onUserHover = () ->
    anime.remove(USER_HEAD, USER_BODY)
    anime.timeline(
        easing: 'easeInOutQuad'
        duration: 250
    ).add(
        targets: USER_HEAD
        rotateY: 65
        rotateX: 10
    ).add(
        targets: USER_HEAD
        offset: '+=100'
        rotateY: -45
        rotateX: 10
    ).add(
        targets: USER_HEAD
        offset: '+=200'
        rotateY: 0
        rotateX: 0
    ).add(
        targets: USER_BODY
        easing: 'linear'
        d: 'M20 21v-2a3 4 0 0 0-4-4H8a3 4 0 0 0-4 4v2'
        duration: 200
    ).add(
        targets: USER_HEAD
        offset: '-=200'
        translateY: 1
        duration: 200
    ).add(
        targets: USER_BODY
        easing: 'linear'
        duration: 200
        d: 'M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2'
    ).add(
        targets: USER_HEAD
        offset: '-=200'
        translateY: 0
        duration: 200
    )

onUserLeave = () ->
    anime.remove(USER_HEAD)
    anime(
        targets: USER_HEAD
        rotateY: 0
        rotateX: 0
    )

IndexCards = (props) ->
    user = props.user ? props.fetched?.user

    <div
        style={ props.style }
        className="text-center text-light #{ props.className ? '' }">
        {if props.title
            <h1 className='text-light text-center mb-5'>
                { props.title }
            </h1>}
        <div className='
            d-flex flex-column flex-lg-row
            justify-content-around
            align-items-center
            my-3 card-grid'>
            <div className='flex-column-center order-2 order-lg-1 discover-container'>
                <Link prefetch href='/discover'>
                    <a>
                        <Card
                            size={ WIDTH }
                            color={ colors.PEACH.mix(colors.SUNFLOWER) }
                            icon={ Music }
                            title='Discover'
                            className='discover-card my-3 mx-lg-3'>
                        </Card>
                    </a>
                </Link>
            </div>
            <div className='flex-column-center order-1 order-lg-2 blend-container'>
                {if user?.spotifyPremium
                    <Link prefetch href='/blend'>
                        <a>
                            <Card
                                onMouseEnter={ onBlendHover }
                                onMouseLeave={ onBlendLeave }
                                size={ WIDTH }
                                color={ colors.RED.mix(colors.MAGENTA) }
                                icon={ Sliders }
                                title='Blend'
                                className='blend-card my-3 mx-lg-3'>
                            </Card>
                        </a>
                    </Link>
                }
            </div>
            <div className='flex-column-center order-3 order-lg-3 profile-container'>
                <Link prefetch href='/user'>
                    <a>
                        <Card
                            onMouseEnter={ onUserHover }
                            onMouseLeave={ onUserLeave }
                            size={ WIDTH }
                            color={ colors.MAUVE.mix(colors.MAGENTA) }
                            icon={ User }
                            title='Profile'
                            className='user-card my-3 mx-lg-3'>
                        </Card>
                    </a>
                </Link>
            </div>
        </div>
        <style global jsx>{"""#{} // stylus
            .user-card svg
                perspective 4cm
                circle
                    transform-origin center
        """}</style>
        <style jsx>{"""#{} // stylus
            .card-grid
                max-width 100vw
        """}</style>
    </div>

mapStateToProps = (state) ->
    user: state.spotify.user


export default connect(mapStateToProps)(IndexCards)
