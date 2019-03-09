import { connect } from 'react-redux'

import Link from 'next/link'

import { randomInt } from '~/lib/util'

import UIActions from '~/redux/ui'

import colors from '~/styles/colors'
import { AtSign, MapPin, Star, User } from '~/styles/icons'
import { fluid } from '~/styles/util'

import config from '~/config'


username = (user) ->
    if user?.displayName?.length > 0
        user.displayName
    # else if user?.email?.length > 0
    #     user?.email
    else
        user?.username

fallbackImage =  ->
    "#{ config.STATIC }/img/bg/artist/bg_#{ randomInt(1, 5) }_320.jpg"

UserHeader = (props) ->
    infoTextSize = 16
    iconProps =
        color: "#{ if props.mobile
            colors.WHITE.alpha(0.8)
        else
            colors.WHITE.alpha(0.4) }"
        size: infoTextSize
        style:
            verticalAlign: 'middle'
            marginRight: if props.mobile then 5 else 10
    image = props.user?.images?[0]?.url
    name = username(props.user)

    <div className='
        d-flex justify-content-around
        align-items-center user-header'>
        <div
            className='flex-center mt-md-5 user-image'>
            <img
                style={
                    display: if not image? then 'none' else 'block'
                }
                className='user-icon'
                src={ props.fallbackUserImage ? image }
                onError={ () -> props.setFallbackUserImage(fallbackImage()) }
                alt='User Icon' />
            <div
                style={
                     fontSize: infoTextSize
                 }
                className='
                    d-flex flex-column
                    flex-wrap my-0 my-md-1
                    text-left user-info'>
                <div className='
                    d-flex align-items-center
                    ml-2 ml-md-4 my-0 my-md-1
                    user-info-item'>
                    <User { iconProps... } /> { name }
                </div>
                <div
                    key={ 1 }
                    className='
                        d-flex align-items-center
                        ml-2 ml-md-4 my-0 my-md-1
                        user-info-item'>
                    <MapPin { iconProps... } /> { props.user?.countryName }
                </div>
                <div
                    key={ 2 }
                    className='
                        d-flex align-items-center
                        ml-2 ml-md-4 my-0 my-md-1
                        user-info-item'>
                    <AtSign { iconProps... } /> { props.user?.email }
                </div>
            </div>
        </div>
        <div className='
            d-flex
            flex-column
            justify-content-center
            align-items-center
            user-details'>
        </div>
        <style jsx>{"""#{} // stylus
            .user-header
                color white
                font-weight bold
                font-size 1.5rem
                height #{ props.height }vh
                min-height #{ props.height }vh
                width 100vw
                text-align center
                margin-top navbarHeightDesktop + 10px
                margin-bottom navbarHeightDesktop
                @media(max-width: $mobile)
                    margin-top navbarHeightMobile + 10px
                    margin-bottom navbarHeightMobile


            .user-info
                max-height #{ props.height - 4 }vh

            .user-icon
                object-fit cover
                display block
                height #{ props.height - 4 }vh
                max-height #{ props.height - 2 }vh
                width #{ props.height - 4 }vh
                max-width #{ props.height - 2 }vh
                border-radius 10px
                ease-out 0.4s height width

            @media (max-height: #{ config.WIDTH.mobile }px)
                .user-icon
                    height #{ (props.height - props.height / 3) - 2 }vh
                    max-height #{ (props.height - props.height / 3) - 2 }vh
                    width #{ (props.height - props.height / 3) - 2 }vh
                    max-width #{ (props.height - props.height / 3) - 2 }vh

                .user-header
                    height #{ props.height - props.height / 3 }vh
                    min-height #{ props.height - props.height / 3 }vh


            @media (max-width: #{ config.WIDTH.mobile }px)
                .user-header
                    height #{ props.height - props.height / 3 }vh
                    min-height #{ props.height - props.height / 3 }vh

                .user-icon
                    height #{ (props.height - props.height / 3) - 4 }vh
                    max-height #{ (props.height - props.height / 3) - 4 }vh
                    width #{ (props.height - props.height / 3) - 4 }vh
                    max-width #{ (props.height - props.height / 3) - 4 }vh
                    box-shadow 0 2px 10px alpha(black, 0.4)
        """}</style>
    </div>

mapStateToProps = (state) ->
    fallbackUserImage: state.ui.fallbackUserImage
mapDispatchToProps = (dispatch) ->
    setFallbackUserImage: (image) -> dispatch(UIActions.setFallbackUserImage(image))


export default connect(mapStateToProps, mapDispatchToProps)(UserHeader)
