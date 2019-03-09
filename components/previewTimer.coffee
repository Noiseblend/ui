PreviewTimer = ({
    style, className, children, id,
    remainingSeconds, color, hoverColor, props...
}) ->
    <div
        className="
            text-center font-heading
            d-flex justify-content-center
            align-items-center
            preview-timer #{ className }"
        id={ id }
        style={ style }
        { props... }>
        { remainingSeconds }
        <style jsx>{"""#{} // stylus
            size = 24px
            .preview-timer
                border 2px solid #{ color }
                height size
                width size
                background-color transparent
                font-size 11px
                border-radius (size / 2)
                ease-out 0.25s border-color color

                &:hover
                    color #{ hoverColor }
                    border-color #{ hoverColor }
        """}</style>
    </div>

export default PreviewTimer
