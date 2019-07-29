
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

onCitysearch = (req, res) ->
    log 'onCitysearch'
    log req.body

    maxResults = cfg.defaultMaxResults
    if req.body.maxResults
        maxResults = req.body.maxResults

    searchString = '' 
    if req.body.searchString
        searchString = req.body.searchString.toLowerCase()

    #kick off search, which terminates synchronously
    results = search.doSearch(searchString, maxResults)
    res.send results
    return

attachSCIFunctions = ->
    log "attachSCIFunctions"
    app.post '/citysearch', onCitysearch 
#endregion


#region exposed functions
scimodule.prepareAndExpose = ->
    log "scimodule.exposeInteface"
    setAllowedOrigins()
    attachSCIFunctions()
    port = process.env.port || cfg.defaultPort
    app.listen port
    log "listening in port: " + port

#endregion exposed functions

export default scimodule
