import '~/lib/str'

export default formatMessage = (message) ->
    try
        message?.toTitleCase()
    catch e
        message
