import { connect } from 'react-redux'

import TextButton from '~/components/textButton'

import { ArrowLeft } from '~/styles/icons'


BackButton = ({
    className, id, style, children, color,
    backgroundColor, mediumScreen, props...
}) ->
    <TextButton
        className="flex-center history-back-button #{ className ? '' }"
        id={ id }
        onClick={ (e) ->
            e.stopPropagation()
            history.back()
        }
        style={{
            position: 'fixed'
            bottom: if mediumScreen then 10 else 20
            left: if mediumScreen then 10 else 20
            width: if mediumScreen then 30 else 40
            height: if mediumScreen then 30 else 40
            borderRadius: 100
            zIndex: 5
            backgroundColor
            style...
        }}>
        <ArrowLeft
            size={ if mediumScreen then 15 else 20 }
            color="#{ color }"
            className='arrow-back-icon'
            { props... }
        />
    </TextButton>

mapStateToProps = (state) ->
    mediumScreen: state.ui.mediumScreen

mapDispatchToProps = (dispatch) -> {}

export default connect(mapStateToProps, mapDispatchToProps)(BackButton)
