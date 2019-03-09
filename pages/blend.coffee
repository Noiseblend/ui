import React from 'react'
import { connect } from 'react-redux'

import Color from 'color'
import Router from 'next/router'
import uuid4 from 'uuid/v4'

import BlendGrid from '~/components/blendGrid'
import BlendTutorial from '~/components/blendTutorial'
import ImageBackground from '~/components/imageBackground'
import RoundedButton from '~/components/roundedButton'

import redirect from '~/lib/redirect'

import PlayerActions from '~/redux/player'
import SpotifyActions from '~/redux/spotify'
import UIActions from '~/redux/ui'

import colors from '~/styles/colors'

import config from '~/config'


initialProps = (blend) ->
    if not blend?
        return {}

    return
        icon: blend.dashedName
        color: blend.color
        manifest: "/manifest-#{ blend.dashedName }.json"
        title: blend.name
        description: blend.description


class Blend extends React.Component
    @getInitialProps: ({ store, query, res, req, isServer, authenticated, user, api }) ->
        blend = config.BLENDS[query.blend]
        playOnLoad = JSON.parse(query.playOnLoad ? false)
        shouldPlay = JSON.parse(query.play ? false)
        isTutorial = JSON.parse(query.tutorial ? false)
        isTest = JSON.parse(query.test ? false)

        blendParams = null
        if shouldPlay and not isTest and user?.spotifyPremium
            if not query.blend
                await return { error: 'No Blend was provided' }

            startVolume = parseInt(query.startVolume ? config.DEFAULTS.FADE_VOLUME_MIN)
            stopVolume = parseInt(query.stopVolume ? config.DEFAULTS.FADE_VOLUME_MAX)
            timeMinutes = parseInt(query.timeMinutes ? config.DEFAULTS.FADE_MINUTES)
            fadeDirection = if startVolume < stopVolume then 1 else -1
            step = parseInt(query.step ? 3)
            force = JSON.parse(query.force ? 'false')

            initialVolume = if query.fade
                parseInt(query.volume ? startVolume)
            else
                parseInt(query.volume)

            fadeParams = if not query.fade
                null
            else
                {
                    limit: stopVolume
                    start: startVolume
                    step: fadeDirection * step
                    seconds: timeMinutes * 60
                    force: force
                }

            blendParams = {
                blend: query.blend
                device: query.device
                volume: initialVolume
                filterExplicit: query.filterExplicit
                fade: fadeParams
                deviceId: query.deviceId
                play: true
            }
            blendToken = query.blendToken
        else if isTutorial and query.blend?
            blendTokenRes = await api.blendToken(query.blend)
            if not blendTokenRes.ok
                await return { error: blendTokenRes }
            blendToken = blendTokenRes.data.token

        userAgent = req?.headers?['user-agent'] ? navigator?.userAgent
        isChrome = userAgent.match('Chrome')?
        isSafari = not isChrome and userAgent.match('Safari')?
        browser = if isSafari
            'safari'
        else
            'chrome'

        navbarConfig = config.PAGE_PROPS['/blend'].navbar ? config.DEFAULT_PAGE_PROPS.navbar
        await return {
            initial: {
                initialProps(blend)...
                navbar: {
                    navbarConfig...
                    hidden: blendParams?
                }
            }
            playOnLoad
            blendParams
            blendToken
            blend
            shouldPlay
            isTutorial
            isTest
            browser
        }

    componentDidMount: ->
        user = @props.user ? @props.fetched.user
        @props.setUIState(@props.initial)

        if @props.blend?
            @props.blend.color = Color(@props.blend.color)
            @props.blend.overlayColor = Color(@props.blend.overlayColor)

        if @props.isTutorial
            if @props.blend?
                @switchTutorialToPlay(@props.blend, @props.blendToken)
            if user.firstBlend
                @props.setUserDetails({ firstBlend: false })

        if @props.playOnLoad
            @props.playBlend(@props.blendParams, @props.blendToken)

    componentDidUpdate: (prevProps, prevState, snapshot) ->
        if not prevProps.blendPlaylist? and @props.blendPlaylist
            redirect({target: @props.blendPlaylist.uri})

    switchTutorialToPlay: (blend, token) ->
        playHref =
            pathname: '/blend'
            query: {
                play: true
                playOnLoad: true
                blendToken: token
                deviceId: uuid4()
                blend.urlParams...
            }
        tutorialHref =
            pathname: '/blend'
            query: {
                tutorial: true
                blend.urlParams...
            }

        Router.replace(tutorialHref, playHref, { shallow: true })

    render: ->
        user = @props.user ? @props.fetched?.user
        unless user?.spotifyPremium
            <div className='fill-window flex-column-center'>
                <h1 className='mb-5 text-center'>
                    You need Spotify Premium to use this feature.
                </h1>
                <a href="https://www.spotify.com/premium/">
                    <RoundedButton
                        color={ colors.GREEN }>
                        Get Spotify Premium
                    </RoundedButton>
                </a>
            </div>
        else
            blend = @props.blend
            isTutorial = @props.isTutorial
            isTest = @props.isTest
            shouldPlay = @props.shouldPlay
            overlayColor = if blend?
                blend.overlayColor
            else
                colors.YELLOW.lighten(0.25)

            blendBg = if not blend?
                null
            else
                { topic: 'blend', name: blend.dashedName }

            <ImageBackground
                fadeIn fillWindow
                local={ blendBg }
                overlayColor={ overlayColor }>
                {if @props.noTracks
                    <div
                        className="fill-window flex-column-center text-center"
                        style={
                            maxWidth: '80vw'
                            minWidth: '80vw'
                        }>
                        <h1>No tracks could be generated for { blend.name }</h1>
                        <h5 className='font-sans mt-2'>
                            This can happen because of Spotify restrictions in your country
                        </h5>
                    </div>
                else if @props.blendParams?
                    <a href={ @props.blendPlaylist?.uri }>
                        <RoundedButton
                                className='flex-center mx-auto'
                                hoverTextColor={ colors.FLASH_WHITE }
                                onClick={
                                    () =>
                                        @props.playBlend(
                                            @props.blendParams,
                                            @props.blendToken
                                        )
                                }
                                loading={ @props.playingBlend }
                                color={ colors.WHITE }
                                textColor={ Color(@props.blend.color) }
                                style={
                                    fontSize: '1.4rem'
                                    fontWeight: 'bold'
                                }>
                                Play Blend
                        </RoundedButton>
                    </a>
                else if isTutorial or isTest
                    <BlendTutorial
                        testMode={ isTest }
                        blend={ blend }
                        browser={ @props.browser }
                        fetchedUser={ @props.fetched.user } />
                else
                    <BlendGrid />
                }
            </ImageBackground>

mapStateToProps = ({ spotify, player }) ->
    user: spotify.user
    noTracks: player.noTracks
    blendPlaylist: player.blendPlaylist
    playingBlend: player.playingBlend

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    setUIState: (ui) -> dispatch(UIActions.setState(ui))
    setNextUIState: (ui) -> dispatch(UIActions.setNextState(ui))
    setUserDetails: (details) -> dispatch(SpotifyActions.setUserDetails(details))
    playBlend: (params, token) -> dispatch(PlayerActions.playBlend(params, token))

export default connect(mapStateToProps, mapDispatchToProps)(Blend)
