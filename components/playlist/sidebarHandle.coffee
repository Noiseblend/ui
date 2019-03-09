import colors from '~/styles/colors'
import { ArrowLeft } from '~/styles/icons'

import config from '~/config'

SidebarHandle = (props) ->
    bg = props.backgroundColor ? colors.WHITE
    txt = props.color ? colors.BLACK
    <div
        style={{
            cursor: 'pointer'
            width: props.size / 2
            height: props.size
            zIndex: config.ZINDEX.normal
            borderTopLeftRadius: props.size / 2
            borderBottomLeftRadius: props.size / 2
            backgroundColor: if props.sidebarHidden then bg else bg.negate()
            transform: "
                rotateY(#{ if props.sidebarHidden then 0 else 0.5 }turn)
                translateX(#{ if props.sidebarHidden then 0 else (-props.size / 2) }px)
                "
            transition: '
                transform 0.3s var(--ease-out-expo) 0.2s,
                background-color 0.3s var(--ease-out-expo) 0.2s
                '
            props.style...
        }}
        id='handle'
        onClick={ props.onClick }
        className='d-flex justify-content-center align-items-center handle'>
        <ArrowLeft
            color="#{ if props.sidebarHidden then txt else txt.negate() }"
            className='arrow' />
        <style global jsx>{"""#{} // stylus
            .handle
                .arrow
                    margin-left 3px
                    transition stroke 0.2s easeOutExpo
                &:hover .arrow
                    stroke #{ props.hoverColor ? colors.PEACH } !important
        """}</style>
    </div>

export default SidebarHandle
