import React from 'react'

import TextButton from '~/components/textButton'

import colors from '~/styles/colors'

import config from '~/config'

TimeRangeDropdown = ({ disabled, timeRange, onClick, props... }) ->
    <div className='my-2 time-range-dropdown'>
        <select
            style={
                cursor: if disabled then 'auto' else 'pointer'
                color: colors.WHITE.alpha(0.4) if disabled
            }
            disabled={ disabled }
            value={ timeRange }
            onChange={ (e) -> onClick e.target.value }
            className='dropdown'
            { props... }>
            <option value='short_term'>
                { config.TIME_RANGE_MAPPING.short_term }
            </option>
            <option value='medium_term'>
                { config.TIME_RANGE_MAPPING.medium_term }
            </option>
            <option value='long_term'>
                { config.TIME_RANGE_MAPPING.long_term }
            </option>
        </select>
        <style jsx>{"""#{} // stylus
            .dropdown
                outline none
                background-color transparent
                color alpha(white, 0.8)
                border none
                ease-out color
                &:hover
                &:focus
                    color flashWhite

                option
                    color initial
        """}</style>
    </div>

export default TimeRangeDropdown
