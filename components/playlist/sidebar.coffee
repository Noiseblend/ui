import '~/lib/str'
import React from 'react'
import FlipMove from 'react-flip-move'
import { connect } from 'react-redux'

import _ from 'lodash'

import NativeSlider from '~/components/nativeSlider'
import ToggleTextButton from '~/components/toggleTextButton'

import { classif } from '~/lib/util'

import PlaylistActions from '~/redux/playlists'
import RecommendationActions from '~/redux/recommendations'
import UIActions from '~/redux/ui'

import colors from '~/styles/colors'

import config from '~/config'

import KeySelector from './keySelector'
import ResetTuningButton from './resetTuningButton'
import SidebarHandle from './sidebarHandle'
import SortableAttribute from './sortableAttribute'


ARROW_SIZE = 28
DEFAULT_WIDTH = 380
HANDLE_SIZE = 60

apply = ({ artists, batchActions }) ->
    batchActions([
        RecommendationActions.applyTuningAsync({ seedArtists: artists })
    ])
    # batchActions([
    #     RecommendationActions.applyTuning({ seedArtists: artists })
    #     PlaylistActions.applyOrder()
    # ])
applyDeferredTuning = _.debounce(apply, config.POLLING.APPLY_TUNING)

setAttributeValue = (attribute, value, { batchActions, tuneableAttributes }) ->
    batchActions([
        RecommendationActions.setTuneableAttribute(attribute, value)
        PlaylistActions.setModified()
    ])

setAttributeOrder = (attribute, order, { batchActions }, reset = false) ->
    batchActions([
        PlaylistActions.setOrder(attribute, order)
        if reset
            PlaylistActions.resetPlaylist()
        else
            PlaylistActions.applyOrder()
    ])

onSelect = (props, key) ->
    if props.activeMode is key
        props.onChange(null)
    else
        props.onChange(key)

onChange = (key, value, props) ->
    if key is 'key'
        oldValue = props.tuneableAttributes?.key
        if value isnt oldValue
            setAttributeValue(key, value, props)
            applyDeferredTuning(props)
    else if key is 'mode'
        oldValue = props.tuneableAttributes?.mode
        if value isnt oldValue
            setAttributeValue(key, value, props)
            applyDeferredTuning(props)
    else if Array.isArray(value)
        oldValue = props.tuneableAttributes?[key]
        { min, max } = config.TUNEABLE_ATTRIBUTES[key]

        shouldSet = if oldValue?
            oldValue[0] isnt value[0] or oldValue[1] isnt value[1]
        else
            value[0] isnt min or value[1] isnt max

        if shouldSet
            if value[0] is min and value[1] is max
                setAttributeValue(key, null, props)
            else
                setAttributeValue(key, value, props)
            applyDeferredTuning(props)
    else
        value = +value
        oldValue = props.tuneableAttributes?[key]
        { min, max } = config.TUNEABLE_ATTRIBUTES[key]
        middle = (min + max) / 2

        if value isnt (oldValue ? middle)
            if value is middle
                setAttributeValue(key, null, props)
            else
                setAttributeValue(key, value, props)
            applyDeferredTuning(props)


setOrder = (attribute, direction, { order, props... }) ->
    reset = false
    if order[attribute] is direction
        notNull = (k for k, v of order when v?)
        reset = notNull.length is 0 or
            notNull.length is 1 and
            notNull[0] is attribute
        setAttributeOrder(attribute, null, props, reset = reset)
    else
        setAttributeOrder(attribute, direction, props, reset = reset)

getTuneableAttributes = (props) ->
    attrs = (
        {
            notSortable: false
            name: props.tuneableAttributes?[key]?.name ? key.toTitleCase()
            key: key
            direction: props.order?[key] ? 0
            value: props.tuneableAttributes?[key]
            config.TUNEABLE_ATTRIBUTES[key]...
        } for key in Object.keys(config.TUNEABLE_ATTRIBUTES)
    )
    return _.orderBy(attrs, ['direction'], ['asc'])

AttributeTitle = ({ className, id, style, attr, props... }) ->
    <h6
        id={ id }
        style={{
            color: colors.BLACK.lighten(0.2)
            style...
        }}
        className="
            text-center mb-3 mx-2
            #{ className ? '' }">
        { if attr.unit?
            [
                <span key={ 1 }>{ attr.name }</span>
                <div key={ 2 } style={
                    fontSize: '0.8rem'
                    color: colors.LIGHT_GRAY
                    marginTop: 2
                }>
                    ({ attr.unit })
                </div>
            ]
          else
              attr.name }
    </h6>

