import _ from 'lodash'

export anyObj = (obj) ->
    for key of obj
        if obj[key]
            return true
    return false

export any = (arr) ->
    for val in arr
        if val
            return true
    return false

export randomInt = (min, max) ->
    min + Math.floor(Math.random() * Math.floor(max))

export randomDots = (dotCount, minSize, maxSize, maxTop, maxLeft, color) ->
    sizes = (Math.floor((maxSize - minSize) * Math.random()) + minSize for i in [1..dotCount])
    (
        <div
            key={ i }
            className='dot'
            style={
                top: "#{ maxTop * Math.random() }vh",
                left: "#{ maxLeft * Math.random() }vw",
                width: "#{ sizes[i-1] }px",
                height: "#{ sizes[i-1] }px"
            }>
            <style jsx>{"""#{} // stylus
                .dot
                    background-color #{ color }
                    position fixed
                    border-radius 50%

            """}</style>
        </div> for i in [1..dotCount]
    )

export classif = (condition, cls, defaultCls = '') ->
    if condition
        cls
    else
        defaultCls
