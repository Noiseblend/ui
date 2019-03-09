import config from '~/config'

Hero = ({ title, subtitle, props... }) ->
    <div
        style={ props.style }
        className="
            d-flex
            flex-column
            justify-content-center
            align-items-center
            #{ props.className ? '' }">
        <h1 className='text-light text-center font-weight-bold heading'>
            { title }
        </h1>
        <p className='text-lowercase text-center text-light mx-5 subheading'>
            { subtitle }
        </p>
        { props.children }
        <style jsx>{"""#{} // stylus
            .subheading
                font-weight 600
                font-size 0.95rem

                @media (min-width: #{ config.WIDTH.medium }px)
                    font-size 1.1rem
                    margin 0

            .heading
                @media (min-width: #{ config.WIDTH.medium }px)
                    font-size 5rem

                @media (min-width: 1200px)
                    font-size 6rem
        """}</style>
    </div>


export default Hero
