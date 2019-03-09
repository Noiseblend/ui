import Color from 'color'
import Link from 'next/link'

import Card from '~/components/card'

import colors from '~/styles/colors'
import { fluid } from '~/styles/util'

import config from '~/config'
import Book from '~/icons/book.svg'
import Brain from '~/icons/brain.svg'
import Car from '~/icons/car.svg'
import DeskLamp from '~/icons/desk-lamp.svg'
import DinnerPlate from '~/icons/dinner-plate.svg'
import Dumbbell from '~/icons/dumbbell.svg'
import Hearts from '~/icons/hearts.svg'
import Moon from '~/icons/moon.svg'
import Shoe from '~/icons/shoe.svg'
import Sun from '~/icons/sun.svg'

getIcon = (icon) ->
    switch icon
        when 'dumbbell' then Dumbbell
        when 'dinner-plate' then DinnerPlate
        when 'brain' then Brain
        when 'desk-lamp' then DeskLamp
        when 'hearts' then Hearts
        when 'sun' then Sun
        when 'shoe' then Shoe
        when 'book' then Book
        when 'moon' then Moon
        when 'car' then Car

BlendGrid = ({ className, id, style, children, props... }) ->
    <div
        className="
            d-flex flex-column
            justify-content-center
            align-items-center
            #{ className ? '' }"
        id={ id }
        style={{
            paddingTop: '10vh'
            style...
        }}>
        <h1
            className='text-light text-center mb-5'
            style={
                fontSize: fluid(
                    40, 100,
                    config.WIDTH.prisonCellphone,
                    config.WIDTH.twokay)
            }>
            Your music, on the tap.
        </h1>
        <p className='text-center px-5 px-md-0' id='blends-description'>
            Every little square down below, is a gate to an endless stream
            of meticulously chosen songs for your specific occasion
        </p>
        <div className='m-5 blends-container'>
            {for blendType, blend of config.BLENDS
                <a key={ blendType } href="/blend?tutorial=true&blend=#{ blendType }">
                    <Card
                        useFill
                        size={ 230 }
                        backgroundColor={ colors.WHITE.mix(colors.YELLOW, 0.08) }
                        color={ Color(blend.color) }
                        icon={ getIcon(blend.icon) }
                        iconColor={ colors.BLACK }
                        hoverIconColor={ colors.WHITE }
                        iconProps={
                            height: 80
                            width: 80
                            size: 80
                        }
                        title={ blend.name }
                        className='my-3 mx-lg-3 text-center blend-card'>
                    </Card>
                </a>
            }
        </div>
        <style jsx>{"""#{} // stylus
            #blends-description
                font-size 1.2rem
                max-width 550px
                color darkMauve
                @media (max-width: $mobile)
                    font-size 1rem

            .blends-container
                display grid
                grid 1fr 1fr / 1fr 1fr 1fr 1fr
                grid-column-gap 1rem
                grid-row-gap 1rem

                @media (max-width: #{ config.WIDTH.large }px)
                    grid 1fr 1fr 1fr 1fr / 1fr 1fr

                @media (max-width: #{ config.WIDTH.mobile }px)
                    grid 1fr 1fr 1fr 1fr / 1fr

        """}</style>
    </div>


export default BlendGrid
