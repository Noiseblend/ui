###
CONSTRUCTORS
color = Color('rgb(255, 255, 255)')
color = Color({ r: 255, g: 255, b: 255 })
color = Color.rgb(255, 255, 255)
color = Color.rgb([255, 255, 255])


HELPERS
color.hsl()
color.object()       // { r: 255, g: 255, b: 255 }
color.rgb().array()  // [255, 255, 255]
color.rgbNumber()    // 16777215 (0xffffff)
color.red()          // 255
color.hsl().string() // 'hsl(320, 50%, 100%)'
color.luminosity()   // 0.412


COLOR MANIPULATION
color.negate()                    // rgb(0, 100, 255) -> rgb(255, 155, 0)

color.lighten(0.5)                // hsl(100, 50%, 50%) -> hsl(100, 50%, 75%)
color.darken(0.5)                 // hsl(100, 50%, 50%) -> hsl(100, 50%, 25%)

color.saturate(0.5)               // hsl(100, 50%, 50%) -> hsl(100, 75%, 50%)
color.desaturate(0.5)             // hsl(100, 50%, 50%) -> hsl(100, 25%, 50%)
color.grayscale()                 // #5CBF54 -> #969696

color.whiten(0.5)                 // hwb(100, 50%, 50%) -> hwb(100, 75%, 50%)
color.blacken(0.5)                // hwb(100, 50%, 50%) -> hwb(100, 50%, 75%)

color.fade(0.5)                   // rgba(10, 10, 10, 0.8) -> rgba(10, 10, 10, 0.4)
color.opaquer(0.5)                // rgba(10, 10, 10, 0.8) -> rgba(10, 10, 10, 1.0)

color.rotate(180)                 // hsl(60, 20%, 20%) -> hsl(240, 20%, 20%)
color.rotate(-90)                 // hsl(60, 20%, 20%) -> hsl(330, 20%, 20%)

color.mix(Color('yellow'))        // cyan -> rgb(128, 255, 128)
color.mix(Color('yellow'), 0.3)   // cyan -> rgb(77, 255, 179)

// chaining
color.green(100).grayscale().lighten(0.6)
###

import Color from 'color'

Color::s = () -> @rgb().string()

colors =
    FLASH_WHITE   : '#FFFFFF'
    WHITE         : '#FAFAFA'
    MAROON        : '#aa9483'
    LIGHT_GRAY    : '#AAAAAA'
    GRAY          : '#888888'
    DARK_GRAY     : '#444444'
    BLACK         : '#1C1C1C'
    PITCH_BLACK   : '#000000'
    ORANGE        : '#F96332'
    YELLOW        : '#FFB500'
    SUNFLOWER     : '#F7CE68'
    PEACH         : '#FBAB7E'
    SEPIA         : '#B97F64'
    MAUVE         : '#3D2550'
    GRAY_MAUVE    : '#3E3E70'
    DARK_MAUVE    : '#291B3B'
    MAGENTA       : '#E14283'
    RED           : '#FF293E'
    HOTRED        : '#FF1536'
    MARS_RED      : '#862833'
    SPOTIFY_GREEN : '#70B069'
    WEIRD_GREEN   : '#46BD62'
    GREEN         : '#1CCA4A'
    CALM_BLUE     : '#6488B9'
    GRAY_BLUE     : '#B1B2DD'
    BLUE          : '#2977FF'
    'FACEBOOK-F'  : '#3B5998'
    TWITTER       : '#1DA1F2'
    'LINKEDIN-IN' : '#0077b5'
    'GITHUB-ALT'  : '#ffffff'
    'REDDIT-ALIEN': '#FF4500'
    MAGENTISH     : '#811a4c'
    DARK_BLUE     : '#050129'
    BLACK_MAUVE   : '#292837'
    BMAC_ORANGE   : '#ff813f'

for name of colors
    colors[name] = Color(colors[name])

colors = {
    colors...
    PLAYLIST   : colors.BLUE.desaturate(0.4)
    CURRENT    : colors.RED.desaturate(0.3)
    EMERGING   : colors.MAUVE.lighten(0.4)
    UNDERGROUND: colors.DARK_GRAY.lighten(0.2)
    PINE_NEEDLE: colors.SPOTIFY_GREEN
    ACTION     : colors.ORANGE.desaturate(0.4).lighten(0.2)
}

export default colors
