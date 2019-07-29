configmodule = {name: "configmodule"}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["configmodule"]?  then console.log "[configmodule]: " + arg
    return

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
configmodule.initialize = () ->
    log "configmodule.initialize"
    
#region the configuration Object
configmodule.defaultPort = 3003
configmodule.defaultMaxResults = 30
configmodule.allowedOrigins = [
    'http://localhost:3002'
    'http://localhost:3003'
  ]
#endregion

export default configmodule