import React from 'react'
import { connect } from 'react-redux'

import _ from 'lodash'
import Link from 'next/link'

import Card from '~/components/card'
import CloseButton from '~/components/closeButton'
import RoundedButton from '~/components/roundedButton'
import ToggleButton from '~/components/toggleButton'

import CountryActions from '~/redux/countries'
import GenreActions from '~/redux/genres'
import UIActions from '~/redux/ui'

import colors from '~/styles/colors'
import {
    Activity,
    CloudSnow,
    Cpu,
    Disc,
    Gift,
    Globe,
    Radio,
    TrendingUp,
} from '~/styles/icons'

import config from '~/config'

MAINSTREAM = 0
UP_AND_COMING = 1
NOT_FOR_THE_MASSES = 2
ADDITIONAL = 3

getPopularity = (pop, type) ->
    switch pop
        when MAINSTREAM
            if type is 'genre'
                config.POPULARITY.SOUND
            else
                config.POPULARITY.CURRENT
        when UP_AND_COMING
            if type is 'genre'
                config.POPULARITY.PULSE
            else
                config.POPULARITY.EMERGING
        when NOT_FOR_THE_MASSES
            if type is 'genre'
                config.POPULARITY.EDGE
            else
                config.POPULARITY.UNDERGROUND
        when ADDITIONAL
            if type is 'genre'
                [config.POPULARITY.INTRO, config.POPULARITY.YEAR]
            else
                [config.POPULARITY.ALL]

findPlaylist = (playlists, playlistType, {
    popularity, meta = false,
    christmas = false, year = false, women = false,
}) ->
    playlists.find(
        (p) ->
            p.popularity is popularity and
            p.meta is meta and
            (p.christmas is christmas or playlistType is 'genre') and
            p.women is women and
            p.year? is year
    )

thereAreAdditionalPlaylists = (playlists) ->
    playlists.find((p) ->
        p.meta or
        p.christmas or
        p.popularity in [
            config.POPULARITY.INTRO,
            config.POPULARITY.YEAR,
            config.POPULARITY.ALL
        ]
    )

getTitle = (playlist) ->
    title = config.POPULARITY_TITLE[playlist.popularity]
    if playlist.meta
        "Meta: #{ title }"
    else
        title

getIcon = (playlist) ->
    switch playlist.popularity
        when config.POPULARITY.SOUND, config.POPULARITY.CURRENT
            Globe
        when config.POPULARITY.PULSE, config.POPULARITY.EMERGING
            Activity
        when config.POPULARITY.EDGE, config.POPULARITY.UNDERGROUND
            Radio
        when config.POPULARITY.ALL
            Gift
        when config.POPULARITY.INTRO
            Cpu
        when config.POPULARITY.YEAR
            TrendingUp
        else
            if playlist.christmas
                CloudSnow
            else
                Disc

getColor = (playlist) ->
    switch playlist.popularity
        when config.POPULARITY.SOUND, config.POPULARITY.CURRENT
            colors.BLUE
        when config.POPULARITY.PULSE, config.POPULARITY.EMERGING
            colors.YELLOW
        when config.POPULARITY.EDGE, config.POPULARITY.UNDERGROUND
            colors.RED
        when config.POPULARITY.ALL
            colors.WHITE
        when config.POPULARITY.INTRO
            colors.GRAY_BLUE
        when config.POPULARITY.YEAR
            colors.RED
        else
            if playlist.christmas
                colors.GREEN
            else
                colors.PEACH


setHeightAuto = (e) -> e.target.style.height = 'auto'

toggleAdditionalPlaylists = (showAdditionalPlaylists) ->
    container = document.getElementById('additional-playlists')

    if showAdditionalPlaylists
        container.style.height = "#{ container.scrollHeight + 49 }px"
        container.addEventListener('transitionend', setHeightAuto)
        setTimeout((
            () ->
                container.removeEventListener('transitionend', setHeightAuto)
        ), 1000)
    else
        container.style.height = "#{ container.scrollHeight }px"
        setTimeout((
            () -> container.style.height = '0px'
        ), 50)

