import '~/lib/util'

import React from "react"
import { connect } from 'react-redux'

import anime from 'animejs'
import _ from 'lodash'
import Head from 'next/head'
import Router from 'next/router'

import App, { Container } from "next/app"

import AppleLaunchScreenLinks from '~/components/appleLaunchScreenLinks'
import Layout from '~/components/layout'
import RoundedButton from '~/components/roundedButton'

import redirect from '~/lib/redirect'
import Sentry from '~/lib/sentry'
import { randomInt } from '~/lib/util'

import createStore from '~/redux'
import SpotifyActions from '~/redux/spotify'
import UIActions from '~/redux/ui'

import API from '~/services/api'

import colors from '~/styles/colors'

import config from '~/config'
import withRedux from "~/hoc/redux"


StrictMode = React.StrictMode

class MyApp extends App
    constructor: (props) ->
        super props
        @detectMobileDeferred = _.debounce(
            (() => @detectMobile()),
            config.POLLING.WINDOW_RESIZE)

        @onRouteChangeComplete = null
        @onRouteChangeStart = null
        @onRouteChangeError = null

        @loadingSetter = null

    @getInitialProps: ({ Component, router, ctx }) ->
        { store, query, res, req, ctx... } = ctx
        isServer = req?
        cache = if isServer then req?.cache else null
        blendToken = query.blendToken

        api = API.create({ isServer, store, query, res, req, blendToken, cache })

        authenticated = false
        user = store.getState().spotify?.user
        if user?
            authenticated = true
        else
            authenticatedRes = await api.isAuthenticated()
            if authenticatedRes.ok
                authenticated = authenticatedRes.data.authenticated
            else
                { problem, data, sentryEventId } = authenticatedRes
                await return { error: { problem, data, sentryEventId } }
            isPublicPage = router.pathname in config.UNAUTHORIZED_PAGES
            isStaticRoute = router.pathname.match(/\/static\/.+/)?

            if authenticated is true
                userRes = await api.getUserDetails()
                if not userRes.ok
                    { problem, data, sentryEventId } = userRes
                    await return { error: { problem, data, sentryEventId } }
            else if not isPublicPage and not isStaticRoute
                redirect({target: '/', res, isServer})
                await return {}

            user = userRes?.data

        ctx = { store, query, res, req, authenticated, user, isServer, api, ctx... }
        pageProps = {}
        if Component.getInitialProps
            pageProps = await Component.getInitialProps(ctx) ? {}

        if pageProps.error?.problem?
            { problem, data, sentryEventId } = pageProps.error
            pageProps = {
                pageProps...
                error: { problem, data, sentryEventId }
            }

        fetchedProps = {
            user: user
            (pageProps.fetched ? {})...
        }

        initialProps = {
            config.DEFAULT_PAGE_PROPS...
            (config.PAGE_PROPS[router.pathname] ? {})...
            (pageProps.initial ? {})...
        }

        return {
            authenticated
            pageProps...
            fetched: fetchedProps
            initial: initialProps
        }

    detectMobile: ->
        @props.batchActions([
            UIActions.setWindowWidth(window.innerWidth)
            UIActions.setMobile(window.innerWidth <= config.WIDTH.mobile)
            UIActions.setMediumScreen(window.innerWidth <= config.WIDTH.medium)
        ])

    componendDidCatch: (error, info) ->
        Sentry.configureScope((scope) ->
            scope.setExtra(errorInfo: JSON.stringify(info)))
        Sentry.captureException(error)

    componentWillUnmount: ->
        window.removeEventListener('resize', @detectMobileDeferred)
        Router.events.off("routeChangeComplete", @onRouteChangeComplete)
        Router.events.off("routeChangeStart", @onRouteChangeStart)
        Router.events.off("routeChangeError", @onRouteChangeError)

    componentDidUpdate: (prevProps, prevState, snapshot) ->
        prevUser = prevProps.fetched?.user
        user = @props.fetched?.user
        if user? and user.lastFetch > (prevUser?.lastFetch ? 0) and
        not _.isEqual(prevUser, user)
            @props.setUser(user)

    componentDidMount: ->
        if @props.user?
            return

        @detectMobile()
        window.addEventListener('resize', @detectMobileDeferred)

        @addRouteEventListeners()

        if @props.error
            @props.setErrorMessage(@props.error)
            return

        actions = [
            UIActions.setState(@props.initial)
        ]

        if @props.fetched?.user?
            user = @props.fetched.user
            actions.push(SpotifyActions.setUser(user))
            mediumUsage = not (
                user.firstPlay and
                user.firstBlend and
                user.firstDislike and
                user.secondPlaylist
            )

        @props.batchActions(actions)

    addRouteEventListeners: ->
        @onRouteChangeError = (err, url) =>
            @props.setUIState({
                circularMenuOpen: false
                loading: false
            })

            if @loadingSetter?
                clearTimeout(@loadingSetter)

        @onRouteChangeComplete = (url) =>
            pathname = url.match(config.PATHNAME_PATTERN)?[0]
            pageProps = config.PAGE_PROPS[pathname] ? {}
            @props.batchActions([
                UIActions.setState({
                    config.DEFAULT_PAGE_PROPS...
                    pageProps...
                    loading: false
                })
            ])

            if @loadingSetter?
                clearTimeout(@loadingSetter)

        @onRouteChangeStart = (url) =>
            if Router.pathname is '/blend' and url isnt '/blend'
                window.location.href = url

            @props.setUIState({
                circularMenuOpen: false
                loading: true
            })

            if @loadingSetter?
                clearTimeout(@loadingSetter)
            @loadingSetter = setTimeout((() => @props.setUIState(loading: false)), 10000)


        Router.events.on("routeChangeError", @onRouteChangeError)
        Router.events.on("routeChangeComplete", @onRouteChangeComplete)
        Router.events.on("routeChangeStart", @onRouteChangeStart)

    render: ->
        { Component, store, props... } = @props
        defaultPageProps = config.DEFAULT_PAGE_PROPS
        icon = props.icon ? props.initial?.icon ? defaultPageProps.icon
        color = "#{ props.color ? props.initial?.color ? defaultPageProps.color }"
        title = props.title ? props.initial?.title ? defaultPageProps.title
        description = (
            props.description ?
            props.initial?.description ?
            defaultPageProps.description
        )
        spotifyPremium = props.user?.spotifyPremium ? props.fetched?.user?.spotifyPremium
        manifest = props.manifest ? props.initial?.manifest ? defaultPageProps.manifest

        <StrictMode>
            <Container>
                <Layout
                    authenticated={ props.authenticated }
                    spotifyPremium={ spotifyPremium }
                    fillWindow>
                    <Head>
                        <title> { title ? 'Noiseblend' } </title>
                        <meta name="description" content={ description } />
                        <meta name="theme-color" content={ color } />
                        <meta
                            name="msapplication-TileColor"
                            content={ color } />
                        <meta
                            name="msapplication-TileImage"
                            content="
                                #{ config.STATIC }/img/icons/\
                                #{ icon }/#{ icon }\
                                -apple-144x144.png\
                                ?v=#{ config.ICON_VERSION }" />
                        <link href={ manifest } rel='manifest' />
                        {
                            links = for platform, sizes of config.ICONS
                                for size in sizes
                                    <link
                                        key="#{ platform }-#{ size }"
                                        rel={if platform is 'apple'
                                            'apple-touch-icon'
                                        else
                                            'icon'
                                        }
                                        sizes="#{ size }x#{ size }"
                                        href="
                                            #{ config.STATIC }/img/icons/\
                                            #{ icon }/#{ icon }-#{ platform }-\
                                            #{ size }x#{ size }.png\
                                            ?v=#{ config.ICON_VERSION }" />
                            links.reduce((acc, v) -> acc.concat(v))
                        }
                        <AppleLaunchScreenLinks topic={ icon } />
                    </Head>
                    <Component { props... } />
                </Layout>
            </Container>
        </StrictMode>



mapStateToProps = ({ ui, auth, spotify }) ->
    color        : ui.color
    description  : ui.description
    errorMessage : spotify.errorMessage
    icon         : ui.icon
    manifest     : ui.manifest
    mobile       : ui.mobile
    sentryEventId: spotify.sentryEventId
    title        : ui.title
    user         : spotify.user

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    setErrorMessage: (error) -> dispatch(SpotifyActions.setErrorMessage(error))
    setUser: (user) -> dispatch(SpotifyActions.setUser(user))
    setUserDetails: (details) -> dispatch(SpotifyActions.setUserDetails(details))
    setUIState: (ui) -> dispatch(UIActions.setState(ui))
    setCircularMenuOpen: (open) -> dispatch(UIActions.setCircularMenuOpen(open))


export default withRedux(
    createStore
    debug: config.REDUX_DEBUG
)(connect(mapStateToProps, mapDispatchToProps)(MyApp))
