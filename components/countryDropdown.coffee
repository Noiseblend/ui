import React from 'react'

import _ from 'lodash'

import colors from '~/styles/colors'


CountryDropdown = ({ disabled, onClick, countries, country, props... }) ->
    countries = _.sortBy(countries ? [], ['name'])
    <div className='my-2 country-dropdown'>
        <select
            style={
                cursor: if disabled then 'auto' else 'pointer'
                color: colors.WHITE.alpha(0.4) if disabled
            }
            disabled={ disabled }
            value={ country?.name }
            onChange={ (e) -> onClick e.target.value }
            className='dropdown'
            { props... }>
            { countries.map((country, i) ->
                <option key={ country.name } value={ country.name }>
                    { country.name }
                </option>
            )}
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

export default CountryDropdown
