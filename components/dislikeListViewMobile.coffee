import DislikeList from '~/components/dislikeList'

import { classif } from '~/lib/util'

import colors from '~/styles/colors'
import { BarChart2, Disc, Map, Users } from '~/styles/icons'

import config from '~/config'


DislikeListViewMobile = ({ activeTab, props... }) ->
    <div className='
        d-flex flex-column
        justify-content-between
        align-items-center
        bottom-container'>
        <div className='tab-content'>
            <div
                className="tab-pane #{ classif(activeTab is 'artists', 'active') }"
                id='artists-tab'>
                <DislikeList
                    mobile={ true }
                    items={ props.dislikes.artists }
                    removeDislike={
                        (item) ->
                            props.removeDislike('artists', item)}
                    itemsName='Artists'
                    fetching={ props.fetching } />
            </div>
            <div
                className="tab-pane #{ classif(activeTab is 'genres', 'active') }"
                id='genres-tab'>
                <DislikeList
                    mobile={ true }
                    items={ props.dislikes.genres }
                    removeDislike={
                        (item) ->
                            props.removeDislike('genres', item)}
                    itemsName='Genres'
                    fetching={ props.fetching } />
            </div>
            <div
                className="tab-pane #{ classif(activeTab is 'cities', 'active') }"
                id='cities-tab'>
                <DislikeList
                    mobile={ true }
                    items={ props.dislikes.cities }
                    removeDislike={
                        (item) ->
                            props.removeDislike('cities', item)}
                    itemsName='Cities'
                    fetching={ props.fetching } />
            </div>
            <div
                className="tab-pane #{ classif(activeTab is 'countries', 'active') }"
                id='countries-tab'>
                <DislikeList
                    mobile={ true }
                    items={ props.dislikes.countries }
                    removeDislike={
                        (item) ->
                            props.removeDislike('countries', item)}
                    itemsName='Countries'
                    fetching={ props.fetching } />
            </div>
        </div>
        <nav className='d-flex justify-content-around align-items-center bottom-tabs'>
            <div
                onClick={ () -> props.activateTab('artists') }
                className="
                    d-flex flex-column
                    justify-content-center
                    align-items-center
                    font-heading text-center tab
                    #{ classif(activeTab is 'artists', 'active') }">
                <Users color="#{ colors.WHITE.alpha(0.9) }" size={ 22 } />
                Artists
            </div>
            <div
                onClick={ () -> props.activateTab('genres') }
                className="
                    d-flex flex-column
                    justify-content-center
                    align-items-center
                    font-heading text-center tab
                    #{ classif(activeTab is 'genres', 'active') }">
                <Disc color="#{ colors.WHITE.alpha(0.9) }" size={ 22 } />
                Genres
            </div>
            <div
                onClick={ () -> props.activateTab('cities') }
                className="
                    d-flex flex-column
                    justify-content-center
                    align-items-center
                    font-heading text-center tab
                    #{ classif(activeTab is 'cities', 'active') }">
                <Map color="#{ colors.WHITE.alpha(0.9) }" size={ 22 } />
                Cities
            </div>
            <div
                onClick={ () -> props.activateTab('countries') }
                className="
                    d-flex flex-column
                    justify-content-center
                    align-items-center
                    font-heading text-center tab
                    #{ classif(activeTab is 'countries', 'active') }">
                <BarChart2 color="#{ colors.WHITE.alpha(0.9) }" size={ 22 } />
                Countries
            </div>
        </nav>
        <style global jsx>{"""#{} // stylus
            .dislike-list-container
                height 100%
                width 100vw

            .dislike-list
                width 100vw
                border-radius 0
                box-shadow none
                height 100%
        """}</style>
        <style jsx>{"""#{} // stylus
            .bottom-container
                height 100%
                background-color userBg

            .tab-content, .tab-pane
                height calc(100% - 35px)

            .tab-pane
                display none

                &.active
                    display block

            .bottom-tabs
                fixed bottom left
                border-top 1px solid alpha(white, 0.2)
                height 70px
                width 100vw
                padding 0

                .tab
                    color: white - 20%
                    width 25vw
                    margin 0
                    padding 0
                    border none

                    &:hover
                        color white !important
                    &.active
                        color peach !important
        """}</style>
    </div>

export default DislikeListViewMobile
