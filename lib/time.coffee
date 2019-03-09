export getMoment = (time) ->
    switch Math.floor((time ? new Date()).getHours() / 6)
        when 0 then 'night'
        when 1 then 'morning'
        when 2 then 'noon'
        when 3 then 'evening'

export getPointTags = (tags = {}) ->
    time = new Date()
    return
        time: time
        tags: {
            tags...
            moment: getMoment(time)
        }
