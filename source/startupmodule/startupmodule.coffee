
startupmodule = {name: "startupmodule"}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["startupmodule"]?  then console.log "[startupmodule]: " + arg
    return

#region internal variables
citysearch = null
sci = null
#endregion


##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
startupmodule.initialize = () ->
    log "startupmodule.initialize"
    citysearch = allModules.citysearchmodule
    sci = allModules.scimodule

#region exposed functions
startupmodule.serviceStartup = ->
    log "startupmodule.serviceStartup"
    citysearch.setUpDataStructure()
    sci.prepareAndExpose()

#endregion exposed functions

export default startupmodule