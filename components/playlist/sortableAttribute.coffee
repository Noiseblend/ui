import { Tooltip } from 'react-tippy'

import { classif } from '~/lib/util'

import colors from '~/styles/colors'
import { ArrowDownCircle, ArrowUpCircle } from '~/styles/icons'

import config from '~/config'

Msg = ({ attr, direction }) ->
    <span>
        Move tracks with more <b>{ attr }</b> to the <b>{ direction }</b>
        <style jsx>{"""#{} // stylus
            b
                color yellow
        """}</style>
    </span>

SortableAttribute = (props) ->
    accentColor = if props.dark then colors.PEACH else colors.MAGENTA
    grayColor = if props.dark then colors.LIGHT_GRAY.alpha(0.7) else colors.DARK_GRAY
    <div className='
        d-flex w-75
        justify-content-between
        align-items-center
        title-actions'>
        <Tooltip
            disabled={ props.disabled }
            trigger='mouseenter'
            position='top'
            size='regular'
            arrow
            html={ <Msg attr={ props.name } direction='bottom' /> }>
            <div
                className="
                    sort-icon
                    sort-down
                    #{ classif(props.disabled, 'disabled') }
                    #{ classif(props.direction is 1, 'active') }"
                onClick={ () -> props.setOrder(1) unless props.disabled }>
                <ArrowDownCircle size={ props.arrowSize } />
            </div>
        </Tooltip>
        <h6
            style={ color: colors.BLACK.lighten(0.2) }
            className='text-center mb-0 mx-2'>
          { if props.unit?
              [
                  <span key={ 1 }>{ props.name }</span>
                  <div key={ 2 } style={
                      fontSize: '0.8rem'
                      color: colors.LIGHT_GRAY
                      marginTop: 2
                  }>
                      ({ props.unit })
                  </div>
              ]
            else
                props.name }
        </h6>
        <Tooltip
            disabled={ props.disabled }
            trigger='mouseenter'
            position='top'
            arrow
            html={ <Msg attr={ props.name } direction='top' /> }>
            <div
                className="
                    sort-icon
                    sort-up
                    #{ classif(props.disabled, 'disabled') }
                    #{ classif(props.direction is -1, 'active') }"
                onClick={ () -> props.setOrder(-1) unless props.disabled }>
                <ArrowUpCircle size={ props.arrowSize } />
            </div>
        </Tooltip>
        <style jsx>{"""#{} // stylus
            .sort-icon.active
                color #{ accentColor }

            .sort-icon:not(.disabled):hover
                color #{ accentColor }
                filter drop-shadow(0 0 4px #{ accentColor })

            .sort-icon
                ease-out 0.3s color 'filter'
                cursor pointer
                color #{ grayColor }
                height #{ props.arrowSize }px
        """}</style>
    </div>

export default SortableAttribute
