import React from 'react'
import { connect } from 'react-redux'

import Color from 'color'
import _ from 'lodash'

import Palette from '~/components/palette'
import PlaylistQuiz from '~/components/playlistQuiz'
import RoundedButton from '~/components/roundedButton'
import TextButton from '~/components/textButton'

import { classif } from '~/lib/util'

import SpotifyActions from '~/redux/spotify'
import UIActions from '~/redux/ui'
import UserActions from '~/redux/user'

import colors from '~/styles/colors'
import { ChevronLeft, ChevronRight } from '~/styles/icons'

import config from '~/config'

import DislikeButton from './dislikeButton'
import ImageBackground from './imageBackground'
import Undo from './undo'


dislike = (item, props) ->
    actions = [
        props.dislike(item, { returnActions: true })...
        UIActions.setUndoHidden(false)
        UserActions.invalidateDislikes()
    ]
    props.hideUndoIn5Seconds()
    if props.user.firstDislike
        actions = [
            actions...
            SpotifyActions.setUserDetails({ firstDislike: false })
            UIActions.setFocusProfile(true)
        ]
        props.showProfileTooltipInHalfSecond()
        props.defocusProfileIn8Seconds()
        props.hideProfileTooltipIn8Seconds()
    props.batchActions(actions)

CardContent = ({
    item, itemNo, clicked, height, width, radius,
    color, textColor, props...
}) ->
    if not textColor?
        textColor = if color.isLight()
            colors.BLACK
        else
            colors.WHITE

    <div>
        <div
            className="
                item
                #{ classif item.loading ? false, 'loading' }
                #{ classif item.selected ? false, 'selected' }"
            onClick={ () ->
                if not item.loading and not clicked
                    props.onClick(item, itemNo)
            }
            style={{
                color: textColor
                minHeight: height / 2
                minWidth: width / 2
                maxHeight: height
                maxWidth: width
                borderRadius: radius
                margin: '2rem auto'
                cursor: 'pointer'
            }}>
            <ImageBackground
                key={ itemNo }
                style={
                    overflow: 'hidden' if clicked
                    borderRadius: radius
                }
                background={ src: item.image?.url }
                overlayColor={ color.alpha(0.75) }
                sizes="(min-width: #{ config.WIDTH.medium }px) 22vw, 50vw"
                imageStyle={
                    backfaceVisibility: 'hidden'
                    borderRadius: radius
                    display: if item.loading
                        'none'
                    else
                        'block'
                    transform: 'scale(1.1)' if clicked
                }
                overlayStyle={ borderRadius: radius }
                fadeIn={ not item.loading }
                blur={ 30 if clicked }
                clickable={ not item.loading and not clicked }>
                <div
                    className='selected-overlay'
                    style={
                        borderRadius: radius
                     } >
                    <div className='space'></div>
                    <div className='font-heading item-name'>
                        { item.name }
                    </div>
                    { props.showDislikeButton and <DislikeButton
                        id={ itemNo }
                        style={
                            opacity: if item.loading then 0 else 1
                            transition: 'opacity 0.7s var(--ease-out-quint)'
                        }
                        disabled={ item.loading }
                        onClick={ () ->
                            if not item.loading
                                dislike(item, props) }
                        message="Don't show this #{ props.itemName } anymore"
                        backgroundColor='transparent'
                        color={ textColor }>
                    </DislikeButton> }
                </div>
            </ImageBackground>
        </div>
        <div className='credits' style={ opacity: +item.image?.unsplash? }>
            <p className='unsplash-credits text-center'>
                Photo by <a href={ item.image?.unsplash?.userUrl ? '' }>
                    { item.image?.unsplash?.userName ? '' }
                </a> /&nbsp;
                <a href={ item.image?.unsplash?.siteUrl ? '#' }>
                    Unsplash
                </a>
            </p>
        </div>
        <div
            style={
                backgroundColor: color.alpha(1)
                zIndex: config.ZINDEX.normal
            }
            className="bg-reveal #{ classif clicked, 'reveal' }" />
        { if clicked
            playlists = props.clickedItem.playlists
            <PlaylistQuiz
                style={
                    position: 'fixed'
                    top: '0'
                    left: '0'
                    width: '100vw'
                    maxWidth: '100vw'
                    zIndex: config.ZINDEX.normal
                }
                item={ props.clickedItem }
                playlists={ playlists ? [] }
                playlistType={ props.itemName }
                color={ color }
                textColor={ textColor }
                deselectItem={ props.deselectItem }>
            </PlaylistQuiz>
        }
        <style jsx>{"""#{} // stylus
            :global(.card-item)
                bg-reveal-fullsize fixed center center

            .item
                ease-out 'box-shadow' 'transform' color
                width 50vw
                height @width
                box-shadow:
                    0 16px 22px alpha(darkMauve, 0.4),
                    0px 5px 8px alpha(pitchBlack, 0.3)

                font-weight bold
                font-size 1.3rem
                text-align center

                &.selected
                    transform scale(1.015)

                &:not(.loading)
                    &:hover
                    &:focus
                        box-shadow:
                            0 18px 26px alpha(darkMauve, 0.5),
                            0px 4px 14px alpha(pitchBlack, 0.3)
                        cursor pointer

                @media (min-width: #{ config.WIDTH.medium }px)
                    width 22vw
                    height 22vw

                .selected-overlay
                    transition:
                        background 0.15s easeOutCubic 0.05s,
                        border-radius 0s easeOutCubic 0.5s,
                        width 0s easeOutCubic 0.5s,
                        height 0s easeOutCubic 0.5s,
                        box-shadow 0.2s
                        opacity 0.2s easeOutCubic
                    background-color transparent
                    border-radius 100px
                    height 100%
                    width 100%
                    display grid
                    grid-template 'space' .5fr 'name' .5fr 'button' .5fr

                &.selected .selected-overlay
                    transition:
                        background 0.1s,
                        border-radius 0.3s,
                        width 0.2s,
                        height 0.2s,
                        box-shadow 0.2s easeOutCubic 0.1s
                    color white
                    background-color alpha(darkMauve, 0.4)
                    box-shadow 0 10px 60px alpha(mauve, 0.9)
                    height 100%
                    width 100%

            .space
                grid-area space

            .item-name
                justify-self center
                align-self center
                grid-area name

            .credits
                transition opacity 0.4s ease-in-out 1s
                margin-top 1rem
                margin-bottom 1rem

                .unsplash-credits
                    margin 0
                    line-height 1
                    font-size 0.8rem
                    font-weight normal
                    color lightGray

                    & > a
                        color grayMauve
                        transition color 0.15s easeOutCubic

                        &:hover,
                        &:focus
                            color #{ colors.GRAY_MAUVE.rotate(40).lighten(0.5) }
                            text-decoration none
        """}</style>
        <style jsx>{"""#{} // stylus
            :global(body)
                overflow #{ if props.clickedItem? then 'hidden' else 'auto' }

            .item
                &:not(.loading)
                    &:hover
                    &:focus
                        transform scale(#{ if props.clickedItem? then '1' else '1.015' })
        """}</style>
    </div>

