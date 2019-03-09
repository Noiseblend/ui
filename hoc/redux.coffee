import React, { Component } from "react"
import { Provider } from "react-redux"

_Promise = Promise
_debug = false
DEFAULT_KEY = "__NEXT_REDUX_STORE__"
isServer = not window?

export setPromise = (Promise) ->
    _Promise = Promise

###
  @param makeStore
  @param initialState
  @param config
  @param ctx
  @return {{ getState: function, dispatch: function }}
###
initStore = ({ makeStore, initialState, config, ctx = {} }) ->
    { storeKey } = config

    createStore = () ->
        makeStore(config.deserializeState(initialState), {
            ctx...
            config...
            isServer
        })

    return createStore() if isServer

    # Memoize store if client
    window[storeKey] ?= createStore()

    return window[storeKey]

###
  @param makeStore
  @param config
  @return { function(App): {getInitialProps, new(): WrappedApp, prototype: WrappedApp }}
###
withRedux = (makeStore, config = {}) ->
    config = {
        storeKey: DEFAULT_KEY
        debug: _debug
        serializeState: (state) -> state
        deserializeState: (state) -> state
        config...
    }

    (App) ->
        class WrappedApp extends Component
            @displayName: "withRedux(#{ App.displayName or App.name or "App" })"
            @getInitialProps: (appCtx) ->
                throw new Error("No app context") if not appCtx
                throw new Error("No page context") if not appCtx.ctx

                appCtx.ctx.isServer = appCtx.ctx.req?
                store = initStore({
                    makeStore
                    config
                    ctx: appCtx.ctx
                })
                appCtx.ctx.store = store

                initialProps = {}

                if App.getInitialProps
                    initialProps = (await App.getInitialProps(appCtx)) ? {}

                return {
                    isServer
                    req:
                        if appCtx.ctx.req?
                            headers: appCtx.ctx.req.headers, url: appCtx.ctx.req.url
                        else
                            null
                    initialState: config.serializeState(store.getState())
                    initialProps: initialProps
                }

            constructor: (props, context) ->
                super(props, context)
                { initialState, req } = props
                @store = initStore({
                    makeStore
                    initialState
                    config
                    ctx: { isServer: req?, req }
                })

            render: () ->
                { initialProps, initialState, props... } = @props
                <Provider store={ @store }>
                    <App {props...} {initialProps...} />
                </Provider>

export default withRedux
