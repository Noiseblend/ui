import TextButton from '~/components/textButton'

import { X, XCircle } from '~/styles/icons'


CloseButton = ({
    className, id, style, children, onClose, color,
    circle = true, mobile, props...
}) ->
    <TextButton
        className="close-button #{ className ? '' }"
        id={ id }
        onClick={ (e) ->
            e.stopPropagation()
            onClose()
        }
        style={{
            position: 'fixed'
            top: if mobile then 25 else 30
            left: if mobile then 25 else 30
            zIndex: 2
            style...
        }}>
        {if circle
            <XCircle
                size={ if mobile then 30 else 40 }
                color="#{ color }"
                className='close-icon'
                { props... }
            />
        else
            <X
                size={ if mobile then 30 else 40 }
                color="#{ color }"
                className='close-icon'
                { props... }
            />
        }
        <style global jsx>{"""#{} // stylus
            .close-button:focus
                filter: brightness(150%)
                transform: scale(1.1)
                ease-out: 0.25s color 'transform' 'filter'
        """}</style>
    </TextButton>

export default CloseButton
