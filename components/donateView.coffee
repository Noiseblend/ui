import { connect } from 'react-redux'

import anime from 'animejs'

import RoundedButton from '~/components/roundedButton'
import TextButton from '~/components/textButton'

import SpotifyActions from '~/redux/spotify'

import colors from '~/styles/colors'

import Coffee from '~/icons/coffee.svg'


LID = '#lid'

onButtonHover = () ->
    anime.remove(LID)
    anime(
        targets: LID
        transform: "
            rotate(-15.000000)
            translate(-1.868838, 4.205366)"
    )

onButtonLeave = () ->
    anime.remove(LID)
    anime(
        targets: LID
        transform: "
            rotate(-1.000000)
            translate(1.000000, 6.000000)"
    )


export DonateButton = ({ size = 60, props... }) ->
    <a
        id='bmac-link'
        onMouseEnter={ onButtonHover }
        onMouseLeave={ onButtonLeave }
        href="https://buymeacoff.ee/noiseblend">
        <RoundedButton
            style={
                width: size
                height: size
            }
            className='p-0 donate-button'
            color={ colors.BMAC_ORANGE }>
            <Coffee height={ size * 0.75 } />
        </RoundedButton>
        <style jsx>{"""#{} // stylus
            :global(.donate-button)
                &:hover
                &:focus
                    transform scale(1.3)
        """}</style>
    </a>

DonateView = ({ className, id, style, children, setUserDetails, onClick, props... }) ->
    <div
        className="
            flex-column-center donate-view
            #{ className ? '' }"
        id={ id ? '' }
        style={ style }
        { props... }>
        <DonateButton />
        <h6 className='mt-3 text-center bmac-description'>
            <div className="underline" />
            <span>Help me keep</span>
        </h6>
        <h6 className='text-center bmac-description'>
            <div className="underline" />
            <span>Noiseblend running</span>
        </h6>
        <TextButton
            onClick={ () ->
                onClick?()
                setUserDetails(donateButtonHidden: true)
            }
            id='bmac-hide'
            className='hide-text'
            color={ colors.WHITE.alpha(0.4) }>
            Leave me alone
        </TextButton>
        <style jsx>{"""#{} // stylus
            .donate-view
                max-width 150px

                :global(.hide-text)
                    font-size 14px
                    text-decoration underline
                    &:hover
                    &:focus
                        color alpha(white, 70%)

                h6
                    line-height 1.4
                    color white
                    position relative
                    span
                        position relative
                    .underline
                        absolute top 60% left -2%
                        width 0%
                        height 40%
                        background blue
        """}</style>
    </div>

mapStateToProps = (state) -> {}

mapDispatchToProps = (dispatch) ->
    setUserDetails: (details) -> dispatch(SpotifyActions.setUserDetails(details))


export default connect(mapStateToProps, mapDispatchToProps)(DonateView)
