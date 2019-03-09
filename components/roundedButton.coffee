import { classif } from '~/lib/util'

import colors from '~/styles/colors'
import { Loader } from '~/styles/icons'

import config from '~/config'


RoundedButton = ({
    color = colors.WHITE, textColor, disabled, loading,
    width, onClick, hoverColor, hoverTextColor, props...
}) ->
    hoverColor = (hoverColor ? color)
    textColor = textColor ? if color.isLight()
        colors.BLACK
    else
        colors.WHITE
    hoverTextColor = hoverTextColor ? if hoverColor.isLight()
        colors.BLACK
    else
        colors.WHITE

    <button
        className="
            d-flex justify-content-center
            align-items-center
            rounded-button
            #{ classif(disabled or loading, 'disabled') }
            #{ props.className ? '' }"
        disabled={ disabled or loading }
        style={{
            minWidth: width
            props.style...
        }}
        onClick={ onClick if not (disabled or loading) }>
        { if not loading
            props.children
        else
            <Loader className='spin-alternate-fast' />
        }
        <style jsx>{"""#{} // stylus
            .rounded-button
                outline none
                ease-out 0.25s background-color color 'box-shadow' 'filter' width height 'transform'
                background-color #{ color }
                color #{ textColor }
                border-radius 100px
                cursor pointer
                box-shadow 0 2px 10px alpha(black, 0.4)
                border-color transparent
                padding 1rem 3rem

                &:hover,
                &:focus
                    filter: brightness(#{ if color.isLight() then '115%' else '130%' })
                    box-shadow 0 3px 10px alpha(black, 0.5)
                    background-color #{ hoverColor ? color }
                    color #{ hoverTextColor }

                &.disabled,
                &:hover.disabled,
                &:focus.disabled
                    filter: none
                    cursor auto
                    box-shadow none
                    background-color transparent
                    color #{ color.desaturate(0.3) }
                    border 1px solid #{ color.desaturate(0.3) }

        """}</style>
    </button>

export default RoundedButton
