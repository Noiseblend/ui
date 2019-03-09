import { connect } from 'react-redux'

import RoundedButton from '~/components/roundedButton'

import { anyObj, classif } from '~/lib/util'

import PlaylistActions from '~/redux/playlists'
import RecommendationActions from '~/redux/recommendations'

import colors from '~/styles/colors'

onReset = ({ resetTuning, resetOrder, resetPlaylist }) ->
    resetTuning()
    resetOrder()
    resetPlaylist()


ResetTuningButton = ({
    order, tuneableAttributes, width,
    color, children, disabled, props...
}) ->
    modified = anyObj(order) or anyObj(tuneableAttributes)

    <RoundedButton
        className='mx-1 my-4 reset-button'
        color={ color ? colors.BLACK }
        disabled={ not modified or disabled }
        width={ width ? 160 }
        onClick={ () -> onReset(props) }
        { props... }>
        { children ? 'Reset to default' }
    </RoundedButton>

mapStateToProps = (state) ->
    tuneableAttributes: state.recommendations.present.tuneableAttributes
    order: state.playlists.present.order

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    resetTuning: () ->
        dispatch(RecommendationActions.resetTuning())
    resetOrder: () ->
        dispatch(PlaylistActions.resetOrder())
    resetPlaylist: () ->
        dispatch(PlaylistActions.resetPlaylist())


export default connect(mapStateToProps, mapDispatchToProps)(ResetTuningButton)
