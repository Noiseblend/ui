import { connect } from 'react-redux'
import { Tooltip } from 'react-tippy'

import ToggleButton from '~/components/toggleButton'

import PlaylistActions from '~/redux/playlists'

import colors from '~/styles/colors'


Filters = (props) ->
    <div
        style={ props.style }
        className="d-flex align-items-center">
        <h5 style={ color: colors.GRAY } className='my-0 py-0'>Show:</h5>
        <ToggleButton
            className='ml-4 p-1 explicit-button'
            width={ 100 }
            color={ colors.MARS_RED }
            toggled={ not props.filterExplicit }
            onClick={ () -> props.setFilterExplicit(not props.filterExplicit) }
            style={
                fontSize: '0.8rem'
            }>
            Explicit
        </ToggleButton>
        <ToggleButton
            className='ml-4 p-1 dislikes-button'
            width={ 100 }
            color={ colors.MARS_RED }
            toggled={ not props.filterDislikes }
            onClick={ () -> props.setFilterDislikes(not props.filterDislikes) }
            style={
                fontSize: '0.8rem'
            }>
            Disliked
        </ToggleButton>
    </div>

mapStateToProps = (state) ->
    filterExplicit: state.playlists.present.filterExplicit
    filterDislikes: state.playlists.present.filterDislikes

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    setFilterExplicit: (filterExplicit) ->
        dispatch(PlaylistActions.setFilterExplicit(filterExplicit))
    setFilterDislikes: (filterDislikes) ->
        dispatch(PlaylistActions.setFilterDislikes(filterDislikes))

export default connect(mapStateToProps, mapDispatchToProps)(Filters)
