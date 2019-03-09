import BrandIcon from '~/components/brandIcon'

SocialButtons = ({ className, style }) ->
    <div
        className="d-flex flex-row #{ className ? '' }"
        style={ style }>
        <a
            target='_blank'
            rel='noopener noreferrer'
            href='https://www.facebook.com/noiseblend'>
            <BrandIcon brand='facebook-f' />
        </a>
        <a
            target='_blank'
            rel='noopener noreferrer'
            href='https://www.twitter.com/noiseblend'>
            <BrandIcon brand='twitter' />
        </a>
        <a
            target='_blank'
            rel='noopener noreferrer'
            href='https://www.reddit.com/r/noiseblend'>
            <BrandIcon brand='reddit-alien' />
        </a>
    </div>

export default SocialButtons
