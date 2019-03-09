import buildURL from 'axios/lib/helpers/buildURL'
import _ from 'lodash'
import LRUCache from 'lru-cache'

import { AxiosAdapter, AxiosPromise } from 'axios'

import config from '~/config'

FIVE_MINUTES = 1000 * 60 * 5

debug = if config.DEBUG
    console.log
else
    () -> null

buildSortedURL = ({ url, params, paramsSerializer }) ->
    builtURL = buildURL(url, params, paramsSerializer)
    [urlPath, queryString] = builtURL.split('?')
    if queryString
        paramsPair = queryString.split('&')
        return "#{ urlPath }?#{ paramsPair.sort().join('&') }"

    return builtURL

getCacheKey = ({ url, auth = 'PUBLIC', type = 'RESPONSE', etag = '' }) ->
    return "#{ url }[AUTH=#{ auth } ETAG=#{ etag ? '' }]:#{ type }"

isCacheLike = (cache) -> (
    cache.set and
    cache.get and
    cache.del and
    typeof cache.get is 'function' and
    typeof cache.set is 'function' and
    typeof cache.del is 'function'
)

shouldCache = (response) ->
    (
        response?.headers?['cache-control']? and
        response.status >= 200 and
        response.status < 300
    )

getCacheControl = (response) ->
    cacheControl = response?.headers?['cache-control']
    unless cacheControl?
        return null

    pairs = (p.trim() for p in cacheControl.split(','))
    cacheControl = {}
    for p in pairs
        [key, val] = p.split('=')
        val = if val?
            intVal = parseInt(val)
            if isNaN(intVal) then val else intVal
        else
            true
        cacheControl[_.camelCase(key)] = val

    if cacheControl.maxAge
        cacheControl.maxAge = cacheControl.maxAge * 1000

    etag = response.headers['etag']
    if etag?
        cacheControl.eTag = etag

    return cacheControl

cacheResponse = (response, cache) ->
    cacheControl = getCacheControl(response)
    if cacheControl.maxAge is 0
        return

    url = buildSortedURL(response.config)
    etagKey = getCacheKey(
        url: url
        type: 'ETAG'
    )
    { privateKey, publicKey } = getResponseKeys(
        url, response.config.headers.Authorization, cacheControl.eTag
    )
    key = if cacheControl.private then privateKey else publicKey

    if cacheControl.eTag?
        cache.set(etagKey, cacheControl.eTag)

    if response?.config?.cache?
        delete response.config.cache

    if not cacheControl.maxAge? and not cacheControl.eTag?
        debug("Response will not be cached: key=#{ key }")
    else
        debug("Caching response: key=#{ key }")
        cache.set(key, Promise.resolve(response), cacheControl.maxAge)

fetchResponseByEtag = (adapter, config, cache, key, responsePromise) ->
    url = buildSortedURL(config)
    { etag, etagKey } = getEtagWithKey(url, cache)
    response = try
        await adapter({
            config...
            headers: {
                config.headers...
                'If-None-Match': etag
            }
        })
    catch reason
        if reason.response.status is 304
            debug("Response cached with etag: key=#{ key } etag=#{ etag }")
            await responsePromise
        else
            cache.del(etagKey)
            cache.del(key)
            throw reason

    cache.del(etagKey)
    cache.del(key)

    if shouldCache(response)
        cacheResponse(response, cache)

    return response

fetchResponse = (adapter, config, cache, key) ->
    try
        response = await adapter(config)
        if shouldCache(response)
            cacheResponse(response, cache)

        return response
    catch reason
        cache.del(key)
        throw reason

getEtagWithKey = (url, cache) ->
    etagKey = getCacheKey(
        url: url
        type: 'ETAG'
    )
    etag = cache.get(etagKey)
    return { etag, etagKey }

getResponseKeys = (url, auth, etag) -> {
    privateKey: getCacheKey({ url, auth, etag })
    publicKey: getCacheKey({ url, etag })
}

export default cacheAdapterEnhancer = (adapter, options = {}) ->
    {
        enabledByDefault = true
        defaultCache = new LRUCache({ max: 10000 })
    } = options

    return (config) ->
        useCache = config.cache ? enabledByDefault
        auth = config.headers.Authorization

        if config.method is 'get' and useCache
            cache = if isCacheLike(useCache) then useCache else defaultCache
            unless cache?
                debug("No cache provided")
                return adapter(config)

            url = buildSortedURL(config)
            { etag, etagKey } = getEtagWithKey(url, cache)
            { privateKey, publicKey } = getResponseKeys(url, auth, etag)
            [responsePromise, key] = if (resp = cache.get(privateKey))?
                [resp, privateKey]
            else
                [cache.get(publicKey), publicKey]

            if responsePromise? and etag? and not config.forceUpdate
                debug("Found cached response and etag: key=#{ key } etag=#{ etag }")
                return fetchResponseByEtag(adapter, config, cache, key, responsePromise)

            if not responsePromise or config.forceUpdate
                debug("Response is not cached: key=#{ key }")
                return fetchResponse(adapter, config, cache, key)

            debug("Response is cached: #{ key }")
            return responsePromise

        return adapter(config)
