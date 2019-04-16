import React from "react"
import { connect } from "react-redux"

import Router from "next/router"

import ConnectButton from "~/components/connectButton"
import Hero from "~/components/hero"
import ImageBackground from "~/components/imageBackground"
import IndexCards from "~/components/indexCards"
import InfoLinks from "~/components/infoLinks"
import SocialButtons from "~/components/socialButtons"

import redirect from "~/lib/redirect"
import {
    getAlexaParams
    removeAuthTokenCookie
    setAlexaParams
    removeAlexaParams
    setAuthTokenCookie
} from "~/lib/session"
import { randomInt } from "~/lib/util"

import AuthActions from "~/redux/auth"
import SpotifyActions from "~/redux/spotify"

import colors from "~/styles/colors"

import config from "~/config"

class Index extends React.Component
    @getInitialProps = ({ store, query, res, req, isServer, authenticated, user, api }) ->
        ctx = { isServer, store, query, res, req }
        props = {}

        if query.logout is "true"
            if authenticated
                await api.logOut()
            removeAuthTokenCookie(ctx)
            return
                authenticated: false
                fetched:
                    user: null

        if query.code? and query.state? and isServer
            user = await api.authenticate(query.code, query.state)
            authenticated = user?
            props =
                fetched: { user }
                authenticated: authenticated
                emailConfirmed: user?.email?.length isnt 0 and user?.emailConfirmed

        queryAlexaParams = query
        cookieAlexaParams = getAlexaParams(ctx)
        hasQueryAlexaParams =
            queryAlexaParams.client_id is "alexa-blend" and
            queryAlexaParams.redirect_uri in config.ALEXA_REDIRECT_URIS
        hasCookieAlexaParams =
            cookieAlexaParams.client_id is "alexa-blend" and
            cookieAlexaParams.redirect_uri in config.ALEXA_REDIRECT_URIS

        props = {
            props...
            hasQueryAlexaParams
            hasCookieAlexaParams
            queryAlexaParams
            cookieAlexaParams
        }

        if not hasCookieAlexaParams and not authenticated
            setAlexaParams(queryAlexaParams, ctx)

        # if authenticated and user?.firstLogin and isServer
        #     if user?.spotifyPremium
        #         pages = ["/artists", "/genres", "/blend"]
        #         redirectedPage = pages[randomInt(0, 3)]
        #     else
        #         pages = ["/artists", "/genres"]
        #         redirectedPage = pages[randomInt(0, 2)]

        #     await api.setUserDetails(firstLogin: false)
        #     redirect({target: redirectedPage, res, isServer})
        #     await return props

        await return props

    componentDidUpdate: (prevProps, prevState, snapshot) ->
        { query } = Router
        if query?.logout is "true"
            removeAuthTokenCookie()
            window.location.replace('/')
        else if query?.token?
            Router.replace("/", "/", shallow: true)

    componentDidMount: () ->
        { query } = Router
        if query?.logout is "true"
            removeAuthTokenCookie()
            window.location.replace('/')
        else if query?.code? and query?.state?
            Router.replace("/", "/", shallow: true)
        else if query?.token?
            Router.replace("/", "/", shallow: true)

        authParams = {
            hasQueryAlexaParams
            hasCookieAlexaParams
            queryAlexaParams
            cookieAlexaParams
            authenticated
        } = @props

        if (hasQueryAlexaParams or hasCookieAlexaParams) and authenticated
            @props.alexaAuthentication(authParams)

    render: () ->
        { authenticated, authenticating, emailConfirmed, actions... } = @props
        <ImageBackground fadeIn fillWindow overlayColor={ config.DEFAULT_IMAGE_OVERLAY }>
            <div className="flex-column-center">
                { if authenticated?
                    if not authenticated
                        <Hero
                            className="hero"
                            title="Get closer to the Edge."
                            subtitle="There's a whole ocean out there
                                      and you're swimming in a pool">
                            <ConnectButton
                                authenticating={ authenticating }
                                onClick={ actions.startAuthentication }
                            />
                            <div className="mt-2 text-center disclaimer">
                                <div>Some features may not be available if</div>
                                <div>you're not a Spotify Premium user</div>
                            </div>
                        </Hero>
                    else
                        <IndexCards fetched={ @props.fetched } className="index-cards" />
                 }
                <SocialButtons
                    className="mb-2"
                    style={
                        bottom: if @props.mobile then 50 else 30
                        position: "fixed"
                    }
                />
                <InfoLinks className="mb-2" style={bottom: 0, position: "fixed"} />
            </div>
            <style global jsx>{ """#{} // stylus
                .disclaimer
                    color alpha(white, 80%)
                    font-size 14px
                    opacity 0
                    reveal opacity 1.5s 3s

                .hero
                .index-cards
                    opacity 0
                    reveal opacity
                    margin-top 3rem
                    margin-bottom 3rem
                    @media (max-width: $mobile)
                        margin-bottom 6rem

                .card-layer
                    margin-top 25px

                    @media (max-width: 500px)
                        margin-top 15px
                        flex-direction column
            """ }</style>
        </ImageBackground>

mapStateToProps = (state) ->
    user: state.spotify.user
    authenticating: state.auth.authenticating
    mobile: state.ui.mobile

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    startAuthentication: () ->
        dispatch(AuthActions.startAuthentication())
    alexaAuthentication: ({queryAlexaParams, cookieAlexaParams, hasQueryAlexaParams, hasCookieAlexaParams}) ->
        dispatch(AuthActions.alexaAuthentication(
            queryAlexaParams, cookieAlexaParams, hasQueryAlexaParams, hasCookieAlexaParams
        ))

export default connect(mapStateToProps, mapDispatchToProps)(Index)