class TuneableAttribute extends React.PureComponent
    render: ->
        {
            className, id, style, key, order, sliderWidth, artists,
            direction, playlist, attr, tuning, batchActions, tuneableAttributes, props...
        } = @props
        <div
            key={ key }
            id={ id }
            style={ style }
            className="
                w-100 d-flex flex-column
                justify-content-center
                align-items-center
                tuning-item
                #{ className ? '' }"
            ref={ props.ref }>
            {if attr.notSortable
                <AttributeTitle attr={ attr } />
            else
                <SortableAttribute
                    disabled={ tuning }
                    dark={ true }
                    key={ "#{ attr.key }-attr" }
                    name={ attr.name }
                    unit={ attr.unit }
                    setOrder={ (direction) ->
                        setOrder(attr.key, direction, { order, batchActions }) }
                    direction={ order[attr.key] }
                    arrowSize={ ARROW_SIZE } />
            }
            {if playlist?.discover
                <div className='tuning-slider'>
                    <NativeSlider
                        key={ "#{ attr.key }-slider" }
                        value={ attr.value ? ((attr.min + attr.max) / 2) }
                        min={ attr.min }
                        max={ attr.max }
                        step={ attr.step }
                        showMarks={ attr.key in ['durationMs', 'tempo'] }
                        showTooltip={ attr.key in ['durationMs', 'tempo'] }
                        style={ width: "#{ sliderWidth }px" }
                        modified={ attr.value? }
                        disabled={ not playlist?.discover or tuning }
                        onChange={(value) ->
                            onChange(
                                attr.key, value,
                                { artists, batchActions, tuneableAttributes }
                            )
                        } />
                </div>
            }
            <style jsx>{"""#{} // stylus
                .tuning-slider
                    padding-top 1rem
                    padding-bottom .5rem
                .tuning-item
                    min-height 70px
                    padding-top 1rem
                    padding-bottom 1rem
                    margin-bottom 1rem
                    background-color white
                    border-radius 10px
            """}</style>
        </div>

ModeSelector = (props) ->
    accentColor = if props.dark then colors.PEACH else colors.MAGENTA
    grayColor = if props.dark then colors.LIGHT_GRAY.alpha(0.7) else colors.DARK_GRAY
    <div>
        <div className='
            d-flex
            flex-row
            justify-content-between
            align-items-center
            key-row'>

            <h5
                key="major"
                className="
                    key-item
                    #{ classif(props.disabled, 'disabled') }
                    #{ classif(props.activeMode is 1, 'active') }"
                onClick={ () -> onSelect(props, 1) unless props.disabled }>
                Major
            </h5>
            <h5
                key="minor"
                className="
                    key-item
                    #{ classif(props.disabled, 'disabled') }
                    #{ classif(props.activeMode is 0, 'active') }"
                onClick={ () -> onSelect(props, 0) unless props.disabled }>
                Minor
            </h5>

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


class TuneableKey extends React.PureComponent
    render: ->
        {
            className, id, style, children, tuning, order,
            tuneableAttributes, rowWidth, props...
        } = @props
        <div
            id={ id }
            style={ style }
            className="
                d-flex flex-column
                justify-content-center
                align-items-center
                tuning-item
                #{ className ? '' }"
            ref={ props.ref }>
            <SortableAttribute
                disabled={ tuning }
                dark={ true }
                key="key-attr"
                name="Key"
                setOrder={ (direction) ->
                    setOrder("key", direction, { order, props... }) }
                direction={ order["key"] }
                arrowSize={ ARROW_SIZE } />

            <div className='key-selector'>
                <KeySelector
                    disabled={ tuning }
                    dark={ true }
                    rowWidth={ rowWidth }
                    onChange={ (key) -> onChange('key', key, props) }
                    activeKey={ tuneableAttributes?.key } />
            </div>
            <div className='mode-selector'>
                <ModeSelector
                    disabled={ tuning }
                    dark={ true }
                    rowWidth={ rowWidth }
                    onChange={ (mode) -> onChange('mode', mode, props) }
                    activeMode={ tuneableAttributes?.mode } />
            </div>
            <style jsx>{"""#{} // stylus
                .key-selector
                    padding-top 1rem

                .tuning-item
                    min-height 70px
                    padding-top 1rem
                    padding-bottom 1rem
                    margin-bottom 1rem
                    background-color white
                    border-radius 10px
            """}</style>
        </div>