CardView = (props) ->
    <div className='
        d-flex flex-row
        justify-content-around
        align-items-center
        w-100 card-container'>
        <Undo
            top
            show={ not props.undoHidden }
            onClick={ () ->
                if dislikedItems?.length > 0
                    props.removeDislike(dislikedItems[dislikedItems.length - 1])
                props.hideUndo()
            } />
        <TextButton
            className='ml-2 history-button previous-button'
            style={
                opacity: if props.loading then 0 else 'initial'
            }
            disabled={ (not props.showPreviousButton) or props.loading }
            onClick={ props.onPreviousClick }>
            <ChevronLeft
                size='38'
                className='h-100 mr-1'
                />
        </TextButton>

        <ul className='
            d-flex
            flex-column
            flex-lg-row
            justify-content-around
            align-items-center
            w-100
            item-list'>
            {props.items?.filter((item) -> item?)?.map((item, i) ->
                clicked = item.name is props.clickedItem?.name
                borderRadius = if clicked then 0 else props.borderRadius

                textColor = if item.image?.textColor?
                    Color(item.image?.textColor)
                else
                    null

                color = if item.image?.color?
                    Color(item.image?.color)
                else
                    null

                <li
                    className='
                        d-flex flex-column
                        justify-content-center
                        align-items-center
                        card-item'
                    key={ i }>
                    {if not color? and item.image?.url?
                        <Palette image={ item.image?.url }>
                            {(palette) ->
                                <CardContent
                                    item={ item }
                                    clicked={ clicked }
                                    height={ props.cardHeight }
                                    width={ props.cardWidth }
                                    radius={ borderRadius }
                                    color={
                                        if palette?.lightMuted?.length
                                            Color(palette.lightMuted)
                                        else
                                            colors.GRAY_MAUVE.alpha(0.7)
                                    }
                                    textColor={ textColor }
                                    { props... }
                                />
                            }
                        </Palette>
                    else
                        <CardContent
                            item={ item }
                            itemNo={ i }
                            clicked={ clicked }
                            height={ props.cardHeight }
                            width={ props.cardWidth }
                            radius={ borderRadius }
                            color={ color ? Color(config.CARD_OVERLAY_COLOR) }
                            textColor={ textColor }
                            { props... }
                        />
                    }
                </li>
            )}
        </ul>
        <TextButton
            className='mr-2 history-button next-button'
            style={ opacity: if props.loading then 0 else 'initial' }
            disabled={ (not props.showNextButton) or props.loading }
            onClick={ () -> props.onNextClick() }>
            <ChevronRight
                size='38'
                className='h-100 ml-1'
                />
        </TextButton>
        <style global jsx>{"""#{} // stylus
            size = 100px
            mobileSize = 70px

            .history-button
                margin-bottom 2.8rem
                transition all 0.2s
                width size
                height size
                line-height size
                min-width size
                min-height size
                border-radius (size / 2)
                text-align center
                padding 0
                font-size 2.5rem
                background-color alpha(flashWhite, 0.1) !important

                @media (max-width: #{ config.WIDTH.medium }px)
                    font-size 1.5rem
                    width mobileSize
                    height mobileSize
                    line-height mobileSize
                    min-width mobileSize
                    min-height mobileSize
                    border-radius (mobileSize / 2)

                &.disabled
                    background-color alpha(flashWhite, 0.1) !important
                    opacity 1
                    color white
                    height 0px
                    min-height 0px
                    font-size 0px
                    border-radius 0

                    &:hover
                    &:focus
                        background-color alpha(flashWhite, 0.1) !important
                        color white
                        box-shadow none

                &:hover
                    background-color alpha(flashWhite, 0.3) !important
                    box-shadow none
                    border-color transparent

                &:active
                &:active:focus
                    background-color alpha(red, 0.4) !important
                    box-shadow none
                    border-color transparent

                &:focus
                    background-color alpha(flashWhite, 0.1) !important
                    box-shadow none
                    border-color transparent

            .dislike-button
                grid-area button
        """}</style>
        <style jsx>{"""#{} // stylus

            .card-container
                width 94%

            .item-list
                list-style-type none
                padding-left 0

                @media (min-width: #{ config.WIDTH.medium }px)
                    min-width 400px
        """}</style>
    </div>

mapStateToProps = (state) ->
    undoHidden: state.ui.undoHidden
    windowWidth: state.ui.windowWidth
    focusProfile: state.ui.focusProfile
    user: state.spotify.user

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    showUndo: () -> dispatch(UIActions.setUndoHidden(false))
    hideUndo: () -> dispatch(UIActions.setUndoHidden(true))
    setUserDetails: (details) -> dispatch(SpotifyActions.setUserDetails(details))
    setFocusProfile: (focusProfile) -> dispatch(UIActions.setFocusProfile(focusProfile))
    hideUndoIn5Seconds: _.debounce(
        (() -> dispatch(UIActions.setUndoHidden(true))), 5000)
    defocusProfileIn8Seconds: _.debounce(
        (() -> dispatch(UIActions.setFocusProfile(false))), 8000)
    showProfileTooltipInHalfSecond: _.debounce(
        (() -> dispatch(UIActions.setShowTooltipProfile(true))), 500)
    hideProfileTooltipIn8Seconds: _.debounce(
        (() -> dispatch(UIActions.setShowTooltipProfile(false))), 8000)


export default connect(mapStateToProps, mapDispatchToProps)(CardView)
