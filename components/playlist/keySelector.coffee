import { classif } from '~/lib/util'

import colors from '~/styles/colors'

import config from '~/config'


onSelect = (props, key) ->
    if props.activeKey is key
        props.onChange(null)
    else
        props.onChange(key)

keyName = (key) ->
    if key.length is 2
        <span className="sharp">{ key[0] }<sup className="sharp">{ key[1] }</sup></span>
    else
        key

KeySelector = (props) ->
    accentColor = if props.dark then colors.PEACH else colors.MAGENTA
    grayColor = if props.dark then colors.LIGHT_GRAY.alpha(0.7) else colors.DARK_GRAY
    <div>
        <div className='
            d-flex
            flex-row
            justify-content-between
            align-items-center
            key-row'>
            {config.KEY_MAPPING[...6].map((key, i) ->
                <h5
                    key={ key }
                    className="
                        key-item
                        #{ classif(props.disabled, 'disabled') }
                        #{ classif(props.activeKey is i, 'active') }"
                    onClick={ () -> onSelect(props, i) unless props.disabled }>
                    { keyName(key) }
                </h5>
            )}
        </div>
        <div className='
            d-flex
            flex-row
            justify-content-between
            align-items-center
            key-row'>
            {config.KEY_MAPPING[6..].map((key, i) ->
                <h5
                    key={ key }
                    className="key-item #{ classif(props.activeKey is i + 6, 'active') }"
                    onClick={ () -> onSelect(props, i + 6) unless props.disabled }>
                    { keyName(key) }
                </h5>
            )}
            <style global jsx>{"""#{} // stylus
                sup.sharp
                    width 11.2px

                .key-item
                    font-weight bold
                    margin-left .5rem
                    margin-right .5rem
                    ease-out 0.3s color 'text-shadow'
                    cursor pointer
                    color #{ grayColor }

                .key-item span.sharp
                    margin-right -11.2px

                .key-item.active
                    color #{ accentColor }

                .key-item:not(.disabled):hover
                    color #{ accentColor }
                    text-shadow 0 0 4px #{ accentColor }

                .key-row
                    width #{ props.rowWidth ? 250 }px
                    height 35px

            """}</style>
        </div>
    </div>

export default KeySelector
