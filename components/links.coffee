import React from "react"

Links = ({ css = [] }) ->
    css.map((url) ->
        <link key={ url } href={ url } rel="stylesheet" />)

export default Links
