import React from 'react'
import { connect } from 'react-redux'

import TextButton from '~/components/textButton'

import { classif } from '~/lib/util'

import ArtistActions from '~/redux/artists'

import colors from '~/styles/colors'
import { Loader, Search, X } from '~/styles/icons'

SearchInput = ({
    query, onFocus, onBlur, id, className = '',
    disabled, focused, search, searching, props...
}) ->
    <div
        id={ id }
        className="
            d-flex justify-content-between align-items-center
            search-input-group
            #{ classif focused and not disabled, 'focus' }
            #{ className ? '' }"
        onFocus={ props.focusInput }
        onBlur={ props.defocusInput }>
        <div className="d-flex justify-content-center align-items-center input-left">
            <Search
                className='my-auto'
                size={ 16 }
                style={
                    minWidth: 16
                }
                color="#{
                    if focused
                        colors.DARK_GRAY
                    else
                        colors.WHITE.alpha(0.9)}" />
            <input
                style={ backgroundColor: 'transparent' }
                type='text'
                disabled={ disabled }
                value={ query ? '' }
                placeholder='Type to search...'
                onChange={ (e) ->
                    e.persist()
                    search(e.target.value) }
                className='ml-1 flex-grow-1 search-input' />
        </div>
        <TextButton
            className='
                d-flex justify-content-center
                align-items-center
                reset-input-button'
            color={ if focused then colors.PEACH else colors.WHITE }
            onClick={ () -> search('') }
            disabled={ query?.length is 0 or disabled }>
            {if searching
                <Loader className='my-auto spin-alternate-fast' />
            else
                <X className='my-auto' />}
        </TextButton>
        <style global jsx>{"""#{} // stylus
            .reset-input-button.disabled:hover,
            .reset-input-button.disabled:focus
                cursor auto

            .reset-input-button.disabled
                display none !important

            .reset-input-button
                line-height 51px
                margin 0
                padding 0
        """}</style>
        <style jsx>{"""#{} // stylus
            .search-input-group
                ease-out expo 0.4s background-color width
                background-color alpha(white, 0.2)
                min-width 200px
                width 200px
                height 36px
                border-radius 18px
                padding-left 0.5rem
                padding-right 0.5rem
                outline none

                &:hover
                    background-color alpha(white, 0.5)

                &.focus .reset-input-button:not(.disabled)
                    color red !important

                &.focus .reset-input-button:not(.disabled):hover,
                &.focus .reset-input-button:not(.disabled):focus
                    color #{ colors.RED.lighten(0.3).rotate(30) } !important

                &.focus
                    background-color alpha(white, 0.9)
                    box-shadow: 0 8px 12px alpha(black, 0.2), 0 4px 8px alpha(black, 0.1)
                    width 250px
                    border none

                .search-input
                    font-size 0.9rem
                    background-color transparent
                    caret-color yellow
                    color alpha(black, 0.6)
                    border none
                    outline none
                    padding-left 0.5rem !important
                    border-radius 15px

                    &::placeholder
                        color alpha(white, 0.9)
                        transition color 0.2s ease-in

                    &:focus::placeholder
                        color alpha(lightGray, 0.6)

                    &:hover
                    &:focus
                        background-color transparent
                        color black
                        border none

        """}</style>
    </div>

mapStateToProps = (state) ->
    focused: state.artists.present.inputFocused
    query  : state.artists.present.query

mapDispatchToProps = (dispatch) ->
    focusInput: () -> dispatch(ArtistActions.focusInput())
    defocusInput: () -> dispatch(ArtistActions.defocusInput())


export default connect(mapStateToProps, mapDispatchToProps)(SearchInput)
