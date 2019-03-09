import { createActions, createReducer } from 'reduxsauce'

import Immutable from 'seamless-immutable'

{ Types, Creators } = createActions(
    cache: ['key', 'value']
, { prefix: 'cache/' })

export CacheTypes = Types
export default Creators

export INITIAL_STATE = Immutable(
    cache: null
)

cache = (state, { key, value }) -> {
    state...
    cache: { state.cache..., "#{ key }": value}
}

ACTION_HANDLERS =
    "#{ Types.CACHE }": cache


export reducer = createReducer(INITIAL_STATE, ACTION_HANDLERS)
