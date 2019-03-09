import { applyMiddleware, compose, createStore } from "redux"
import createSagaMiddleware from "redux-saga"

import { reduxBatch } from "@manaflair/redux-batch"

import Sentry from "~/lib/sentry"

import config from "~/config"

configureStore = (rootReducer, getRootSaga, initialState, ctx) ->
    isClient = not ctx.isServer

    createAppropriateStore = createStore
    middleware = []
    sagaMonitor = null
    sagaMiddleware = createSagaMiddleware({
        sagaMonitor
        onError: (err) ->
            console.error(err)
            Sentry.captureException(err)
    })
    middleware.push(sagaMiddleware)

    enhancers = [reduxBatch, applyMiddleware(middleware...), reduxBatch]

    composeEnhancers = window?.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ? compose
    store = createAppropriateStore(rootReducer, initialState, composeEnhancers(enhancers...))

    if isClient and sagaMiddleware?
        sagaMiddleware.run(getRootSaga({ ctx..., store }))

    store

export default configureStore
