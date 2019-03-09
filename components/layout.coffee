import React from 'react'
import { connect } from 'react-redux'

import { withRouter } from 'next/router'

import Alert from '~/components/alert'
import BackButton from '~/components/backButton'
import Brand from '~/components/brand'
import ImageBackground from '~/components/imageBackground'
import Navbar from '~/components/navbar'
import RoundedButton from '~/components/roundedButton'

import SpotifyActions from '~/redux/spotify'

import colors from '~/styles/colors'

import config from '~/config'

AlertFactory = (type) ->
    typeTitleCase = "#{ type[0].toUpperCase() }#{ type[1..] }"
    messageKey = "#{ type }Message"
    connect(
        ({ spotify }) ->
            type: type
            isOpen: spotify[messageKey]?
            sentryEventId: if type is 'error' then spotify.sentryEventId else null
            children: [spotify[messageKey]]
        (dispatch) ->
            toggle: () -> dispatch(SpotifyActions["set#{ typeTitleCase }Message"](null))
    )(Alert)

ErrorAlert = AlertFactory('error')
InfoAlert = AlertFactory('info')
SuccessAlert = AlertFactory('success')

Layout = (props) ->
    bg = config.PAGE_PROPS[props.router.pathname]?.background ? colors.BLACK.s()
    background = "#{ bg }"
    height = props.height ? 'inherit'
    width = props.width ? 'inherit'

    minHeight = props.minHeight ? if props.fillWindow
        '100vh'
    else
        'inherit'
    minWidth = props.minWidth ? if props.fillWindow
        '100vw'
    else
        'inherit'

    <div
        className="
            layout-container
            #{ props.className ? '' }"
        style={ props.style }>
        <ErrorAlert />
        <InfoAlert />
        <SuccessAlert />
        <style global jsx>{"""#{} // stylus
            html
            body
            body > #__next
            body > div[data-reactroot]
            .layout-container
                height #{ height }
                width #{ width }
                min-height #{ minHeight }
                min-width #{ minWidth }

            html
            body
                background-size cover
                background: #{ background }
        """}</style>
        { props.children }
        <Navbar />
        <BackButton
            id='app-back-button'
            color={ colors.WHITE }
            backgroundColor={ colors.PITCH_BLACK.alpha(0.8) }
        />
        <style jsx>{"""#{} // stylus
            .error-container
                color black + 5%
        """}</style>
        <style global jsx>{"""#{} // stylus
            #app-back-button
                display none !important
                @media (display-mode: fullscreen), (display-mode: standalone)
                    display flex !important
        """}</style>
    </div>


export default withRouter(Layout)
