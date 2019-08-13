
scimodule = {name: "scimodule"}

#region node_modules
express = require('express')
bodyParser = require('body-parser')
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["scimodule"]?  then console.log "[scimodule]: " + arg
    return

#region internal variables
cfg = null
search = null

app = null
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
scimodule.initialize = () ->
    log "scimodule.initialize"
    cfg = allModules.configmodule
    search = allModules.citysearchmodule
    app = express()
    app.use bodyParser.urlencoded(extended: false)
    app.use bodyParser.json()

#region internal functions
# for acces control allowing acces to the necessary services - - - - - 
setAllowedOrigins = ->
    log "setAllowedOrigins"
    app.use (req, res, next) ->
        allowedOrigins = cfg.allowedOrigins
        origin = req.headers.origin
        log 'header origin was: ' + origin
        if allowedOrigins.indexOf(origin) > -1
            res.setHeader 'Access-Control-Allow-Origin', origin
        res.header 'Access-Control-Allow-Methods', 'POST, OPTIONS'
        res.header 'Access-Control-Allow-Headers', 'Content-Type'
        next()

attachSCIFunctions = ->
    log "attachSCIFunctions"
    app.post '/citysearch', onCitySearch 
    app.post '/stringsearch', onStringSearch 
    app.post '/coordsearch', onCoordSearch 


## SCI handler functions
onCitySearch = (req, res) ->
    log 'onCitysearch'
    try
        log JSON.stringify(req.body)
        maxResults = cfg.defaultMaxResults
        if req.body.maxResults
            maxResults = req.body.maxResults

        searchString = '' 
        if req.body.searchString
            searchString = req.body.searchString.toLowerCase()
            results = search.doStringSearch(searchString, maxResults)
        else 
            lon = req.body.lon
            lat = req.body.lat
            results = search.doCoordSearch(lon, lat)

        #kick off search, which terminates synchronously
    catch error then results = ["error:" + error]
    finally res.send results
    return

onCoordSearch = (req, res) ->
    log 'onCitysearch'
    try
        log JSON.stringify(req.body, null, 2)
        lon = req.body.lon
        lat = req.body.lat

        results = search.doCoordSearch(lon, lat)
    catch error then results = ["error:" + error]
    finally res.send results
    return

onStringSearch = (req, res) ->
    log 'onCitysearch'
    try
        log JSON.stringify(req.body)
        maxResults = cfg.defaultMaxResults
        if req.body.maxResults
            maxResults = req.body.maxResults

        searchString = req.body.searchString.toLowerCase()
        results = search.doStringSearch(searchString, maxResults)
    catch error then results = ["error:" + error]
    finally res.send results
    return

#endregion


#region exposed functions
scimodule.prepareAndExpose = ->
    log "scimodule.prepareAndExpose"
    setAllowedOrigins()
    attachSCIFunctions()
    port = process.env.PORT || cfg.defaultPort
    app.listen port
    log "listening on port: " + port

#endregion exposed functions

export default scimodule
