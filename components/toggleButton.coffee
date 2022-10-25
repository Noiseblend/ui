import { classif } from '~/lib/util'

import colors from '~/styles/colors'

import config from '~/config'


ToggleButton = ({
    color = colors.WHITE, textColor, disabled, className
    toggled, width, onClick, style, children, props...
}) ->
    textColor = textColor ? color

    toggledTextColor = if color.isLight()
        colors.BLACK
    else
        colors.WHITE

    <button
        className="
            toggle-button
            #{ classif(disabled, 'disabled') }
            #{ classif(toggled, 'toggled') }
            #{ className ? '' }"
        disabled={ disabled }
        style={{
            minWidth: width
            style...
        }}
        onClick={ onClick if not disabled }
        { props... }>
        { children }
        <style jsx>{"""#{} // stylus
            .toggle-button
                font-weight bold
                outline none
                ease-out 0.25s background-color color 'box-shadow' 'filter'
                background-color transparent
                border 2px solid #{ color }
                color #{ textColor }
                border-radius 6px
                cursor pointer
                padding 1rem 3rem

            .toggle-button.toggled
                background-color #{ color }
                color #{ toggledTextColor }

            .toggle-button:not(.toggled):hover
                background-color #{ color.alpha(0.2) }

            .toggle-button.toggled:hover
                filter brightness(120%)

            .toggle-button.disabled,
            .toggle-button:hover.disabled,
            .toggle-button:focus.disabled
                filter none
                cursor auto
                box-shadow none
                background-color transparent
                color #{ color.desaturate(0.3) }
                border 2px solid #{ color.desaturate(0.3) }

        """}</style>
    </button>

export default ToggleButton
