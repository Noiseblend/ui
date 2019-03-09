LoadingLines = ({ className, id, style, children, props... }) ->
    <div
        className="
            la-line-scale-pulse-out-rapid
            #{ className ? '' }"
        id={ id ? '' }
        style={ style }
        { props... }>
        <div />
        <div />
        <div />
        <div />
        <div />
        <style jsx>{"""#{} // stylus
            .la-line-scale-pulse-out-rapid,
            .la-line-scale-pulse-out-rapid > div
                box-sizing: border-box

            .la-line-scale-pulse-out-rapid
                display: block
                font-size: 0
                color: #fff
                width: 40px
                height: 32px

                &.la-dark
                    color: #333

                & > div
                    display: inline-block
                    float: none
                    background-color: currentColor
                    border: 0 solid currentColor
                    width: 4px
                    height: 32px
                    margin: 2px
                    margin-top: 0
                    margin-bottom: 0
                    border-radius: 0
                    animation: line-scale-pulse-out-rapid .9s infinite cubic-bezier(.11, .49, .38, .78)

                    &:nth-child(3)
                        animation-delay: -.9s

                    &:nth-child(2),
                    &:nth-child(4)
                        animation-delay: -.65s

                    &:nth-child(1),
                    &:nth-child(5)
                        animation-delay: -.4s

                &.la-sm
                    width: 20px
                    height: 16px

                    & > div
                        width: 2px
                        height: 16px
                        margin: 1px
                        margin-top: 0
                        margin-bottom: 0

                &.la-1-5x
                    width: 60px
                    height: 48px

                    & > div
                        width: 6px
                        height: 48px
                        margin: 3px
                        margin-top: 0
                        margin-bottom: 0

                &.la-2x
                    width: 80px
                    height: 64px

                    & > div
                        width: 8px
                        height: 64px
                        margin: 4px
                        margin-top: 0
                        margin-bottom: 0

                &.la-3x
                    width: 120px
                    height: 96px

                    & > div
                        width: 12px
                        height: 96px
                        margin: 6px
                        margin-top: 0
                        margin-bottom: 0

            @keyframes line-scale-pulse-out-rapid
                0%
                    transform: scaley(1)

                80%
                    transform: scaley(.3)

                90%
                    transform: scaley(1)
        """}</style>
    </div>

export default LoadingLines
