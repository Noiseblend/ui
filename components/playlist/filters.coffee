import { connect } from 'react-redux'
import { Tooltip } from 'react-tippy'

import ToggleButton from '~/components/toggleButton'

import PlaylistActions from '~/redux/playlists'

import colors from '~/styles/colors'


Filters = (props) ->
    <div
        style={ props.style }
        className="d-flex align-items-center">
        <ToggleButton
            className='ml-1 px-2 py-1 explicit-button'
            color={ colors.MARS_RED }
            toggled={ not props.filterExplicit }
            onClick={ () -> props.setFilterExplicit(not props.filterExplicit) }
            style={
                fontSize: if props.mobile then '0.7rem' else '0.8rem'
            }>
            Explicit
        </ToggleButton>
        <ToggleButton
            className='ml-1 px-2 py-1 dislikes-button'
            color={ colors.MARS_RED }
            toggled={ not props.filterDislikes }
            onClick={ () -> props.setFilterDislikes(not props.filterDislikes) }
            style={
                fontSize: if props.mobile then '0.7rem' else '0.8rem'
            }>
            Disliked
        </ToggleButton>
    </div>

mapStateToProps = (state) ->
    mobile: state.ui.mobile
    filterExplicit: state.playlists.present.filterExplicit
    filterDislikes: state.playlists.present.filterDislikes

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    setFilterExplicit: (filterExplicit) ->
        dispatch(PlaylistActions.setFilterExplicit(filterExplicit))
    setFilterDislikes: (filterDislikes) ->
        dispatch(PlaylistActions.setFilterDislikes(filterDislikes))

export default connect(mapStateToProps, mapDispatchToProps)(Filters)
