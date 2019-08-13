configmodule = {name: "configmodule"}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["configmodule"]?  then console.log "[configmodule]: " + arg
    return

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
configmodule.initialize = () ->
    log "configmodule.initialize"
    
#region the configuration Object
configmodule.defaultPort = 3008
configmodule.defaultMaxResults = 30
configmodule.allowedOrigins = [
    'http://localhost:3008',
    'http://citysearch.aurox.at',
    'https://citysearch.aurox.at',
    'http://citysearch.auroxtech.com',
    'https://citysearch.auroxtech.com'
  ]
#endregion

export default configmodule