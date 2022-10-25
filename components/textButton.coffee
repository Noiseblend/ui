import { classif } from '~/lib/util'

import colors from '~/styles/colors'

import config from '~/config'


TextButton = ({
    color = colors.WHITE, disabledColor, hoverColor,
    disabled, width, onClick, className, style,
    children, shadow, props...
}) ->
    <button
        className="
            p-0 text-button
            #{ classif(disabled, 'disabled') }
            #{ className ? '' }"
        disabled={ disabled }
        style={ style }
        onClick={ onClick if not disabled }
        { props... }>
        { children }
        <style jsx>{"""#{} // stylus
            button
                -webkit-appearance none
                outline none
                ease-out 0.25s color 'filter'
                background-color transparent
                color #{ color }
                cursor pointer
                border-color transparent
                border none
                box-shadow none

                &:hover
                    filter: brightness(140%) \
                        #{ if shadow
                           "drop-shadow(0 0 #{ shadow ? 0 }px #{ hoverColor ? color })"
                        else
                            ''}
                    color #{ hoverColor ? color }

                &.disabled,
                &:hover.disabled,
                &:focus.disabled
                    filter: none
                    cursor auto
                    box-shadow none
                    color #{ disabledColor ? color.desaturate(0.4) }
        """}</style>
    </button>

export default TextButton
