import React from 'react'
import { connect } from 'react-redux'
import { Tooltip } from 'react-tippy'

import anime from 'animejs'
import _ from 'lodash'
import Link from 'next/link'

import { DonateButton } from '~/components/donateView'
import ProfilePicture from '~/components/profilePicture'

import { randomInt } from '~/lib/util'
import { classif } from '~/lib/util'

import UIActions from '~/redux/ui'

import colors from '~/styles/colors'
import { Home, LogOut, User } from '~/styles/icons'

import config from '~/config'

toggle = ({ onToggle, isOpen, closeMenu, openMenu }) ->
    if onToggle?
        onToggle(not isOpen)

    if isOpen
        closeMenu()
    else
        openMenu()

CircularMenu = (props) ->
    size = props.size ? 80
    <div
        className="#{ props.className ? '' }"
        id='circular-menu-container'
        style={{
            zIndex: config.ZINDEX.circularMenu
            position: 'absolute'
            top: 10
            right: 10
            maxWidth: size
            maxHeight: size
            props.style...
        }}>
        <nav id='menu' className="menu #{ classif(props.isOpen, 'menu--open') }">
            <ProfilePicture size={ size } onToggle={ () -> toggle(props) } />
            <ul className='menu__items'>
                <Tooltip
                    theme='light'
                    offset={ size }
                    distance={ 130 }
                    open={ props.showTooltipHome }
                    trigger='manual'
                    position='left'
                    html={
                        <div className='flex-column-center'>
                            <span>After you're done, you can explore</span>
                            <span>other parts of the app here</span>
                        </div>}>
                    <li
                        id='home-circle'
                        className='flex-center'>
                        <Link prefetch href='/'>
                            <a className="
                                flex-column-center
                                #{ classif(props.focusHome, 'focused') }">
                                <Home />
                                <div className='icon-text'>Home</div>
                            </a>
                        </Link>
                    </li>
                </Tooltip>
                <Tooltip
                    theme='light'
                    offset={ 92 }
                    distance={ 170 }
                    open={ props.showTooltipProfile }
                    trigger='manual'
                    position='bottom'
                    title='You can manage your dislikes here later'>
                    <li
                        id='user-circle'
                        className='flex-center'>
                        <Link prefetch href='/user'>
                            <a className="
                                flex-column-center
                                #{ classif(props.focusProfile, 'focused') }">
                                <User />
                                <div className='icon-text'>Profile</div>
                            </a>
                        </Link>
                    </li>
                </Tooltip>
                <li
                    id='out-circle'
                    className='flex-center'>
                    <Link prefetch href={{
                            pathname: '/',
                            query: {
                                logout: true
                            }
                        }}>
                        <a className='flex-column-center'>
                            <LogOut />
                            <div className='icon-text'>Log Out</div>
                        </a>
                    </Link>
                </li>
                <li
                    id='donate-circle'
                    className='flex-center'>
                    <DonateButton size={ 50 } />
                </li>
            </ul>
            <style jsx>{"""#{} // stylus
                item-size-medium = 60px
                item-size = 50px
                item-size-big = 80px

                #menu
                    position relative
                    display inline-block
                    user-select none
                    cursor pointer
                    margin 0

                    .menu__items
                        absolute top left
                        width 100%
                        height 100%
                        padding 0
                        margin 0
                        list-style-type none

                        @media screen and (max-width: #{ config.WIDTH.medium }px)
                            transform scale3d(0.8,0.8,1)

                        li
                            opacity 0
                            width item-size-big
                            height item-size-big
                            min-width item-size
                            min-height item-size
                            max-width item-size-big
                            max-height item-size-big
                            absolute top 10% left 10%
                            font-size 1.5em
                            z-index -1
                            transform-origin 50% 50%
                            transform scale3d(0.5, 0.5, 1)
                            transition:
                                transform 0.25s easeOutCubic,
                                0.1s opacity 0.05s

                            a
                                width item-size
                                height item-size
                                text-decoration none !important
                                text-align center
                                background pitchBlack
                                color white
                                border-radius 100px
                                outline none
                                overflow hidden
                                ease-out width height background-color color
                                -webkit-tap-highlight-color rgba(0,0,0,0)
                                -webkit-tap-highlight-color transparent

                                &:hover
                                &:focus
                                &.focused
                                    width item-size-big
                                    height item-size-big
                                    border-radius 100px
                                    background red
                                    color pitchBlack

                                    .icon-text
                                        opacity 1
                                        display block

                                .icon-text
                                    opacity 0
                                    display none
                                    transition opacity 0.2s
                                    font-size 0.95rem

                                span
                                    absolute top 100%
                                    color transparent
                                    pointer-events none

                    &.menu--open .menu__items li
                        transition:
                            transform 0.25s cubic-bezier(0, 0.4, 0, 0.89),
                            opacity 0.1s
                        opacity 1

                        &#home-circle
                            transform scale3d(1, 1, 1) translate3d(-134px, -24px, 0)
                            filter: drop-shadow(0 0 4px alpha(black, 0.6))

                        &#user-circle
                            transform scale3d(1, 1, 1) translate3d(-112px, 36px, 0)
                            filter: drop-shadow(0 0px 4px alpha(black, 0.6))

                        &#out-circle
                            transform scale3d(1, 1, 1) translate3d(-70px, 86px, 0)
                            filter: drop-shadow(0 0 4px alpha(black, 0.6))

                        &#donate-circle
                            transform scale3d(1, 1, 1) translate3d(-8px, 115px, 0)
                            filter: drop-shadow(0 0 4px alpha(black, 0.6))

            """}</style>
            <style global jsx>{"""#{} // stylus
                .overlay-icon
                    opacity 0
                    ease-out 'opacity'

                    .menu:hover &
                        opacity 0.7
            """}</style>
        </nav>
    </div>

mapStateToProps = (state) ->
    isOpen            : state.ui.circularMenuOpen
    focusProfile      : state.ui.focusProfile
    focusHome         : state.ui.focusHome
    showTooltipHome   : state.ui.showTooltipHome
    showTooltipProfile: state.ui.showTooltipProfile
    user              : state.spotify.user
    fallbackUserImage : state.ui.fallbackUserImage

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    openMenu: _.debounce((() -> dispatch(UIActions.setCircularMenuOpen(true))), 175)
    closeMenu: () -> dispatch(UIActions.setCircularMenuOpen(false))
    setFallbackUserImage: (image) -> dispatch(UIActions.setFallbackUserImage(image))

export default connect(mapStateToProps, mapDispatchToProps)(CircularMenu)
