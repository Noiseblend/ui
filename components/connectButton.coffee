import React from 'react'

import RoundedButton from '~/components/roundedButton'

import colors from '~/styles/colors'


ConnectButton = ({ authenticating, onClick, props... }) ->
    <RoundedButton
        className='mt-5 px-1'
        id='connect-button'
        loading={ authenticating }
        color={ colors.GREEN }
        textColor={ colors.WHITE }
        style={
            fontWeight: 500
            height: 60
            width: if authenticating then 60 else 250
            padding: 0 if authenticating
        }
        onClick={ onClick }>
        Connect with Spotify
    </RoundedButton>

export default ConnectButton
