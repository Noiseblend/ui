import { camelCase } from 'lodash'

import * as Vibrant from 'node-vibrant'

getImagePalette = (url) ->
    Vibrant.from(url).getPalette()
        .then((response) ->
            keys = Object.keys(response)
            addPalette = (acc, paletteName) -> ({
                acc...
                [camelCase(paletteName)]: (
                    response[paletteName] and
                    response[paletteName].getHex()
                )
            })
            colorPallete = keys.reduce(addPalette, {})

            return colorPallete
        )


export default getImagePalette
