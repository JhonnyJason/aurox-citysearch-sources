debugmodule = {name: "debugmodule"}

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
debugmodule.initialize = () ->
    console.log "debugmodule.initialize - nothing to do"

debugmodule.modulesToDebug = 
    unbreaker: true
    # citysearchmodule: true
    # configmodule: true
    coordsearchmodule: true
    # scimodule: true
    # startupmodule: true
    # stringsearchmodule: true

#region exposed variables

export default debugmodule