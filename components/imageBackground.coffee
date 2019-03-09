import React from 'react'

import anime from 'animejs'
import Color from 'color'
import _ from 'lodash'

import LoadingIndicator from '~/components/loadingIndicator'

import { getResolution } from '~/lib/img'

import colors from '~/styles/colors'

import config from '~/config'
import '~/lib/str'

WIDTHS = Object.values(config.WIDTH)
WIDTHS.sort()
COMMON_RATIO = 9 / 16

class ImageBackground extends React.Component
    constructor: (props) ->
        super props
        @crossfadeImgToImg2Bound = () => @crossfadeImgToImg2()
        @opacityTimeout = null
        @blurTimeout = null

        @state =
            background: ImageBackground.backgroundFallback(props)
            background2: ImageBackground.background(props)
            imgDisplay: 'block'
            imgOpacity: 1
            imgDisplay2: 'block'
            imgOpacity2: 1
            imgBlur2: @props.blur ? 0
            fadeDuration: props.fadeDuration ? 1000

    componentWillUnmount: ->
        image2 = document.querySelector ".background-image-2_#{ @imageId(2) }"
        image2?.removeEventListener('load', @crossfadeImgToImg2Bound)

        if @opacityTimeout
            clearTimeout(@opacityTimeout)
        if @blurTimeout
            clearTimeout(@blurTimeout)

    componentDidMount: ->
        return unless document?
        image2 = document.querySelector ".background-image-2_#{ @imageId(2) }"
        if image2? and not image2.complete
            @hideImage()

    hideImage: ->
        @setState
            imgDisplay2: 'none'
            imgOpacity2: 0
            imgBlur2: 120

    @getDerivedStateFromProps: (nextProps, prevState) ->
        newBackground = ImageBackground.background(nextProps)
        { src, srcSet } = newBackground
        { prevSrc, prevSrcSet } = prevState.background2
        if (src? and src isnt prevSrc) or (srcSet? and srcSet isnt prevSrcSet)
            return { background2: newBackground }
        return null

    @unsplashSource: ({ source, searchTerms, width, height, ratio }) ->
        width = Math.round(width)
        height = Math.round(height ? ratio * width)

        searchTerms = if searchTerms? then "?#{ searchTerms.join(',') }" else ''
        return "
            https://source.unsplash.com/\
            #{ width }x#{ height }/\
            #{ source }#{ searchTerms }"

    @localSource: ({ topic, number, name, width, fallback }) ->
        return if fallback
            "#{ config.STATIC }/img/fallbacks/#{ topic }/#{ name ? number }.svg"
        else
            "#{ config.STATIC }/img/bg/#{ topic }/bg_#{ name ? number }_#{ width }.jpg"

    @unsplashSrcSet: (unsplashProps) ->
        WIDTHS.map((width) ->
            "#{ ImageBackground.unsplashSource({
                unsplashProps...
                width
                ratio: COMMON_RATIO
            }) } #{ width }w"
        ).join(',')

    @localSrcSet: ({ number, name, topic = 'music' }) ->
        WIDTHS.map((width) ->
            "#{ ImageBackground.localSource({
                name
                number
                width
                topic
            }) } #{ width }w"
        ).join(',')

    @backgroundFallback: ({ background, local }) ->
        today = new Date().getDate()
        if local?
            switch local.timeSpan
                when 'weekly'
                    currentWeek = Math.round(today / 28 + 1)
                    src = ImageBackground.localSource({
                        local...
                        number: currentWeek
                        fallback: true
                    })
                else
                    src = ImageBackground.localSource({
                        local...
                        number: today
                        fallback: true
                    })
            return { src, srcSet: '' }
        return {
            src: ImageBackground.localSource({
                topic: 'music'
                number: today
                fallback: true
             })
            srcSet: ''
        }

    @background: ({ unsplash, background, local }) ->
        if background?.src? or background?.srcSet?
            return background

        if unsplash?
            src = ''
            if unsplash?.width? and (unsplash?.height? or unsplash?.ratio?)
                src = ImageBackground.unsplashSource(unsplash)
            srcSet = ImageBackground.unsplashSrcSet(unsplash)
            return { src, srcSet }

        today = new Date().getDate()
        if local?
            switch local.timeSpan
                when 'weekly'
                    currentWeek = Math.round(today / 28 + 1)
                    srcSet = ImageBackground.localSrcSet({
                        local...
                        number: currentWeek
                    })
                else
                    srcSet = ImageBackground.localSrcSet({
                        local...
                        number: today
                    })
            return { src: '', srcSet }

        return {
            src: ''
            srcSet: ImageBackground.localSrcSet({
                number: today
            })
        }

    imageId: (image = '') ->
        JSON.stringify(@state["background#{ image }"]).hash()

    crossfadeImgToImg2: () ->
        @setState(imgDisplay2: 'block')
        image2 = document.querySelector ".background-image-2_#{ @imageId(2) }"
        image2?.removeEventListener('load', @crossfadeImgToImg2Bound)

        blur = @props.blur ? 0
        @opacityTimeout = setTimeout((() => @setState(imgOpacity2: 1)), 50)
        @blurTimeout = setTimeout((() => @setState(imgBlur2: blur)), 250)

    render: () ->
        imageStyle = {
            position: 'absolute'
            width: '100%'
            height: '100%'
            zIndex: config.ZINDEX.imageBackground
            objectFit: 'cover'
            overflow: 'hidden'
            transition: "
                opacity 0.2s var(--ease-out-circ),
                filter #{ @state.fadeDuration / 1000 }s var(--ease-out-circ)
            "
            @props.imageStyle...
        }
        overlayStyle = {
            zIndex: config.ZINDEX.imageOverlay
            backgroundColor: @props.overlayColor
            height: '100%'
            cursor: if @props.clickable then 'pointer' else 'auto'
            transition: 'background-color 0.3s ease-out'
            @props.overlayStyle...
        }
        if @props.fillWindow
            imageStyle = {
                imageStyle...
                minWidth: '100vw'
                minHeight: '100vh'
            }
            overlayStyle = {
                overlayStyle...
                minWidth: '100vw'
                minHeight: '100vh'
            }
        if @props.overlayGradient?
            overlayStyle.background = @props.overlayGradient

        imgStyle1 = {
            display: @state.imgDisplay
            opacity: @state.imgOpacity
            imageStyle...
        }
        imgStyle2 = {
            imageStyle...
            filter: "blur(#{ @state.imgBlur2 }px)"
            display: @state.imgDisplay2
            opacity: @state.imgOpacity2
        }

        <div
            onClick={ @props.onClick }
            style={{ position: 'relative', @props.style... }}
            className="
                flex-center h-100 w-100 image
                #{ @props.className ? '' }">
            <img
                className="background-image_#{ @imageId() }"
                sizes={ @props.sizes ? '(orientation: portrait) 130vh, 100vw' }
                { @state.background... }
                style={ imgStyle1 } />
            <img
                className="background-image-2_#{ @imageId(2) }"
                sizes={ @props.sizes ? '(orientation: portrait) 130vh, 100vw' }
                onLoad={ @crossfadeImgToImg2Bound }
                { @state.background2... }
                style={ imgStyle2 } />
            <div
                style={ overlayStyle }
                className="
                    d-flex
                    justify-content-center
                    align-items-center
                    h-100 w-100 overlay
                    #{ if @props.fadeIn then 'fade-in' else '' }">
                { if @props.loading
                    <div className='
                        w-100vw h-100vh d-flex
                        justify-content-center
                        align-items-center'>
                        <LoadingIndicator className='w-100vw' />
                    </div>
                else
                    @props.children
                }
            </div>
        </div>


export default ImageBackground
