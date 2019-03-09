import React from 'react'

import redirect from '~/lib/redirect'

import config from '~/config'


Logout = (props) -> <div />

Logout.getInitialProps = ({ store, query, res, req, isServer, authenticated, user, api }) ->
    ctx = { isServer, store, query }
    redirect({target: "/?logout=true", res, isServer})

    await return {
        authenticated: false
    }

 export default Logout
