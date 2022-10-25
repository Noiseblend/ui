import TextButton from '~/components/textButton'

import colors from '~/styles/colors'
import { PlayCircle } from '~/styles/icons'

PlayButton = (props) ->
    iconSize = 50
    <TextButton
        className='play-button'
        width={ 60 }
        color={ colors.WHITE }
        style={
            height: iconSize
            lineHeight: "#{ iconSize }px"
            padding: 0
        }
        onClick={ props.onClick }>
        <PlayCircle color={ colors.WHITE.rgb().string() } size={ iconSize } />
        <style global jsx>{"""#{} // stylus
            .play-button
                opacity 0.9
                ease-out 'transform' 'opacity'
                pointer-events all

                &:hover,
                &:focus
                    opacity 1
                    transform scale(1.05)
        """}</style>
    </TextButton>

export default PlayButton