SimplePopularityPlaylists = ({
    popularities, query = { }, item, playlists,
    color, textColor, playlistType, onClick
}) -> popularities.map((popularity, i) ->
    playlist = findPlaylist(playlists, playlistType, { popularity, query... })
    if playlist?
        playlistColor = getColor(playlist)
        if playlistColor.contrast(textColor) < 1.5
            if textColor.isLight()
                playlistColor = playlistColor.darken(0.1)
            else
                playlistColor = playlistColor.lighten(0.1)
        <Link
            prefetch
            key={ i }
            href={{
                pathname: '/playlist',
                query:
                    id: playlist?.id
                    image: btoa(item?.image?.url ? '')
                    user: playlist?.owner
            }}>
            <a>
                <Card
                    onClick={ onClick }
                    size={ 210 }
                    color={ playlistColor }
                    backgroundColor={ textColor }
                    icon={ getIcon(playlist) }
                    title={ getTitle(playlist) }
                    className='my-3 mx-lg-3'>
                </Card>
            </a>
        </Link>
)
PopularityPlaylists = connect(
    () -> {},
    (dispatch) ->
        onClick: _.debounce(
            (() ->
                dispatch([
                    GenreActions.deselectGenre()
                    CountryActions.deselectCountry()
                ])
            ), 1000
        )
)(SimplePopularityPlaylists)

MorePlaylists = ({
    setShowAdditionalPlaylists, showAdditionalPlaylists,
    children, textColor
}) ->
    <div className='
        my-3 mx-auto'>
        <ToggleButton
            className='py-2 mb-4'
            toggled={ showAdditionalPlaylists }
            color={ textColor }
            onClick={ () ->
                toggleAdditionalPlaylists(not showAdditionalPlaylists)
                setShowAdditionalPlaylists(not showAdditionalPlaylists)
            }>
            { if showAdditionalPlaylists then 'Less' else 'More' }
        </ToggleButton>
        <div
            style={
                overflow: 'hidden'
                height: 0
                transition: 'height 0.6s var(--ease-out-expo)'
            }
            id='additional-playlists'
            className='
                d-flex flex-wrap
                flex-column flex-lg-row
                justify-content-center
                align-items-center' >
            { children }
        </div>
    </div>


PlaylistQuiz = ({
    color, textColor, playlists, playlistType, item,
    style, className, props...
}) ->
    <div
        style={{
            height: '100vh'
            style...
        }}
        className="text-center popularity-quiz #{ className ? '' }">
        <CloseButton
            onClose={ () ->
                props.setShowAdditionalPlaylists(false)
                props.deselectItem()
            }
            color={ textColor }
        />
        <h1
            className='text-center'
            style={
                marginTop: '10vh'
                color: textColor
            }>
            { item?.name.toTitleCase() }
        </h1>
        <div className='d-table-cell align-middle w-100vw px-3 text-center quiz'>
            <h3
                className='text-center mb-5'
                style={ color: textColor }>
                How popular would you like your music to be?
            </h3>
            <div className='
                    mb-3 d-flex flex-wrap
                    flex-column flex-lg-row
                    justify-content-center
                    align-items-center'>
                <PopularityPlaylists
                    playlists={ playlists }
                    playlistType={ playlistType }
                    item={ item }
                    popularities={[
                        getPopularity(MAINSTREAM, playlistType)
                        getPopularity(UP_AND_COMING, playlistType)
                        getPopularity(NOT_FOR_THE_MASSES, playlistType)
                    ]}
                    textColor={ textColor }
                    color={ color }
                />
            </div>
        </div>
        {if thereAreAdditionalPlaylists(playlists)
            <MorePlaylists
                textColor={ if textColor.isLight()
                    textColor.darken(0.25)
                else
                    textColor.lighten(0.25) }
                { props... }>
                <PopularityPlaylists
                    playlists={ playlists }
                    item={ item }
                    query={ meta: true }
                    popularities={[
                        getPopularity(MAINSTREAM, playlistType)
                        getPopularity(UP_AND_COMING, playlistType)
                        getPopularity(NOT_FOR_THE_MASSES, playlistType)
                    ]}
                    textColor={ textColor }
                    color={ color }
                />
                <PopularityPlaylists
                    playlists={ playlists }
                    item={ item }
                    popularities={ getPopularity(ADDITIONAL, playlistType) }
                    textColor={ textColor }
                    color={ color }
                />
            </MorePlaylists>
        else
            <div className="placeholder" />
        }
        <style jsx>{"""#{} // stylus
            .popularity-quiz
                opacity 0
                overflow scroll
                -webkit-overflow-scrolling touch
                reveal opacity 1s 0.2s

                &::-webkit-scrollbar
                    display none

                .quiz
                    height 70vh
        """}</style>
     </div>

mapStateToProps = (state) ->
    showAdditionalPlaylists: state.ui.showAdditionalPlaylists

mapDispatchToProps = (dispatch) ->
    setShowAdditionalPlaylists: (st) -> dispatch(UIActions.setShowAdditionalPlaylists(st))


export default connect(mapStateToProps, mapDispatchToProps)(PlaylistQuiz)
