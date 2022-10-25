import React from 'react'

import Link from 'next/link'

import { getResolution } from '~/lib/img'

import colors from '~/styles/colors'
import { BarChart2, Disc, Map, Users } from '~/styles/icons'

import config from '~/config'

import ImageBackground from './imageBackground'
import LoadingIndicator from './loadingIndicator'

getIcon = (type) ->
    iconProps =
        size: 40
        className: "#{ type.toLowerCase() }-icon"
    switch type
        when 'Artist'
            <Users { iconProps... } />
        when 'Genre'
            <Disc { iconProps... } />
        when 'Country'
            <Map { iconProps... } />
        when 'City'
            <BarChart2 { iconProps... } />


DiscoverItem = ({
    href, className, id, style, imageTopic, imageBlur, onClick,
    color, loading, headline, description, loadingTexts, mobileLayout, props...
}) ->
    bgColor = color.saturate(0.1).lighten(0.6).alpha(0.9)
    headlineHoverColor = if bgColor.isLight()
        colors.PITCH_BLACK
    else
        colors.FLASH_WHITE
    descriptionHoverColor = if bgColor.isLight()
        colors.BLACK
    else
        colors.WHITE
    margin = if imageTopic is 'artist' and mobileLayout
        (config.NAVBAR_HEIGHT.mobile + 10)
    else
        0

    <Link prefetch href={ href }>
        <a
            className="discover-item #{ className ? '' }"
            id={ id }
            style={ style }>
            <ImageBackground
                local={
                    timeSpan: 'weekly'
                    topic: imageTopic
                }
                onClick={ onClick }
                blur={ 0 }
                fadeDuration={ 100 }
                overlayColor={ color.desaturate(0.2).alpha(0.8) }
                clickable={ not loading }
                >
                <div
                    style={
                        paddingTop: margin
                    }
                    className='
                        flex-column-center
                        justify-content-lg-between
                        h-100 item-text-container'>
                    <div className='d-flex
                        flex-column
                        justify-content-center
                        align-items-center
                        item-text'>
                        <h1 className='text-light text-center mb-2 headline'>
                            <span className='d-block'>{ getIcon(headline) }</span>
                            { headline }
                        </h1>
                        <p className='text-light text-center fw-500 description'>
                            { description }
                        </p>
                    </div>
                    {if loading
                        <LoadingIndicator
                            style={
                                position: 'fixed'
                                bottom: 20
                            }
                            eqColor={ headlineHoverColor }
                            textColor={ descriptionHoverColor }
                            loadingTexts={ loadingTexts }
                            className='w-100 loading-indicator' />}
                </div>
            </ImageBackground>
            <style jsx>{"""#{} // stylus
                bg-z-index = 1
                .discover-item
                    text-decoration none
                    overflow hidden
                    ease-out width height

                    @media (max-width: #{ config.WIDTH.medium }px)
                        width 100vw
                        height #{ if imageTopic is 'artist' then '45vh' else '25vh' }
                        min-height 200px

                    @media (min-width: #{ config.WIDTH.medium }px)
                        width 25vw
                        height 100vh

                        .item-text
                            margin-top 40vh

                    .item-text-container
                        z-index bg-z-index + 1

                    &:hover
                    &:focus
                        .headline
                            color #{ headlineHoverColor } !important
                            transform translateY(-10px) scale(1.05)

                        .description
                            color #{ descriptionHoverColor } !important
                            transform scale(1.02)

                    .description
                        ease-out 0.6s expo color 'transform'
                        font-size 0.9rem
                        font-weight 500
                        width 75%
                        line-height 1.2

                    .headline
                        ease-out 0.8s expo color 'transform'
                        margin-bottom 0
                        font-weight bold
                        font-size 2.7rem
            """}</style>
        </a>
    </Link>

export default DiscoverItem
