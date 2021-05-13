const withBundleAnalyzer = require('@zeit/next-bundle-analyzer')
const withCoffeescript = require('next-coffeescript')
const withTM = require('@weco/next-plugin-transpile-modules')
const LodashModuleReplacementPlugin = require('lodash-webpack-plugin')
const { PHASE_DEVELOPMENT_SERVER } = require('next/constants')
const SentryCliPlugin = require('@sentry/webpack-plugin')

const fs = require('fs')
const _ = require('lodash')

let env = _.cloneDeep(process.env)
env.AUTH_TOKEN_EXPIRATION_DAYS = parseInt(env.AUTH_TOKEN_EXPIRATION_DAYS, 10)
env.SKIP_SENTRY = env.SKIP_SENTRY === 'true'

const defaults = {
    AUTH_TOKEN_COOKIE_KEY: 'authToken',
    AUTH_TOKEN_EXPIRATION_DAYS: 30,
    STATIC_URL: '/static',
    LOCAL_API_URL: 'http://localhost:9000/',
    REMOTE_API_URL: 'https://api.noiseblend.com/',
    LOCAL_WS_URL: 'ws://localhost:9000/',
    REMOTE_WS_URL: 'wss://api.noiseblend.com/'
}
for (let key of Object.keys(env)) {
    let val = env[key]
    if (key.endsWith('__FILE')) {
        if (fs.existsSync(val)) {
            let newKey = key.replace(/__FILE$/g, '')
            env[newKey] = fs.readFileSync(val).toString()
        } else {
            console.log('File does not exist')
            console.log(`${key}: ${val}`)
        }
    }
}
for (let key of Object.keys(defaults)) {
    if (!env[key]) {
        env[key] = defaults[key]
    }
}

module.exports = (phase, { defaultConfig }) => {
    const domain = phase === PHASE_DEVELOPMENT_SERVER ? 'localhost' : 'www.noiseblend.com'
    return withTM(
        withBundleAnalyzer(
            withCoffeescript({
                ...defaultConfig,
                publicRuntimeConfig: {
                    debug: phase === PHASE_DEVELOPMENT_SERVER,
                    domain: domain,
                    staticDir: phase === PHASE_DEVELOPMENT_SERVER ? '/static' : '/static',
                    sentryDSN: env.SENTRY_DSN,
                    sentryRelease: env.SENTRY_RELEASE,
                    sentryEnvironment: env.SENTRY_ENVIRONMENT,
                    localApiURL: env.LOCAL_API_URL,
                    remoteApiURL: env.REMOTE_API_URL,
                    localWsURL: env.LOCAL_WS_URL,
                    remoteWsURL: env.REMOTE_WS_URL
                },
                onDemandEntries: { websocketPort: 4002 },
                cssModules: true,
                transpileModules: ['react-popper'],
                analyzeServer: ['server', 'both'].includes(env.BUNDLE_ANALYZE),
                analyzeBrowser: ['browser', 'both'].includes(env.BUNDLE_ANALYZE),
                webpack(config, { dev, isServer }) {
                    console.log('Mode: %s', isServer ? 'Server' : 'Client')
                    console.log('    Environment: %s', env.NODE_ENV)
                    console.log('    Development: %s', dev)
                    config.module.rules.push({
                        test: /\.(png|jpg|gif|eot|ttf|woff|woff2)$/,
                        use: { loader: 'url-loader', options: { limit: 100000 } }
                    })
                    config.module.rules.push({
                        test: /\.worker\.js$/,
                        use: [
                            {
                                loader: 'worker-loader',
                                options: {
                                    name: 'static/[hash].worker.js',
                                    publicPath: '/_next/'
                                }
                            }
                        ]
                    })
                    config.output.globalObject = `(typeof self !== 'undefined' ? self : this)`

                    config.module.rules.push({
                        test: /\.json$/,
                        loader: 'json-loader'
                    })
                    config.module.rules.push({
                        test: /\.svg$/,
                        exclude: /node_modules/,
                        loader: 'svg-react-loader',
                        query: {
                            classIdPrefix: '[name]-[hash:8]__',
                            filters: [],
                            propsMap: {
                                fillRule: 'fill-rule',
                                size: 'width',
                                color: 'stroke'
                            },
                            xmlnsTest: /^xmlns.*$/
                        }
                    })

                    config.plugins.push(
                        new LodashModuleReplacementPlugin({ shorthands: true })
                    )
                    // config.plugins.push(
                    //     new SentryCliPlugin({
                    //         authToken: env.SENTRY_AUTH_TOKEN,
                    //         release: env.SENTRY_RELEASE,
                    //         rewrite: true,
                    //         include: '.next',
                    //         dryRun: dev || env.SKIP_SENTRY,
                    //         debug: dev,
                    //         urlPrefix: `https://${env.DOMAIN}/_next/`
                    //     })
                    // )

                    if (dev) {
                        config.devtool = 'eval'
                    } else {
                        config.devtool = 'source-map'
                        for (const plugin of config.plugins) {
                            if (plugin.constructor.name === 'UglifyJsPlugin') {
                                plugin.options.sourceMap = true
                                break
                            }
                        }

                        if (config.optimization && config.optimization.minimizer) {
                            for (const plugin of config.optimization.minimizer) {
                                if (plugin.constructor.name === 'TerserPlugin') {
                                    plugin.options.sourceMap = true
                                    break
                                }
                            }
                        }
                    }

                    return config
                }
            })
        )
    )
}
