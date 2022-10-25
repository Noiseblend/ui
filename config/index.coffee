import getConfig from "next/config"

import colors from "~/styles/colors"
{ serverRuntimeConfig, publicRuntimeConfig } = getConfig()

DEV = publicRuntimeConfig.debug
LOADING_TEXTS = [
    "Flipping bits"
    "Crunching data"
    "Traveling back in time"
    "Reverse engineering Spotify protocols"
    "Borrowing pretty images from Unsplash"
    "Cloning Spotify's database"
    "Filtering out elevator music"
]

PEACH_SUNFLOWER_GRADIENT = "linear-gradient( 135deg, hsl(338.2, 16.4%, 86.9%) 0%, hsl(335, 4.8%, 51%) 100%)"
BLACK_GRAY_GRADIENT = "
    linear-gradient(
        to bottom,
        #{ colors.BLACK } 0%,
        #{ colors.BLACK.lighten(0.05) } 100%)"

config =
    NAVBAR_HEIGHT:
        desktop: 60
        mobile: 50
    STATIC: "#{ publicRuntimeConfig.staticDir }"
    DOMAIN: publicRuntimeConfig.domain
    WS_URL:
        if process.browser
            publicRuntimeConfig.remoteWsURL
        else
            publicRuntimeConfig.localWsURL
    SENTRY_DSN: publicRuntimeConfig.sentryDSN
    SENTRY_RELEASE: publicRuntimeConfig.sentryRelease
    SENTRY_ENVIRONMENT: publicRuntimeConfig.sentryEnvironment
    CACHE:
        name: "noiseblend"
        keys:
            AUTH_TOKEN: "authToken"

    ICON_VERSION: 4
    ICONS:
        android: [192]
        favicon: [16, 32, 96]
        apple: [57, 60, 72, 76, 114, 120, 144, 152, 180]

    PATHNAME_PATTERN: /\/[^?'#']*/
    DEFAULT_PAGE_PROPS:
        hideBrand: false
        icon: "app"
        color: colors.YELLOW.hex()
        background: colors.BLACK.s()
        manifest: "/static/manifest/manifest.json"
        title: "Noiseblend"
        description: "One-tap music for every occasion, with Spotify"
        navbar:
            background: colors.WHITE.alpha(0).s()
            color: colors.WHITE.s()
        brandColors:
            color: colors.FLASH_WHITE.s()
            hoverColor: colors.YELLOW.s()

    PAGE_PROPS:
        "/":
            color: colors.MAUVE.hex()
            navbar:
                background: colors.WHITE.alpha(0).s()
                color: colors.WHITE.s()
        "/about":
            title: "About Us"
        "/artists":
            background: PEACH_SUNFLOWER_GRADIENT
            navbar:
                color: colors.MUTED_RED.s()
            brandColors:
                color: colors.MUTED_RED.s()
                hoverColor: colors.MAUVE.s()
        "/blend":
            brandColors:
                color: colors.WHITE.s()
                hoverColor: colors.MAUVE.s()
        "/cities":
            background: PEACH_SUNFLOWER_GRADIENT
            navbar:
                color: colors.MUTED_RED.s()
            brandColors:
                color: colors.MUTED_RED.s()
                hoverColor: colors.MAUVE.s()
        "/countries":
            background: PEACH_SUNFLOWER_GRADIENT
            navbar:
                color: colors.MUTED_RED.s()
            brandColors:
                color: colors.MUTED_RED.s()
                hoverColor: colors.MAUVE.s()
        "/discover": {}
        "/genres":
            background: PEACH_SUNFLOWER_GRADIENT
            navbar:
                color: colors.MUTED_RED.s()
            brandColors:
                color: colors.MUTED_RED.s()
                hoverColor: colors.MAUVE.s()
        "/logout": {}
        "/playlist":
            background: BLACK_GRAY_GRADIENT
            brandColors:
                color: colors.WHITE.s()
                hoverColor: colors.YELLOW.s()
        "/privacy":
            title: "Privacy"
            background: colors.WHITE.s()
            navbar:
                background: colors.WHITE.alpha(0).s()
                color: colors.BLACK.s()
            brandColors:
                color: colors.BLACK.s()
                hoverColor: colors.YELLOW.s()
        "/terms":
            title: "Terms of Service"
            background: colors.WHITE.s()
            navbar:
                background: colors.WHITE.alpha(0).s()
                color: colors.BLACK.s()
            brandColors:
                color: colors.BLACK.s()
                hoverColor: colors.YELLOW.s()
        "/user":
            background: colors.BLACK_MAUVE.s()
            brandColors:
                color: colors.WHITE.s()
                hoverColor: colors.YELLOW.s()

    UNAUTHORIZED_PAGES: ["/", "/privacy", "/terms", "/about"]

    DEFAULTS:
        FADE_MINUTES: 1
        FADE_MIN: 1
        FADE_MAX: 30
        FADE_VOLUME_MIN: 5
        FADE_VOLUME_MAX: 70
        TIME_RANGE: "medium_term"
        COUNTRY: "United States"

    DEV: DEV
    PRODUCTION: not DEV
    AUTH_TOKEN_COOKIE_KEY: "authToken"
    AUTH_TOKEN_EXPIRATION_DAYS: 30

    DEBUG: DEV
    REDUX_DEBUG: false

    SIDEBAR_WIDTH: 380

    MAX_CARD_SIZE: 400
    CARD_RADIUS: 30
    CARD_LIMIT: 3
    CARD_OVERLAY_COLOR: colors.GRAY_MAUVE
        .alpha(0.7)
        .rgb()
        .string()
    CARD_VIEW_BACKGROUND: PEACH_SUNFLOWER_GRADIENT
    PLAYLIST_BACKGROUND: BLACK_GRAY_GRADIENT
    USER_BACKGROUND: colors.BLACK_MAUVE
    DEFAULT_IMAGE_OVERLAY: colors.MAUVE
        .desaturate(0.4)
        .darken(0.1)
        .alpha(0.7)
        .rgb()
        .string()

    FONTS:
        Mukta: [400, 600]

    TIME_RANGE_MAPPING:
        short_term: "Last Month"
        medium_term: "Last 6 Months"
        long_term: "Last few years"

    LOADING_TEXTS: LOADING_TEXTS
    ARTIST_LOADING_TEXTS: [
        LOADING_TEXTS...
        "Spying on your past self listening to music"
        "Asking your friends about your musical tastes"
    ]

    GENRE_LOADING_TEXTS: [
        LOADING_TEXTS...
        "Categorizing about 30 million songs"
        "Hiring professional poets to name genres"
        "Training an AI to write haikus"
    ]

    COUNTRY_LOADING_TEXTS: [
        LOADING_TEXTS...
        "Traveling around the world"
        "Infiltrating governments"
        "Decrypting transatlantic communication"
    ]

    CITY_LOADING_TEXTS: [
        LOADING_TEXTS...
        "Spying on your neighbors listening to music"
        "Breaking into your neighbor's Spotify account"
        "Finding your exact location"
    ]
    DEVICE_ICON:
        Computer: "laptop"
        Speaker: "headphones"
        TV: "television"
        Smartphone: "mobile"
        Tablet: "tablet"
        Car: "car"
        Console: "gamepad"

    POPULARITY_BY_INDEX: [
        "sound"
        "pulse"
        "edge"
        "current"
        "emerging"
        "underground"
        "year"
        "all"
        "intro"
    ]
    PLAYLIST_DESCRIPTIONS:
        country:
            pineNeedle: "Emerging Christmas music from { country }"
            needle:
                all: 'Scattered outbursts of { country }\'s love,
                      collected by Spotify\'s curious machine'
                current: 'The electric pulse of { country }\'s love,
                          detected by Spotify\'s curious machine'
                emerging: 'The hopes and futures of { country }\'s love,
                           detected by Spotify\'s curious machine'
                underground: 'The most secret glimmerings of { country }\'s love,
                              detected by Spotify\'s curious machine'
        genre:
            meta:
                year: "Songs that fans of { genre } were listening to in { year }"
                pulse: "Emerging songs that fans of { genre } are listening to right now"
                edge: "Less known songs that fans of { genre } are listening to right now"
            normal:
                intro: 'An attempted algorithmic introduction to { genre }
                        based on math and listening data from the Large Genre Collider'
                year: "Most listened { genre } songs in { year }"
                sound: "Most popular songs from the { genre } genre"
                pulse: "Emerging songs from the { genre } genre"
                edge: "Less-known songs from the { genre } genre"
    POPULARITY:
        SOUND: 0
        PULSE: 1
        EDGE: 2
        CURRENT: 3
        EMERGING: 4
        UNDERGROUND: 5
        YEAR: 6
        ALL: 7
        INTRO: 8

    POPULARITY_TITLE: [
        "Mainstream"
        "Up-and-coming"
        "Not for the masses"
        "Mainstream"
        "Up-and-coming"
        "Not for the masses"
        "Last year's hits"
        "Doesn't matter"
        "Algorithmical Intro"
    ]

    TUNEABLE_ATTRIBUTES:
        acousticness:
            min: 0.0
            max: 1.0
            unit: null
            step: 0.01
        danceability:
            min: 0.0
            max: 1.0
            unit: null
            step: 0.01
        energy:
            min: 0.0
            max: 1.0
            unit: null
            step: 0.01
        instrumentalness:
            min: 0.0
            max: 1.0
            unit: null
            step: 0.01
        liveness:
            min: 0.0
            max: 1.0
            unit: null
            step: 0.01
        loudness:
            min: -60.0
            max: 0.0
            unit: "db"
            step: 0.01
        popularity:
            min: 0
            max: 100
            unit: null
            step: 1
        speechiness:
            min: 0.0
            max: 1.0
            unit: null
            step: 0.01
        tempo:
            min: 0
            max: 320
            unit: "bpm"
            step: 1
        valence:
            min: 0.0
            max: 1.0
            unit: null
            step: 0.01
            name: "Happiness"
        durationMs:
            min: 0.0
            max: 10.0
            unit: "minutes"
            step: 0.5
            name: "Duration"

    WIDTH:
        damn: 8120
        fivekay: 5260
        fourkay: 3840
        twokay: 2560
        onekay: 1920
        large: 1280
        medium: 992
        mobile: 768
        prisonCellphone: 320
        toothbrush: 64

    ZINDEX:
        imageBackground: 0
        imageOverlay: 0
        normal: 2
        circularMenu: 3
        alert: 9
        undoButton: 10

    MEASUREMENTS:
        SIDEBAR_ATTRIBUTE_VALUE: "nb_sidebar_attribute_value"
        SIDEBAR_ATTRIBUTE_ORDER: "nb_sidebar_attribute_order"
        ROUTE_CHANGE: "nb_route_change"
        BLEND_PLAY: "nb_blend_play"

    POLLING:
        DONATE_BUTTON: if DEV then 50 else 1000
        DEVICE_FETCHER_SLOW: if DEV then 60000 else 30000
        DEVICE_FETCHER_FAST: if DEV then 10000 else 3000
        WINDOW_RESIZE: 500
        APPLY_TUNING: 300
        CHANGE_PLAYLIST_NAME: 700
        SEARCH: 500
        EMAIL_VALIDATION: 200

    BLENDS:
        workoutHype:
            name: "Workout Hype"
            dashedName: "workout-hype"
            description: '
                Songs to get you pumped and sweaty,
                with a progression from mellow tempo to high energy
            '
            color: colors.GREEN
            icon: "dumbbell"
            urlParams:
                blend: "workoutHype"
        deepFocus:
            name: "Deep Focus"
            dashedName: "deep-focus"
            description: '
                Get yourself into a productive state of mind,
                with soft, serene tracks free of distracting lyrics
            '
            color: colors.GRAY_BLUE
            icon: "brain"
            urlParams:
                blend: "deepFocus"
        mellowDinner:
            name: "Mellow Dinner"
            dashedName: "mellow-dinner"
            description: '
                Laid-back soundtrack for an ideal night in the
                company of your closest friends
            '
            color: colors.MARS_RED
            icon: "dinner-plate"
            urlParams:
                blend: "mellowDinner"
        romanticNight:
            name: "Romantic Night"
            dashedName: "romantic-night"
            description: '
                Charming songs to accompany your candle-lit night
            '
            color: colors.RED
            icon: "hearts"
            urlParams:
                blend: "romanticNight"
        morningStroll:
            name: "Morning Stroll"
            dashedName: "morning-stroll"
            description: '
                Take a short detour from reality with your
                most beloved songs and a few surprising additions
            '
            color: colors.SUNFLOWER
            icon: "sun"
            urlParams:
                blend: "morningStroll"
        eveningCommute:
            name: "Evening Commute"
            dashedName: "evening-commute"
            description: '
                Some easygoing music for leaving your daily duties behind
            '
            color: colors.ORANGE
            icon: "car"
            urlParams:
                blend: "eveningCommute"
        immersiveReading:
            name: "Immersive Reading"
            dashedName: "immersive-reading"
            description: '
                Let the storyline come alive and
                forget the real world for a while
            '
            color: colors.GRAY_MAUVE.lighten(0.3)
            icon: "book"
            urlParams:
                blend: "immersiveReading"
        peacefulSleep:
            name: "Peaceful Sleep"
            dashedName: "peaceful-sleep"
            description: '
                Stop counting sheeps.
            '
            color: colors.BLUE
            icon: "moon"
            fade:
                minutes: 20
                direction: -1
            urlParams:
                blend: "peacefulSleep"
                fade: true
                force: true
                step: 1
                startVolume: 50
                stopVolume: 0
                timeMinutes: 20

    KEY_MAPPING: ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    # coffeelint: disable=max_line_length
    EMAIL_REGEX:
        /^(([^<>()\[\]\\.,;:\s@']+(\.[^<>()\[\]\\.,;:\s@']+)*)|('.+'))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    # coffeelint: enable=max_line_length

    ALEXA_REDIRECT_URIS: [
        "https://alexa.amazon.co.jp/api/skill/link/MRZXYFHART641"
        "https://pitangui.amazon.com/api/skill/link/MRZXYFHART641"
        "https://layla.amazon.com/api/skill/link/MRZXYFHART641"
    ]

for blend, blendConfig of config.BLENDS
    blendConfig.overlayColor = blendConfig.color
        .desaturate(0.7)
        .alpha(0.6)
        .darken(0.4)
        .s()
    blendConfig.color = blendConfig.color.s()

export default config
