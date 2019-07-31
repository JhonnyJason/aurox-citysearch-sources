
citysearchmodule = {name: "citysearchmodule"}

cityArray = require('./city.list.json')

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["citysearchmodule"]?  then console.log "[citysearchmodule]: " + arg
    return

#region internal variables
stringSearch = null
coordSearch = null
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
citysearchmodule.initialize = () ->
    log "citysearchmodule.initialize"
    stringSearch = allModules.stringsearchmodule
    coordSearch = allModules.coordsearchmodule
    
#region internal functions
#endregion

#region exposed functions
citysearchmodule.doStringSearch = (searchString, maxResults) ->
    log "citysearchmodule.doStringSearch " + searchString + ", " + maxResults
    return stringSearch.doSearch(searchString, maxResults)

citysearchmodule.doCoordSearch = (lon, lat) ->
    log "citysearchmodule.doCoordSearch " + lon + ", " + lat
    return coordSearch.doSearch(lon, lat)

citysearchmodule.setUpDataStructures = ->
    log "citysearchmodule.setUpDataStructure"
    count = 10
    for cityEntry in cityArray
        stringSearch.addEntry cityEntry
        coordSearch.addEntry cityEntry
    cityArray.length = 0 #free up the memory for the now unused list
    log 'dataStructures initialized!'
    return
#endregion exposed functions

export default citysearchmodule