import React from 'react'
import { connect } from 'react-redux'

import anime from 'animejs'

import TextButton from '~/components/textButton'

import { classif } from '~/lib/util'

import SpotifyActions from '~/redux/spotify'
import UIActions from '~/redux/ui'

import colors from '~/styles/colors'
import { X } from '~/styles/icons'

import config from '~/config'


hideHint = ({ batchActions, setUIState }) ->
    anime(
        begin: () -> setUIState({ hintShown: true })
        targets: '#important-hint'
        rotateX: ['0deg', '95deg']
        easing: 'easeInCubic'
        duration: 500
        complete: () ->
            batchActions([
                UIActions.setState({ hintHidden: true })
                SpotifyActions.setUserDetails({ blendHintHidden: true })
            ])
    )

blendIcon = (blendName) ->
    "#{ config.STATIC }/img/icons/#{ blendName }/#{ blendName }-android-512x512.png"

BlendHint = ({ hintShown, hintHidden, props... }) ->
    <div id="hint-container">
        <div
            className="
                text-center p-3
                #{ classif(hintShown, 'shown') }
                #{ classif(hintHidden, 'hidden') }"
            id="important-hint">
            This is not a conventional playlist
            <br />
            New music is generated on every launch
            <TextButton
                onClick={ () -> hideHint(props) }
                className='flex-center p-0 m-0'
                style={
                    backgroundColor: colors.RED
                    position: 'absolute'
                    top: -4
                    right: -4
                    width: 20
                    height: 20
                    borderRadius: 10
                }>
                <X size={ 12 } />
            </TextButton>
        </div>
        <style jsx>{"""#{} // stylus
            hint-width = 90vw
            #hint-container
                perspective 5cm
                exact-width hint-width
                center-bottom hint-width

                @media(min-width: $mobile)
                    hint-width = 300px
                    exact-width hint-width
                    center-bottom hint-width

            #important-hint
                font-size 14px
                background-color alpha(pitchBlack, 0.9)
                border-radius 5px
                bottom 20px !important
                position relative
                ease-out 'transform'
                transform rotateX(95deg)
                transform-origin bottom
                reveal vertical-rotation 0.6s 2s

                &.shown
                    transform rotateX(0deg)
                    animation none

                &.hidden
                    display none
                    animation none !important

        """}</style>
    </div>


BlendTutorial = ({
    className, id, style, children, blend,
    hintShown, hintHidden, user, fetchedUser, props...
}) ->
    blend ?= config.BLENDS.workoutHype
    hintHidden = hintHidden or user?.blendHintHidden or fetchedUser?.blendHintHidden
    <div
        className="
            flex-column-center
            instructions-container
            #{ className ? '' }"
        id={ id ? '' }
        style={{
            style...
        }}>
        <img
            id='blend-icon'
            className='mx-auto'
            src={ blendIcon(blend.dashedName) }
            alt="#{ blend.name } Icon"
        />
        <h2 className='text-light text-center mt-3 mb-0'>
           { blend.name }
       </h2>
       {if blend.fade?
           <div className='mt-3 font-heading text-uppercase blend-tag'>
                { blend.fade.minutes } minutes fade
                { if blend.fade.direction is -1 then ' out' else ' in' }
            </div>
       }
        <p className='text-center mt-2 p-3' id='blend-description'>
            { blend.description }
        </p>
        {if not props.testMode
            <>
                <div
                    key='video-container'
                    className='
                        flex-column-center
                        video-container'>
                    <video
                        poster="#{ config.STATIC }/img/video-loading-poster.jpg"
                        key='add-home-demo'
                        className='add-home-demo'
                        autoPlay={true}
                        playsInline={true}
                        muted={true}
                        loop={true}>
                        <source
                            src="
                                #{ config.STATIC }/video\
                                /add-home-#{ props.browser }-demo.mp4"
                            type='video/mp4' />
                    </video>
                    <h3 key='add-home-text' className='mt-5 text-center add-home-text'>
                        Add the Blend to homescreen to use it
                    </h3>
                    <h4 className='my-4' style={ opacity: 0.6 }>
                        ————&nbsp;&nbsp;or&nbsp;&nbsp;————
                    </h4>
                    <h3 key='add-home-text-2' className='text-center add-home-text'>
                        Bookmark the Blend if you are on desktop
                    </h3>
                    <img
                        className='mt-4'
                        src="#{ config.STATIC }/img/star#{ props.browser }.jpg"
                        id='bookmark-image' />
                    <h4 key='add-home-text-3' className='mt-2 text-center add-home-text'>
                        and just click on the bookmark to start playback
                    </h4>
                </div>
                <BlendHint
                    key='blend-hint'
                    hintShown={ hintShown }
                    hintHidden={ hintHidden }
                    setUIState={ props.setUIState }
                    batchActions={ props.batchActions }
                />
            </>
        else
            <div className='placeholder' key='placeholder' />
        }
        <style global jsx>{"""#{} // stylus
            #circular-menu-container
                display #{ if props.testMode then 'none' else 'block' }
        """}</style>
        <style jsx>{"""#{} // stylus
            .instructions-container
                margin-top 10vh
                margin-bottom 10vh

                @media(max-width: $mobile)
                    margin-top navbarHeightMobile + 20px
                    margin-bottom 50px

                #bookmark-image
                    border-radius 10px
                    bottom-shadow 4px 20px
                    width 350px
                    max-width 90vw

                .placeholder
                    min-height 40vh

                .video-container
                    .add-home-text
                        color alpha(white, 85%)
                        max-width 300px

                    .add-home-demo
                        border-radius 20px
                        max-height 50vh
                        max-width 100vw
                        bottom-shadow 4px 20px
                        @media(max-width: $medium)
                            max-height 100vh
                            max-width 70vw

                .blend-tag
                    background-color blue
                    color white
                    padding 3px 8px
                    border-radius 2px
                    font-variant small-caps
                    font-size 11px

                #blend-description
                    font-size 1.3rem
                    color flashWhite
                    max-width 500px

                    @media(max-width: $mobile)
                        font-size 14px
                        max-width 75vw

                #blend-icon
                    width 172px
                    height @width

                    @media(max-width: #{ config.WIDTH.medium }px)
                        width 128px
                        height @width

                    @media(max-width: #{ config.WIDTH.mobile }px)
                        width 96px
                        height @width
        """}</style>
    </div>

mapStateToProps = (state) ->
    hintShown: state.ui.hintShown
    hintHidden: state.ui.hintHidden
    user: state.spotify.user

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    setUIState: (ui) -> dispatch(UIActions.setState(ui))

export default connect(mapStateToProps, mapDispatchToProps)(BlendTutorial)
