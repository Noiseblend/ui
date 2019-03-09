import Color from 'color'

export getResolution = () ->
    width = null
    height = null
    if window?
        width = window.screen.width * window.devicePixelRatio
        height = window.screen.height * window.devicePixelRatio

    [width, height]

export fixColors = (data) ->
    for item in data
        if item.image?.color? and typeof item.image.color is 'string'
            color = Color(item.image.color)
            item.image.color = color.alpha(0.7).rgb().string()
            item.image.textColor = if color.isLight() then 'black' else 'white'
    return data
