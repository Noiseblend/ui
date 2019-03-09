import React from "react"

import Link from "next/link"

InfoLinks = ({ className, style }) ->
    <div className={ "d-flex flex-column flex-md-row #{ className ? "" }" } style={ style }>
        <div className="flex-center">
            <Link href="/terms">
                <a style={minWidth: 110}>Terms of Service</a>
            </Link>
            <Link href="/about">
                <a style={minWidth: 70}>About Us</a>
            </Link>
            <Link href="/privacy">
                <a style={minWidth: 110}>Privacy Policy</a>
            </Link>
        </div>
        <style jsx>{ """#{} // stylus
            a
                text-align center
                margin-left 0.5rem
                margin-right 0.5rem
                font-weight bold
                font-size .9rem
                color alpha(white, 50%)
                ease-out color

                &#ideas-link
                    color alpha(white, 70%)
                    &:hover
                    &:focus
                        color peach

                &:hover
                &:focus
                    color peach

        """ }</style>
    </div>

export default InfoLinks
