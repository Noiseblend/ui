import React from 'react'

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'

import colors from '~/styles/colors'
import '~/styles/fontawesome'

BrandIcon = (props) ->
    brandColor = colors[props.brand.toUpperCase()]
    hoverColor = if brandColor.isLight()
        colors.BLACK
    else
        colors.WHITE
    <div
        className='d-flex justify-content-center align-items-center mx-2 brand-icon'
        onClick={ props.onClick }>
        <FontAwesomeIcon
            icon={ ['fab', props.brand] }
            id="#{ props.brand }-brand-icon" />
        <style global jsx>{"""#{} // stylus
            ##{ props.brand }-brand-icon
                transition color 0.15s easeOutCubic
                color #{ brandColor.lighten(0.6) }

                .brand-icon:hover &
                .brand-icon:focus &
                    color #{ hoverColor }
        """}</style>
        <style jsx>{"""#{} // stylus
            .brand-icon
                background-color pitchBlack
                cursor pointer
                font-size 20px
                transition all 0.2s ease-out
                box-shadow 0 2px 10px alpha(black, 0.7)
                border-radius 20px
                width 40px
                height 40px
                text-align center
                line-height 40px

                &:hover
                &:focus
                    box-shadow 0 4px 20px alpha(black, 0.9)
                    transform scale(1.1)
                    background-color #{ colors[props.brand.toUpperCase()] }
        """}</style>
    </div>

export default BrandIcon
