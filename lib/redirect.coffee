import Router from "next/router"

redirect = ({ target, res, isServer, statusCode = 303 }) ->
    if res? and isServer
        res.writeHead(statusCode, Location: target)
        res.end()
        res.finished = true
    else
        Router.push(target)

export default redirect
