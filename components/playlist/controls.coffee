import React from 'react'

import DevicesDrawer from '~/components/devicesDrawer'
import PlayButton from '~/components/playButton'

import colors from '~/styles/colors'

import config from '~/config'


Controls = (props) ->
    <div
        id={ props.id }
        className='flex-column-center controls'
        style={ props.style }>
        <div
            style={{
                width: '100%'
                props.buttonContainerStyle...
            }}
            className='flex-center button-container'>
            <PlayButton onClick={ props.onPlayButtonClick } />
        </div>
        <DevicesDrawer
            playOn={ props.playOn }
            close={ props.closeDrawer }
            style={ overflow: 'hidden' } />
        <style global jsx>{"""#{} // stylus
            .controls::-webkit-scrollbar
                display none
        """}</style>
        <style jsx>{"""#{} // stylus
            .button-container
                height 80px
                background linear-gradient(to top, black 0%, transparent 100%)

            .controls
                overflow hidden
                z-index 1
        """}</style>
    </div>

export default Controls
