import '~/styles/fontawesome'
import React from 'react'
import { connect } from 'react-redux'

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'

import anime from 'animejs'

import TextButton from '~/components/textButton'

import { anyObj } from '~/lib/util'

import UIActions from '~/redux/ui'

import colors from '~/styles/colors'
import { Globe, Settings, Smartphone } from '~/styles/icons'


OPEN_ACTION_HEIGHT =
    desktop: 55
    mobile: 40

OPEN_ACTION_WIDTH =
    desktop: 200
    mobile: 150

HIDDEN_WIDTH =
    desktop: 120
    mobile: 100



class Actions extends React.PureComponent
    showOpenActions: () ->
        size = if @props.mobile then 'mobile' else 'desktop'
        anime.timeline(duration: 600).add(
            targets: '.open-links'
            width: OPEN_ACTION_WIDTH[size]
        ).add(
            targets: '.open-button'
            translateY: -OPEN_ACTION_HEIGHT[size]
            offset: '-=500'
            delay: (el, i) -> i * 150
        ).add(
            targets: '.open-button'
            translateY: 0
            delay: 6000
        ).add(
            targets: '.open-links'
            offset: '-=400'
            width: HIDDEN_WIDTH[size]
            complete: () => @props.setOpenLinksVisible(false)
        )

    componentDidUpdate: (prevProps, prevState, snapshot) ->
        savedPlaylist = prevProps.saving and not @props.saving
        clickedOpen = not prevProps.openLinksVisible and @props.openLinksVisible
        if clickedOpen
            @showOpenActions()
        if savedPlaylist
            @props.setOpenLinksVisible(true)

    render: ->
        if @props.mobile
            size = 'mobile'
            iconSize = 24
            fontSize = '1rem'
            brandSize = '1.5rem'
        else
            size = 'desktop'
            iconSize = 30
            fontSize = '1.2rem'
            brandSize = '1.6rem'
        uri = @props.playlist?.uri
        spotifyUrl = @props.playlist?.externalUrls?.spotify

        <div
            className='d-flex justify-content-start align-items-center my-2 actions'
            style={{
                height: OPEN_ACTION_HEIGHT[size]
                fontSize: fontSize
                @props.style...
            }}>
            <div
                style={ overflow: 'hidden' }
                className='
                    h-100 mr-2
                    d-flex flex-column
                    justify-content-between
                    align-items-center
                    open-action'>
                <TextButton
                    style={ minHeight: OPEN_ACTION_HEIGHT[size] }
                    disabled={ not (spotifyUrl? or uri?) }
                    color={ colors.ACTION }
                    disabledColor={ colors.GRAY }
                    onClick={ () => @props.setOpenLinksVisible(true) }
                    className='
                        d-flex h-100
                        justify-content-between
                        align-items-center
                        open-button'>
                    <FontAwesomeIcon
                        style={ fontSize: brandSize }
                        icon={ ['fab', 'spotify'] } />
                    <span className='font-heading ml-2'>Open</span>
                </TextButton>
                <div
                    style={
                        width: HIDDEN_WIDTH[size]
                        minHeight: OPEN_ACTION_HEIGHT[size]
                    }
                    className='d-flex px-2 open-links'>
                    <a
                        style={
                            textDecoration: 'none'
                        }
                        target='_blank'
                        rel='noopener noreferrer'
                        href={ spotifyUrl }>
                        <TextButton
                            style={
                                minHeight: OPEN_ACTION_HEIGHT[size]
                            }
                            disabled={ not spotifyUrl? or not @props.openLinksVisible }
                            color={ colors.ACTION }
                            disabledColor={ colors.GRAY }
                            className='
                                d-flex p-0 mr-2
                                justify-content-between
                                align-items-center
                                open-button'>
                            <Globe size={ iconSize } />
                            <span className='font-heading ml-2'>Web</span>
                        </TextButton>
                    </a>
                    <a
                        style={
                            textDecoration: 'none'
                        }
                        href={ uri }>
                        <TextButton
                            style={
                                minHeight: OPEN_ACTION_HEIGHT[size]
                            }
                            disabled={ not uri? or not @props.openLinksVisible }
                            color={ colors.ACTION }
                            disabledColor={ colors.GRAY }
                            className='
                                d-flex p-0
                                justify-content-between
                                align-items-center
                                open-button'>
                            <Smartphone size={ iconSize } />
                            <span className='font-heading ml-2'>App</span>
                        </TextButton>
                    </a>
                </div>
            </div>
            <TextButton
                className='
                    h-100
                    d-flex
                    align-items-center
                    justify-content-between
                    save-button'
                color={ colors.ACTION }
                disabledColor={ colors.GRAY }
                disabled={ @props.saving or not anyObj(@props.modified) }
                onClick={ @props.onSavePlaylist }>
                {if @props.saving
                    <Settings size={ iconSize } className='spin-alternate-fast' />
                else
                    <FontAwesomeIcon
                        style={ fontSize: brandSize }
                        icon={ ['fab', 'spotify'] } /> }
                {if @props.saving
                    <span className='ml-2'>Saving</span>
                else
                    <span className='ml-2'>Save</span>}
            </TextButton>
        </div>

mapStateToProps = (state) ->
    openLinksVisible: state.ui.openLinksVisible
    modified        : state.playlists.present.modified
    playlist        : state.playlists.present.playlist
    mobile          : state.ui.mobile
    saving          : (
        state.playlists.present.loading.savingPlaylist or
        state.playlists.present.loading.cloningPlaylist or
        state.playlists.present.loading.filteringPlaylist or
        state.playlists.present.loading.renamingPlaylist or
        state.playlists.present.loading.reorderingPlaylist or
        state.playlists.present.loading.replacingTracks
    )

mapDispatchToProps = (dispatch) ->
    batchActions: (actions) -> dispatch(actions)
    setOpenLinksVisible: (state) -> dispatch(UIActions.setOpenLinksVisible(state))

export default connect(mapStateToProps, mapDispatchToProps)(Actions)
