import colors from '~/styles/colors'


LoadingDots = ({
    className, id, style, children, color = colors.WHITE,
    size = 16, props...
}) ->
    <div
        className="spinner #{ className ? '' }"
        id={ id ? '' }
        style={{
            width: size * 4
            height: size
            style...
        }}
        { props... }>
        <div className="bounce1" style={
            backgroundColor: color
            width: size
            height: size
            borderRadius: size / 2
        } />
        <div className="bounce2" style={
            marginLeft: size / 3
            marginRight: size / 3
            backgroundColor: color
            width: size
            height: size
            borderRadius: size / 2
        } />
        <div className="bounce3" style={
            backgroundColor: color
            width: size
            height: size
            borderRadius: size / 2
        } />
        <style jsx>{"""#{} // stylus
            .spinner
                text-align center

                & > div
                    display inline-block
                    backface-visibility hidden
                    will-change transform
                    animation sk-bouncedelay 1.4s infinite ease-in-out both

                .bounce1
                    -webkit-animation-delay -0.32s
                    animation-delay -0.32s

                .bounce2
                    -webkit-animation-delay -0.16s
                    animation-delay -0.16s

            @keyframes sk-bouncedelay
                0%, 80%, 100%
                    transform scale(0)
                 40%
                    transform scale(1.0)
        """}</style>
    </div>

export default LoadingDots
