import '~/lib/str'

import React from 'react'

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'

import TextButton from '~/components/textButton'

import colors from '~/styles/colors'
import { BarChart2, Disc, Map, ThumbsDown, User, Users, XCircle } from '~/styles/icons'

import config from '~/config'

import '~/styles/fontawesome'

LIST_BG = config.USER_BACKGROUND.darken(0.075)

icon = (itemType, mobile) ->
    iconProps =
        color: "#{ colors.WHITE.alpha(0.9) }"
        size: if mobile then 22 else 26

    switch itemType
        when 'Artists'
            <Users { iconProps... } />
        when 'Genres'
            <Disc { iconProps... } />
        when 'Countries'
            <Map { iconProps... } />
        when 'Cities'
            <BarChart2 { iconProps... } />

fallbackImage = (item) ->
    "#{ config.STATIC }/img/bg/music/\
    bg_#{ (item.hash() % 31) + 1 }_#{ config.WIDTH.toothbrush }.jpg"

DislikeList = ({ listStyle, props... }) ->
    imageSize = if props.mobile
        50
    else
        60

    <div
        className="
            d-flex flex-column
            dislike-list-container
            #{ props.className ? '' }"
        style={ props.style }>
        <div
            className='
                px-4 py-1 py-md-4 my-3
                d-flex
                justify-content-start
                align-items-center
                dislike-list-header'>
            { icon(props.itemsName, props.mobile) }
            {if props.mobile
                <h4 className='m-0 ml-3 font-weight-bold text-light list-heading'>
                    { props.itemsName }
                </h4>
            else
                <h5 className='m-0 ml-3 font-weight-bold text-light list-heading'>
                    { props.itemsName }
                </h5>
            }
        </div>
        <ul
            style={{
                overflow: 'scroll'
                '-webkit-overflow-scrolling': 'touch'
                listStyle...
            }}
            className="
                #{ if props.items?.length isnt 0
                    'py-1 py-md-3 px-0 px-md-4'
                else
                    'p-0 d-flex justify-content-center align-items-center' }
                mb-0 dislike-list">
            {
                if props.fetching
                    <LoadingIndicator className='w-100 loading-indicator' />
                else if props.items? and props.items.length > 0
                    props.items.map((item, i) ->
                        <li className='
                            px-4 py-3 my-3 mx-auto
                            d-flex flex-row
                            justify-content-between
                            align-items-center
                            disliked-item'
                            key={ i }>
                            <div className='d-flex flex-row align-items-center'>
                                <img
                                    src="#{ item?.image?.url ? fallbackImage(item?.name) }"
                                    alt='Item image'
                                    className='item-image'
                                    style={
                                        boxShadow: "
                                            0 2px 10px alpha(black, 0.4)"
                                        width: imageSize
                                        height: imageSize
                                        objectFit: 'cover'
                                        borderRadius: 5
                                        position: 'relative'
                                     } />
                                <div className='ml-3 item-name'>{ item.name }</div>
                            </div>
                            <TextButton
                                className='
                                    p-2 p-md-0 m-0 d-flex
                                    justify-content-center
                                    align-items-center'
                                style={
                                    height: 40
                                }
                                onClick={ () -> props.removeDislike(item) }>
                                <XCircle
                                    className='remove-button'
                                    size={ 24 }
                                    strokeWidth={ 3 }
                                    color="#{ colors.BLACK.rgb().string() }" />
                            </TextButton>
                        </li>)
                else
                    <p className='
                        text-center font-heading w-75
                        d-flex flex-column align-items-center
                        no-items-message'>
                        Disliked { props.itemsName.toLowerCase() } will appear here
                        after you press the dislike button
                        <FontAwesomeIcon
                            icon='thumbs-down'
                            color="#{ colors.RED.desaturate(0.1).alpha(0.7) }"
                            style={
                                marginTop: 20
                                height: '1.7rem'
                                width: '1.7rem'
                           } />
                    </p>
            }
            <style global jsx>{"""#{} // stylus
                .remove-button
                    cursor pointer
                    transition stroke 0.2s ease-out

                .remove-button:hover, .remove-button:focus
                    stroke red !important

                .dislike-list::-webkit-scrollbar
                    display none

            """}</style>
            <style jsx>{"""#{} // stylus
                .dislike-list-container
                    overflow scroll
                    -webkit-overflow-scrolling touch
                    background #{ LIST_BG }
                    border-radius 5px

                .disliked-item
                    border-radius 6px
                    color black
                    font-weight bold
                    font-size 1.2rem
                    background-color white
                    box-shadow 0 4px 10px alpha(black, 0.6)
                    max-width 500px

                .no-items-message
                    font-size 1.1rem
                    color alpha(white, 0.4)

                .list-heading
                    color white

                @media (max-width: 500px)
                    .disliked-item
                        border-radius 0


            """}</style>
        </ul>
    </div>

export default DislikeList
