export fluid = (min, max, minVW, maxVW) ->
    "calc(
        #{ min }px + (#{ max - min }) *
        (
            (100vw - #{ minVW }px) /
            (#{ maxVW - minVW })
        )
    )"
