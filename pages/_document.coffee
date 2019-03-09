import Document, { Head, Main, NextScript } from 'next/document'

import Links from '~/components/links'
import Meta from '~/components/meta'

import config from '~/config'


export default class MyDocument extends Document
    @getInitialProps: (ctx) ->
        initialProps = await Document.getInitialProps(ctx)
        return { initialProps... }

    googleFonts: (fonts) ->
        fontString = ("#{ name }:#{ weights.join(',') }" for name, weights of fonts).join('|')
        "https://fonts.googleapis.com/css?family=#{ fontString }"

    render: ->
        <html>
            <Head>
                <Meta
                    name='Noiseblend'
                    description="One-tap music for every occasion, with Spotify"
                    image="#{ config.STATIC }/img/screenshot.jpg"
                    openGraph={
                        url: 'https://www.noiseblend.com'
                        type: 'website'
                    }
                    facebook={
                        admins: [
                            '100006835027136'
                            '100000694005206'
                        ]
                        appID: '601429796888451'
                    }
                    appleMobileWebAppStatusBarStyle='black'
                    appleMobileWebAppCapable
                />
                <Links
                    css={[
                        "#{ config.STATIC }/css/bootstrap.css"
                        "#{ config.STATIC }/css/app.css"
                        "#{ config.STATIC }/css/tippy.css"
                        @googleFonts(config.FONTS)
                    ]}
                />
            </Head>
            <body>
                <Main />
                <NextScript />
            </body>
        </html>
