Set::isSuperset = (subset) ->
    for elem from subset
        if not @has elem
            return false

    return true

Set::union = (setB) ->
    union = new Set(this)
    for elem from setB
        union.add(elem)

    return union

Set::intersection = (setB) ->
    intersection = new Set()
    for elem from setB
        if @has elem
            intersection.add(elem)

    return intersection

Set::difference = (setB) ->
    difference = new Set(this)
    for elem from setB
        difference.delete(elem)

    return difference

Set::intersects = (setB) ->
    unless setB?
        return false

    for elem from setB
        if @has elem
            return true
    return false

Set::equals = (setB) ->
    @size is setB.size and @intersection(setB).size is @size
