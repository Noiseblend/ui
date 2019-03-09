import React from 'react'
import { Tooltip } from 'react-tippy'

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'

import TextButton from '~/components/textButton'

import colors from '~/styles/colors'

import config from '~/config'
import '~/styles/fontawesome'


DislikeButton = ({
    message, backgroundColor, flip, color,
    onClick, className, style, props...
}) ->
    <div
        style={ style }
        className="dislike-button-container #{ className ? '' }"
        { props... }>
        <Tooltip
            disabled={ not message? }
            trigger='mouseenter'
            position='bottom'
            title={ message ? '' }>
            <TextButton
                color={ color }
                style={ backgroundColor: backgroundColor }
                className='dislike-button'
                onClick={ (e) ->
                    e.stopPropagation()
                    onClick() }>
                <FontAwesomeIcon icon='thumbs-down' flip={ flip } />
            </TextButton>
        </Tooltip>
        <style global jsx>{"""#{} // stylus
            button-size = 60px
            .dislike-button
                width button-size
                height button-size
                border-radius (button-size / 2) !important
                padding 10px !important

                transition all 0.15s linear
                opacity 1
                margin 0 6px 6px 0px
                box-shadow none
                line-height 1
                text-align center

                &.disabled
                    opacity 0 !important

                &:focus
                &:active
                &:hover
                    background-color red !important
                    box-shadow:
                        0 8px 16px alpha(black, 0.3),
                        0px 5px 8px alpha(black, 0.15)

        """}</style>
    </div>

export default DislikeButton
