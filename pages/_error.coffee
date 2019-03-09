import NextError from 'next/error'

import Sentry from '~/lib/sentry'

class MyError extends NextError
    @getInitialProps: (ctx) ->
        if ctx.err
            console.error(ctx.err)
            Sentry.configureScope((scope) ->
                scope.setUser(ctx.user ? {}))
            Sentry.captureException(ctx.err)
        return await NextError.getInitialProps(ctx)



export default MyError
