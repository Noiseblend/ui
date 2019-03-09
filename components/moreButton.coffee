import { connect } from 'react-redux'

import RoundedButton from '~/components/roundedButton'

import colors from '~/styles/colors'
import { Loader } from '~/styles/icons'

import config from '~/config'

MoreButton = ({
    loading, disabled, noMoreData, itemsName, onClick, style,
    noSelectedArtists, width = 200, windowWidth, className = '', props...
}) ->
    itemsName = if windowWidth > 576
        itemsName
    else
        ''
    <RoundedButton
        width={ width }
        color={ colors.DARK_MAUVE }
        disabled={ disabled or noMoreData }
        loading={ loading }
        className={ className }
        style={ style }
        onClick={ onClick }>
        { if noMoreData
            "That's it"
        else
            "More #{ itemsName }" }
    </RoundedButton>

mapStateToProps = (state) ->
    windowWidth: state.ui.windowWidth

mapDispatchToProps = (dispatch) -> {}


export default connect(mapStateToProps, mapDispatchToProps)(MoreButton)
