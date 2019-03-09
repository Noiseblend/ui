Meta = (props) ->
    [
        <meta charSet='utf-8' />
        <meta
            content='
                width=device-width,
                initial-scale=1.0,
                maximum-scale=1.0,
                user-scalable=0,
                shrink-to-fit=no'
            name='viewport' />
        <meta
            name="image"
            content={ props.image }
        />
        <meta
            itemProp="name"
            content={ props.name }
        />
        <meta
            itemProp="description"
            content={ props.description }
        />
        <meta
            itemProp="image"
            content={ props.image }
        />
        <meta
            property="og:title"
            content={ props.openGraph.title ? props.name }
        />
        <meta
            property="og:description"
            content={ props.openGraph.description ? props.description }
        />
        <meta
            property="og:image"
            content={ props.openGraph.image ? props.image }
        />
        <meta
            property="og:url"
            content={ props.openGraph.url }
        />
        <meta
            property="og:site_name"
            content={ props.openGraph.siteName ? props.name }
        />
        <meta
            property="og:type"
            content={ props.openGraph.type }
        />
        <meta
            property="fb:admins"
            content={ props.facebook.admins.join(',') }
        />
        <meta
            property="fb:app_id"
            content={ props.facebook.appID }
        />
        <meta
            name='apple-mobile-web-app-status-bar-style'
            content={ props.appleMobileWebAppStatusBarStyle }
        />
        <meta
            name='mobile-web-app-capable'
            content={if props.appleMobileWebAppCapable
                'yes'
            else
                'no'
            } />
    ]

export default Meta
