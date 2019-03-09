import _ from 'lodash'

String::toTitleCase ?= () ->
    words = @toString().split(' ')
    words = (
        (_.capitalize(subword) for subword in word.split('&')).join('&') for word in words
    )
    words.join(' ')

String::formatUnicorn ?= () ->
    str = @toString()
    if arguments.length
        t = typeof arguments[0]
        args = if (t is 'string' or t is 'number')
            Array.prototype.slice.call(arguments)
        else
            arguments[0]

        for key of args
            str = str.replace(new RegExp('\\{ ' + key + '\\ }', 'gi'), args[key])
    return str

String::hash ?= () ->
    return 0 if @length is 0
    hash = 0
    for i in [0...@length]
        hash = ((hash << 5) - hash) + @charCodeAt(i)
        hash |= 0
    return if hash >= 0 then hash else -hash
