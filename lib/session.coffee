import cookie from "js-cookie"
import uuid4 from "uuid/v4"

import config from "~/config"

TWO_MINUTES = 2 / (24 * 60)
ALEXA_PARAMS = ["state", "client_id", "response_type", "scope", "redirect_uri"]

export getAlexaParams = (ctx) ->
    params = {}
    for param in ALEXA_PARAMS
        params[param] = getCookie(param, ctx)

    return params

export removeAlexaParams = (ctx) ->
    for param in ALEXA_PARAMS
        removeCookie(param, ctx)

export setAlexaParams = (params, ctx = {}) ->
    for param, value of params
        setCookie(param, value, ctx, TWO_MINUTES)

export getAuthTokenCookie = (ctx) ->
    getCookie(config.AUTH_TOKEN_COOKIE_KEY, ctx)

export setAuthTokenCookie = (authToken, ctx = {}) ->
    if authToken?
        setCookie(
            config.AUTH_TOKEN_COOKIE_KEY
            authToken
            ctx
            config.AUTH_TOKEN_EXPIRATION_DAYS
        )

export removeAuthTokenCookie = (ctx = {}) ->
    setAuthTokenCookie(uuid4(), ctx)

export setCookie = (key, value, ctx = {}, expires = 7) ->
    if ctx.isServer
        setCookieToServer(key, value, ctx.res, expires)
    else
        setCookieToBrowser(key, value, expires)

export removeCookie = (key, ctx = {}, expires = 7) ->
    if ctx.isServer
        setCookieToServer(key, "", ctx.res, -1000)
    else
        cookie.remove(key, path: "/")

export getCookie = (key, ctx = {}) ->
    if ctx.isServer
        getCookieFromServer(key, ctx)
    else
        getCookieFromBrowser(key)

setCookieToServer = (key, value, res, expires) ->
    expireDate = new Date()
    expireDate.setMilliseconds(expireDate.getMilliseconds() + expires * 864e5)
    oldCookies = res.getHeader("set-cookie")
    newCookie = "#{ key }=#{ value }; Expires=#{ expireDate.toUTCString() }; Path=/"
    newCookies =
        if not oldCookies?
            newCookie
        else if typeof oldCookies is "string"
            [oldCookies, newCookie]
        else
            [oldCookies..., newCookie]

    res.setHeader("Set-Cookie", newCookies)

setCookieToBrowser = (key, value, expires) ->
    cookie.set(key, value, expires: expires, path: "/")

getCookieFromBrowser = (key) ->
    cookie.get(key)

findCookie = (header, key) ->
    header
        ?.split(";")
        ?.find((c) -> c.trim().startsWith("#{ key }="))

getCookieFromServer = (key, { req, res }) ->
    rawCookie = findCookie(req?.headers?.cookie, key)

    rawCookie?.split("=")[1]
