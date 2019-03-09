import { connect } from 'react-redux'

import BrandIcon from '~/components/brandIcon'
import ImageBackground from '~/components/imageBackground'
import TextButton from '~/components/textButton'

import colors from '~/styles/colors'

import config from '~/config'
import CoffeeScript from '~/icons/coffeescript.svg'
import Python from '~/icons/python.svg'
import Sanic from '~/icons/sanic.svg'
import Zeit from '~/icons/zeit.svg'

TechIcon = ({ name, size, color, props... }) ->
    iconProps = {
        style: {
            marginLeft: 5
            marginRight: 2
            height: size - 2
            color: color
        }
        props...
    }

    return switch name
        when 'Python'
            <Python { iconProps... } />
        when 'CoffeeScript'
            <CoffeeScript { iconProps... } />
        when 'Sanic'
            <Sanic { iconProps... } />
        when 'Next.js'
            <Zeit { iconProps... } />

Technology = ({ name, url, iconColor, iconProps = { }, size = 16}) ->
    <a
        style={
            fontSize: size
            color: colors.FLASH_WHITE
        }
        target='_blank'
        rel='noopener noreferrer'
        href={ url }>
        <TechIcon name={ name } size={ size } color={ iconColor } { iconProps... } />
        { name }
    </a>

Stack = ({ className, style, id, props... }) ->
    <div
        style={{
            style...
        }}
        id={ id }
        className="flex-column-center stack #{ className ? '' }">
        <div>
            Written in
            <Technology
                name='Python'
                url='https://www.python.org'
            /> and
            <Technology
                name='CoffeeScript'
                url='https://coffeescript.org'
                iconColor={ colors.YELLOW }
            />
        </div>
        <div>
            Powered by
            <Technology
                name='Sanic'
                url='https://github.com/channelcat/sanic'
            /> and
            <Technology
                name='Next.js'
                url='https://github.com/zeit/next.js'
                iconColor={ colors.WHITE }
            />
        </div>
    </div>

STACK_WIDTH = 320
About = (props) ->
    <div
        style={ position: 'relative' }
        className='flex-center fill-window'>
        <Stack style={
            color: colors.WHITE.darken(0.1)
            width: STACK_WIDTH
            position: 'absolute'
            bottom: 20
            left: "calc(50vw - #{ STACK_WIDTH / 2 }px)"
            zIndex: 1

        } />
        <div className='flex-center flex-column flex-lg-row fill-window'>
            <ImageBackground
                fadeIn
                background={ src: "#{ config.STATIC }/img/alin.jpg" }
                imageStyle={ minHeight: '100vh', minWidth: '50vw' }
                overlayStyle={ minHeight: '100vh', minWidth: '50vw' }
                overlayColor={ colors.MARS_RED.alpha(0.8) }
                blur={ 30 }>
                <div className='flex-column-center about-alin'>
                    <img
                        className='alin-image'
                        src="#{ config.STATIC }/img/alin.jpg" />
                    <h3 className='my-4 text-center'>Alin Panaitiu</h3>
                    <div className="flex-center">
                        <a
                            target='_blank'
                            rel='noopener noreferrer'
                            href='https://www.linkedin.com/in/alin-panaitiu-a3678652/'>
                            <BrandIcon brand='linkedin-in' />
                        </a>
                        <a
                            target='_blank'
                            rel='noopener noreferrer'
                            href='https://www.github.com/alin23'>
                            <BrandIcon brand='github-alt' />
                        </a>
                    </div>
                </div>
            </ImageBackground>
            <ImageBackground
                fadeIn
                imageStyle={
                    minHeight: if props.mobile then '120vh' else '100vh'
                    minWidth: '50vw'
                }
                overlayStyle={
                    minHeight: if props.mobile then '120vh' else '100vh'
                    minWidth: '50vw'
                }
                overlayColor={ colors.ORANGE.darken(0.8).desaturate(0.2).alpha(0.8) }
                background={ src: "#{ config.STATIC }/img/matei.jpg" }
                blur={ 30 }>
                <div className='flex-column-center about-matei'>
                    <img
                        className='matei-image'
                        src="#{ config.STATIC }/img/matei.jpg" />
                    <h3 className='my-4 text-center'>Matei Sandu</h3>
                    <div className='flex-center'>
                        <a
                            target='_blank'
                            rel='noopener noreferrer'
                            href='
                                https://www.linkedin.com/in/\
                                matei-%C8%99erban-sandu-04a481107/'>
                            <BrandIcon brand='linkedin-in' />
                        </a>
                        <a
                            target='_blank'
                            rel='noopener noreferrer'
                            href='https://www.github.com/sanduserban'>
                            <BrandIcon brand='github-alt' />
                        </a>
                    </div>
                </div>
            </ImageBackground>
        </div>
        <style jsx>{"""#{} // stylus
            .alin-image
            .matei-image
                object-fit cover
                border-radius 10px
                width: 300px
                height: 300px
        """}</style>
    </div>

export default connect(({ ui }) -> { mobile: ui.mobile })(About)
