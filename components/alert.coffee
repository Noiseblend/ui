import React from "react"

import RoundedButton from "~/components/roundedButton"
import TextButton from "~/components/textButton"

import Sentry from "~/lib/sentry"

import colors from "~/styles/colors"
import { X } from "~/styles/icons"

import config from "~/config"

color = (type) ->
    switch type
        when "error" then colors.RED
        when "warning" then colors.YELLOW
        when "info" then colors.BLUE
        when "success" then colors.WHITE
        else colors.WHITE

computeTextColor = (type, bgColor) ->
    switch type
        when "error" then colors.WHITE
        when "warning" then colors.BLACK
        when "info" then colors.WHITE
        when "success" then colors.YELLOW.rotate(-5)
        else
            if bgColor.isLight()
                colors.BLACK
            else
                colors.WHITE

Alert = ({ isOpen, type, toggle, props... }) ->
    bgColor = color(type)
    textColor = computeTextColor(type, bgColor)
    <div
        className={ "
            d-flex flex-grow-1 px-2 px-md-4 py-3
            justify-content-between align-items-center
            alert #{ props.className ? "" }" }
        id={ props.id ? "" }
        style={{
            zIndex: config.ZINDEX.alert
            transform: "translateY(#{ if isOpen then 0 else -500 }px)"
            backgroundColor: bgColor
            color: textColor
            fontWeight: "500"
            fontSize: "1.1rem"
            props.style...
        }}>
        <div className="flex-grow-1 message">{ props.children }</div>
        <TextButton
            className="d-flex align-items-center"
            hoverColor={ textColor.negate() }
            color={ textColor }
            onClick={ toggle }>
            <X size={ 20 } />
        </TextButton>
        <style jsx>{ """#{} // stylus
            .alert
                fixed top left
                width 100vw
                min-height 50px
                ease-out 0.4s expo color background-color 'transform'
                border-radius 0
                bottom-shadow 3px 10px

                .message
                    height 100%
        """ }</style>
    </div>

export default Alert
