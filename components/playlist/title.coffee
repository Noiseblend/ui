import React from 'react'
import { connect } from 'react-redux'

import _ from 'lodash'

import PlaylistActions from '~/redux/playlists'

import colors from '~/styles/colors'
import { fluid } from '~/styles/util'

import config from '~/config'


PlaylistTitle = ({
    style, className = '', name, setName, setPlaylistName
}) ->
    textSize = fluid(22, 50, config.WIDTH.prisonCellphone, config.WIDTH.twokay)
    <div
        style={ style }
        className="header #{ className }">
        <h1
            className='flex-center m-0 px-1 hashtag'
            style={ color: colors.MAROON.darken(0.4) }>
            #
        </h1>
        <h1 className='m-0 playlist-name'>
            <input
                type='text'
                onChange={ (e) ->
                    e.persist()
                    setName(e.target.value)
                    setPlaylistName(e.target.value)}
                value={ name }
                className='font-heading playlist-name-input' />
        </h1>
        <p
            className='edit-hint'
            style={
                color: colors.MAROON.darken(0.3)
                lineHeight: 1
            }>
            Tap title to edit playlist name
        </p>
        <style jsx>{"""#{} // stylus
            .header
                display grid
                grid-template-columns 20px 1fr
                grid-template-areas: 'hashtag name'\
                                     '. hint'

            .hashtag, .playlist-name
                font-size #{ textSize }

            .hashtag
                grid-area hashtag

            .playlist-name
                grid-area name

            .edit-hint
                grid-area hint
                margin 0

            .playlist-name-input
                color white
                font-weight bold
                background-color transparent
                border none
                outline none
                min-height 50px
                caret-color magenta
                text-overflow ellipsis
                width 100%
                @media (min-width: #{ config.WIDTH.mobile }px)
                    width calc(100% - 5.5rem)

            .hashtag, .playlist-name
                color white
                font-weight bold

            @media (min-width: #{ config.WIDTH.medium }px)
                .header
                    display grid
                    grid-template-columns 40px 1fr
        """}</style>
    </div>

mapStateToProps = (state) ->
    name: state.playlists.present.name

mapDispatchToProps = (dispatch) ->
    setName: (name) -> dispatch(PlaylistActions.setName(name))
    setPlaylistName: _.debounce(
        ((name) -> dispatch(PlaylistActions.setPlaylistName(name))),
        config.POLLING.CHANGE_PLAYLIST_NAME
    )

export default connect(mapStateToProps, mapDispatchToProps)(PlaylistTitle)
