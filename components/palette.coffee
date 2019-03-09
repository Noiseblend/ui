import React, { PureComponent } from 'react'

import getImagePalette from '~/lib/palette'

class Palette extends PureComponent
    state:
        palette: {}
        loaded: false
        error: false

    updatePalette: (image) ->
        getImagePalette(image)
            .then((palette) => @setState({ palette, loaded: true }))
            .catch((error) =>
                console.error(error)
                @setState({ palette: { }, loaded: true, error })
            )

    componentDidMount: -> @updatePalette(@props.image)

    componentDidUpdate: (prevProps, prevState, snapshot) ->
        if prevProps.image isnt @props.image
            return @updatePalette(@props.image)

    render: ->
        { children } = @props
        { palette, loaded } = @state

        children(palette)

export default Palette
