import { all, call, put, select, take } from 'redux-saga/effects'

import CacheActions from '~/redux/cache'

import config from '~/config'

export cache = ({ key, value }) ->
    if caches?
        cache = yield caches.open(config.CACHE.name)
        yield cache.put(key, new Response(value))

    yield return
