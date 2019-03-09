import DislikeList from '~/components/dislikeList'

import colors from '~/styles/colors'

import config from '~/config'


LIST_WIDTH = 430

DislikeListViewDesktop = (props) ->
    <div className='
        d-flex
        flex-column
        justify-content-center
        align-items-center
        bottom-container'>
        <div className='d-flex flex-row dislike-container'>
            <DislikeList
                mobile={ false }
                items={ props.dislikes.artists }
                removeDislike={
                    (item) ->
                        props.removeDislike('artists', item) }
                itemsName='Artists'
                fetching={ props.fetching } />
            <DislikeList
                mobile={ false }
                items={ props.dislikes.genres }
                removeDislike={
                    (item) ->
                        props.removeDislike('genres', item) }
                itemsName='Genres'
                fetching={ props.fetching } />
            <DislikeList
                mobile={ false }
                items={ props.dislikes.cities }
                removeDislike={
                    (item) ->
                        props.removeDislike('cities', item) }
                itemsName='Cities'
                fetching={ props.fetching } />
            <DislikeList
                mobile={ false }
                items={ props.dislikes.countries }
                removeDislike={
                    (item) ->
                        props.removeDislike('countries', item) }
                itemsName='Countries'
                fetching={ props.fetching } />
        </div>
        <style global jsx>{"""#{} // stylus
            .dislike-list
                height 86%

            .dislike-list-container
                min-width #{ LIST_WIDTH }px
                max-width #{ LIST_WIDTH }px
                width #{ LIST_WIDTH }px
                height 100%
                background-color #{ config.USER_BACKGROUND.darken(0.1) }
                border-radius 20px
                margin-left 30px
                margin-right 30px

            .dislike-container
                height 100%
                max-width 100vw
                margin-left auto
                margin-right auto
                overflow scroll
                -webkit-overflow-scrolling touch
                height 90%

            .bottom-container
                height 70%

        """}</style>
    </div>

export default DislikeListViewDesktop
