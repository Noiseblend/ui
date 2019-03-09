import { classif } from '~/lib/util'

import colors from '~/styles/colors'

import config from '~/config'


ToggleTextButton = ({
    onColor = colors.RED, offColor = colors.GRAY, disabled,
    shadow, shadowBlur = 4, toggled, width, onClick, props...
}) ->
    disabledColor = if offColor.isLight()
        offColor.darken(0.2)
    else
        offColor.lighten(0.2)
    <button
        className="
            toggle-text-button
            #{ classif(disabled, 'disabled') }
            #{ classif(toggled, 'toggled') }
            #{ props.className ? '' }"
        style={{
            textShadow: "0 0 6px #{ onColor }" if toggled and shadow
            props.style...
        }}
        disabled={ disabled }
        onClick={ onClick if not disabled }>
        { props.children }
        <style jsx>{"""#{} // stylus
            .toggle-text-button
                outline none
                font-weight bold
                ease-out 0.25s color 'text-shadow' 'filter'
                background-color transparent
                box-shadow none
                border none
                color #{ offColor }
                cursor pointer

            .toggle-text-button.toggled
                color #{ onColor }

            .toggle-text-button:hover
                color #{ offColor.mix(onColor) }
                text-shadow 0 0 #{ shadowBlur }px #{ offColor.mix(onColor) }

            .toggle-text-button.toggled
                color #{ onColor }
                text-shadow 0 0 #{ shadowBlur }px #{ offColor.mix(onColor) }

            .toggle-text-button.disabled,
            .toggle-text-button:hover.disabled,
            .toggle-text-button:focus.disabled
                filter none
                cursor auto
                box-shadow none
                text-shadow none
                background-color transparent
                color #{ disabledColor }

        """}</style>
    </button>

export default ToggleTextButton
