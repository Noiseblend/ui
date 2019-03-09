import { init } from "@sentry/browser"
import * as Sentry from "@sentry/browser"

import config from "~/config"

options =
    dsn: config.SENTRY_DSN
    release: config.SENTRY_RELEASE
    autoBreadcrumbs: true
    captureUnhandledRejections: true
    maxBreadcrumbs: 50
    attachStacktrace: true
    environment:
        if config.SENTRY_ENVIRONMENT?.length
            config.SENTRY_ENVIRONMENT
        else if config.DEV
            "development"
        else
            "production"

IsomorphicSentry =
    if process.browser
        init(options)
        Sentry
    else
        NodeSentry = eval("require('@sentry/node')")
        NodeSentry.init(options)
        NodeSentry

export default IsomorphicSentry
