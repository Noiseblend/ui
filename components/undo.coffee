import React from 'react'
import { connect } from 'react-redux'
import { ActionCreators } from 'redux-undo'

import RoundedButton from '~/components/roundedButton'

import { classif } from '~/lib/util'

import colors from '~/styles/colors'

import config from '~/config'

Undo = ({ color, className, top, show, children, style, onClick, undo, props... }) ->
    <RoundedButton
        style={{
            zIndex: config.ZINDEX.undoButton
            style...
        }}
        onClick={ () ->
            undo()
            onClick?()
        }
        color={ color ? colors.RED }
        width={ 100 }
        className="
            font-heading
            py-2 px-0
            undo-button
            #{ classif top, 'undo-button-top' }
            #{ classif show, 'shown' }
            #{ className ? '' }"
        { props... }>
        { children ? 'UNDO' }
        <style global jsx>{"""#{} // stylus
            .undo-button-top
                fixed top -100px
                left calc(50% - 50px)
                opacity 0 !important
                transition all 0.2s easeOutCubic !important
                &.shown
                    opacity 1 !important
                    top 10px
        """}</style>
    </RoundedButton>


mapStateToProps = (state) -> {}

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    undo: () -> dispatch(ActionCreators.undo())


export default connect(mapStateToProps, mapDispatchToProps)(Undo)