PlaylistSidebar = (props) ->
    sidebarX = if props.hidden
        Math.max(-props.width, -props.windowWidth)
    else
        0
    sliderWidth = props.width - props.width / 3
    attrs = getTuneableAttributes(props)
    <div
        style={{
            position: 'fixed'
            top: 0
            zIndex: 1
            right: sidebarX if props.windowWidth > props.width
            left: -sidebarX - (HANDLE_SIZE / 2) if props.windowWidth <= props.width
            transition: 'right 0.3s var(--ease-out-expo), left 0.3s var(--ease-out-expo)'
        }}
        id='sidebar-container'
        className='
            d-flex
            flex-row
            justify-content-center
            align-items-center
            h-100vh
            sidebar-container'>
        <SidebarHandle
            sidebarHidden={ props.hidden }
            size={ HANDLE_SIZE }
            backgroundColor={ colors.WHITE }
            color={ colors.BLACK }
            onClick={ () -> props.toggleSidebar() } />
        <aside
            id={ props.id }
            style={{
                width: props.width
                minWidth: props.width
                (props.style ? {})...
            }}
            className="
                d-flex
                flex-column
                justify-content-start
                align-items-center
                sidebar
                #{ classif props.hidden, 'sidebar-hidden' }">
            <h1 className='text-center mb-5'>Tuning</h1>
            <div className='
                d-flex
                flex-column
                justify-content-center
                align-items-center
                sidebar-content'>
                <FlipMove
                    duration={ 300 }
                    staggerDelayBy={ 150 }
                    enterAnimation={
                        from:
                            transform: 'rotateX(180deg)'
                            opacity: 0.1
                        to:
                            transform: ''
                    }
                    leaveAnimation={
                        from:
                            transform: ''
                        to:
                            transform: 'rotateX(-120deg)'
                            opacity: 0.1
                    }
                    easing='ease-out'
                    style={ width: props.width - 60 }>
                    <TuneableKey
                        style={ width: props.width - 60 }
                        rowWidth={ sliderWidth }
                        { props... }
                    />

                    {attrs[...3].map((attr, i) ->
                        shouldShow = (
                            not attr.notSortable or
                            props.playlist?.discover)
                        if shouldShow
                            <TuneableAttribute
                                key={ "#{ attr.key }-item" }
                                sliderWidth={ sliderWidth }
                                attr={ attr }
                                { props... }
                            />
                    )}
                </FlipMove>
                <ToggleTextButton
                    onColor={ colors.DARK_GRAY }
                    offColor={ colors.PITCH_BLACK }
                    onClick={ () ->
                        props.setShowMoreAttributes(not props.showMoreAttributes)
                    }
                    shadowBlur={ 0 }
                    toggled={ props.showMoreAttributes }>
                    {if props.showMoreAttributes
                        'Less attributes ▴'
                    else
                        'More attributes ▾'
                    }
                </ToggleTextButton>
                <FlipMove
                    duration={ 300 }
                    staggerDelayBy={ 150 }
                    enterAnimation='elevator'
                    leaveAnimation='elevator'
                    easing='ease-out'
                    style={
                        width: props.width - 60
                        height: if props.showMoreAttributes then 'auto' else 0
                        overflow: 'hidden'
                    }>
                    {attrs[3..].map((attr, i) ->
                        shouldShow = (
                            not attr.notSortable or
                            props.playlist?.discover)
                        if shouldShow
                            <TuneableAttribute
                                key={ "#{ attr.key }-item" }
                                sliderWidth={ sliderWidth }
                                attr={ attr }
                                { props... }
                            />
                    )}
                </FlipMove>
                <ResetTuningButton disabled={ props.tuning } />
            </div>
            <style jsx>{"""#{} // stylus
                .sidebar-content
                    margin-bottom 70px
                    width 100%
                    min-height min-content

                .sidebar
                    -webkit-overflow-scrolling touch
                    overflow-y scroll
                    overflow-x hidden
                    min-height 100vh
                    max-height 100vh
                    height 100vh
                    border-left solid 1px alpha(maroon, 0.1)
                    background-color #{ colors.WHITE.darken(0.1) }
                    color black
                    padding 1rem
            """}</style>
        </aside>
    </div>

mapStateToProps = (state) ->
    tuning: state.recommendations.present.tuning
    tuneableAttributes: state.recommendations.present.tuneableAttributes
    order: state.playlists.present.order
    hidden: state.playlists.present.sidebarHidden
    mobile: state.ui.mobile
    windowWidth: state.ui.windowWidth
    showMoreAttributes: state.ui.showMoreAttributes

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    setTuneableAttribute: (attribute, value) ->
        dispatch(RecommendationActions.setTuneableAttribute(attribute, value))
    setOrder: (attribute, direction) ->
        dispatch(PlaylistActions.setOrder(attribute, direction))
    resetPlaylist: () ->
        dispatch(PlaylistActions.resetPlaylist())
    applyTuning: (artists) ->
        dispatch(RecommendationActions.applyTuning({ seedArtists: artists }))
    applyOrder: () ->
        dispatch(PlaylistActions.applyOrder())
    toggleSidebar: () ->
        dispatch(PlaylistActions.toggleSidebar())
    setShowMoreAttributes: (showMoreAttributes) ->
        dispatch(UIActions.setShowMoreAttributes(showMoreAttributes))

PlaylistSidebar.defaultProps =
    width: DEFAULT_WIDTH


export default connect(mapStateToProps, mapDispatchToProps)(PlaylistSidebar)
