import { connect } from 'react-redux'

import Link from 'next/link'

import Brand from '~/components/brand'
import { DonateButton } from '~/components/donateView'
import ProfilePicture from '~/components/profilePicture'

import { classif } from '~/lib/util'

import colors from '~/styles/colors'
import { Home, LogOut, Music } from '~/styles/icons'

import config from '~/config'


Navbar = ({
    className, id, style, children, mobile,
    navbarConfig, authenticated, props...
}) ->
    <nav
        className="
            flex-center px-1 px-md-3
            #{ classif(navbarConfig.hidden, 'd-none') }
            #{ className ? '' }"
        id={ id ? '' }
        style={{
            backgroundColor: navbarConfig.background
            style...
        }}
        { props... }>
        <Brand />
        <Link prefetch href='/'>
            <a className='ml-2 ml-md-4 font-heading flex-center nav-link'>
                <Home size={ if mobile then 17 else 20 } style={ marginTop: -1 } />
                <span className='ml-1'>Home</span>
            </a>
        </Link>
        {if authenticated
            <Link prefetch href='/discover'>
                <a className='ml-2 ml-md-4 font-heading flex-center nav-link'>
                    <Music size={ if mobile then 17 else 20 } />
                    <span className='ml-1'>Discover</span>
                </a>
            </Link>
        }
        <div className='flex-grow-1' />
        {if authenticated
            <>
                <Link prefetch href={{
                    pathname: '/',
                    query: {
                        logout: true
                    }
                }}>
                    <a className='font-heading flex-center ml-2 mr-3 nav-link'>
                        <LogOut size={ if mobile then 17 else 20 } />
                        <span className='ml-1'>Logout</span>
                    </a>
                </Link>
                <DonateButton size={ config.NAVBAR_HEIGHT.desktop - 20 } />
                <Link prefetch href='/user'>
                    <a className='ml-2 flex-center'>
                        <ProfilePicture style={ position: 'relative' } />
                    </a>
                </Link>
            </>
        }
        <style global jsx>{"""#{} // stylus
            #bmac-link
                @media(max-width: $mobile)
                    display none
        """}</style>
        <style jsx>{"""#{} // stylus
            .nav-link
                color #{ navbarConfig.color }
        """}</style>
        <style jsx>{"""#{} // stylus
            nav
                z-index 0
                height navbarHeightDesktop
                width 100vw
                absolute top left

                @media(max-width: $mobile)
                    height navbarHeightMobile

                .nav-link
                    font-size 18px
                    ease-out color
                    &:hover
                    &:focus
                        color red

                    @media(max-width: $mobile)
                        font-size 15px
        """}</style>
    </nav>

mapStateToProps = ({ ui, auth }) ->
    mobile: ui.mobile
    navbarConfig: ui.navbar
    authenticated: auth.authenticated

mapDispatchToProps = (dispatch) -> {}

export default connect(mapStateToProps, mapDispatchToProps)(Navbar)
