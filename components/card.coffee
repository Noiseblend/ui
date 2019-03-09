import React from "react"

import colors from "~/styles/colors"
import {
    Activity
    CloudSnow
    Cpu
    Disc
    Gift
    Globe
    Music
    Radio
    Sliders
    TrendingUp
    User
} from "~/styles/icons"

import config from "~/config"

getIcon = (icon, props = {}) ->
    if icon?
        React.createElement(icon, { size: 45, className: "card-icon", props... })

Card = ({
    backgroundColor
    color
    hoverTextColor
    hoverIconColor
    iconColor
    className
    icon
    style
    title
    children
    size = 180
    iconProps = {}
    useFill = false
    props...
}) ->
    backgroundColor ?= colors.BLACK
    iconColor ?=
        if backgroundColor.isLight()
            colors.BLACK
        else
            colors.WHITE
    hoverTextColor ?=
        if color.contrast(colors.BLACK) > 2
            colors.BLACK
        else
            colors.WHITE
    hoverIconColor ?=
        if iconColor.contrast(color) > 10
            iconColor
        else
            hoverTextColor
    iconProperty =
        if useFill
            "fill"
        else
            "stroke"

    <button
        style={{
            backgroundColor: backgroundColor
            style...
        }}
        className={ "
            font-heading
            card-button
            #{ className ? "" }" }
        {props...}>
        <div style={backgroundColor: color} className="bg-reveal" />
        <div
            className='
                d-flex
                flex-column
                align-items-center
                justify-content-center
                button-content'>
            { getIcon(icon, iconProps) }
            { children }
            <div style={color: color} className="font-heading card-title">
                { title }
            </div>
        </div>
        <style jsx>{ """#{} // stylus
            .card-button
                .button-content
                    :global(.card-icon)
                        #{ iconProperty }: #{ iconColor } !important
                &:hover
                &:focus
                    box-shadow 0 3px 40px #{ color.alpha(0.7) }

                    .button-content
                        .card-title
                            color #{ hoverTextColor } !important
                        :global(.card-icon)
                            #{ iconProperty }: #{ hoverIconColor } !important
        """ }</style>
        <style jsx>{ """#{} // stylus
            .card-button
                cursor: pointer
                outline none
                overflow hidden
                position: relative
                border none
                border-radius 6px
                width #{ size }px
                height #{ size }px
                min-width #{ size }px
                min-height #{ size }px
                font-size 24px
                transition:
                    border-radius 0.3s easeOutExpo,
                    color 0.25s easeOutCubic,
                    box-shadow 0.2s !important

                bg-reveal 1000px bottom right 'hover' focus


                &:hover
                &:focus
                    border-radius 0
                    transition:
                        border-radius 0.3s easeOutExpo 0.05s,
                        box-shadow 0.1s ease-in !important

                    :global(.card-icon)
                        ease-out 'transform' stroke fill
                        transform translateY(-5px)

                .button-content
                    overflow hidden
                    position relative

                    .card-title
                        transition color 0.7s easeOutExpo

                    :global(.card-icon)
                        ease-out cubic 0.4s 'transform'
                        margin .5rem
        """ }</style>
    </button>

export default Card
