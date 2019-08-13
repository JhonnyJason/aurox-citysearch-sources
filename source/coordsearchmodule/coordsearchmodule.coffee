
coordsearchmodule = {name: "coordsearchmodule"}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["coordsearchmodule"]?  then console.log "[coordsearchmodule]: " + arg
    return

#region internal variables
rootNode = lonNodes:  {} 
currentEntryToInsert = null
currentDigitIndex = 0
currentLonAsDigits = ""
currentLatAsDigits = ""

lonDigit = ""
latDigit = ""
currentNode = null

matchedLonDigits = ""
matchedLatDigits = ""
#endregion


##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
coordsearchmodule.initialize = () ->
    log "coordsearchmodule.initialize"
    

#region internal functions
tranformToDigits = (floatNum, logging) ->
    log "tranformToDigits" if logging
    log "initial number is: " + floatNum  if logging
    positive = floatNum + 1200.0
    log "after adding 1200.0 we have: " + positive  if logging
    big = 10000000 * positive
    log "after multiplying by 10000000 we have: " + big  if logging
    integer = Math.round(big)
    log "after rounding we have: " + integer  if logging
    digits = integer.toString()
    log "after toString we have: " + digits  if logging
    return digits

transformToCoord = (digits) ->
    number = parseInt(digits) || 0
    number = 1.0 * number / 10000000
    number -= 1200
    return number

printCurrentInsertState = ->
    log " - - - - - \n" + JSON.stringify currentEntryToInsert
    log " - - - - - tree:\n" + JSON.stringify(rootNode, null, 2)
    log " - - - to insert:"
    log "index: " + currentDigitIndex
    log "lonDigit: " + currentLonAsDigits.charAt(currentDigitIndex)
    log "latDigit: " + currentLatAsDigits.charAt(currentDigitIndex)
    log " - - - - - - - \n"

printSearchState = ->
    # log " - - - - - \n" + JSON.stringify currentEntryToInsert
    # log " - - - - - tree:\n" + JSON.stringify(rootNode, null, 2)
    log " - - - To search for: "
    log " lon Digits: " + currentLonAsDigits
    log " lon: " + transformToCoord(currentLonAsDigits)
    log " lat Digits: " + currentLatAsDigits
    log " lat: " + transformToCoord(currentLatAsDigits)
    log " - - - searching:"
    log "matchedLonDigits: " + matchedLonDigits
    log "matchedLatDigits: " + matchedLatDigits
    log "current index: " + currentDigitIndex
    log "current lonDigit: " + currentLonAsDigits.charAt(currentDigitIndex)
    log "current latDigit: " + currentLatAsDigits.charAt(currentDigitIndex)
    log " - - - - - - - \n"

#==========================================================================================
# insert Data functions
#==========================================================================================
# inserts the current entry which at this point should have been set into the datastructure
insertCityEntry = ->
    # log "insertCityEntry"
    #start off @ 0
    currentDigitIndex = 0
    lonDigit = currentLonAsDigits.charAt(currentDigitIndex)
    latDigit = currentLatAsDigits.charAt(currentDigitIndex)
    
    # printCurrentInsertState()

    if !rootNode.lonNodes[lonDigit]
        rootNode.lonNodes[lonDigit] = latNodes: {}
    if !rootNode.lonNodes[lonDigit].latNodes[latDigit]
        rootNode.lonNodes[lonDigit].latNodes[latDigit] = lonNodes: {}

    currentNode = rootNode.lonNodes[lonDigit].latNodes[latDigit]
    while currentNode
        insertNextNode()

    #reset state
    currentDigitIndex = 0
    currentNode = null
    return

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# is called for every character of the object to insert the node for it's seach path
insertNextNode = ->
    # log "insertNextNode"
    currentDigitIndex++
    lonDigit = currentLonAsDigits.charAt(currentDigitIndex)
    latDigit = currentLatAsDigits.charAt(currentDigitIndex)
    
    # printCurrentInsertState()

    if lonDigit == "" or latDigit == ""
        currentNode.leaf = currentEntryToInsert
        currentNode = null
        return

    if !currentNode.lonNodes[lonDigit]
        currentNode.lonNodes[lonDigit] = latNodes: {}
    if !currentNode.lonNodes[lonDigit].latNodes[latDigit]
        currentNode.lonNodes[lonDigit].latNodes[latDigit] = lonNodes: {}

    currentNode = currentNode.lonNodes[lonDigit].latNodes[latDigit]



#==========================================================================================
# search functions
#===========================================================================================
bestFitSearch = ->
    log "bestFitSearch"
    currentDigitIndex = 0
    lonDigit = currentLonAsDigits.charAt(currentDigitIndex)
    latDigit = currentLatAsDigits.charAt(currentDigitIndex)

    if !rootNode.lonNodes[lonDigit]
        currentNode = rootNode
        findBestFit()
        return leafToResult(currentNode.leaf) if currentNode.leaf?
    else if !rootNode.lonNodes[lonDigit].latNodes[latDigit]
        currentNode = rootNode
        findBestFit()
        return leafToResult(currentNode.leaf) if currentNode.leaf?

    matchedLonDigits += lonDigit
    matchedLatDigits += latDigit
    currentNode = rootNode.lonNodes[lonDigit].latNodes[latDigit]

    secureCount = 0

    while !currentNode.leaf and secureCount++ < 30
        checkNextLevel()

    if secureCount > 30 then throw "Error: Datastructure is broken - infinite loop detected!"

    return leafToResult(currentNode.leaf)

leafToResult = (leaf) ->
    log "leafToResult"
    result = 
        cityID: leaf.id
        cityName: leaf.name + ', ' + leaf.country
    log JSON.stringify(result)
    return result

findBestFit = () ->
    log "findBestFit"

    possiblePairs = generatePossiblePairsFromCurrentNode()
    # log "collected possiblePairs:\n" + JSON.stringify(possiblePairs, null, 2)
    
    targetPair = 
        lon: parseInt(lonDigit) || 0
        lat: parseInt(latDigit) || 0
    # log "target Pair: \n" + JSON.stringify(targetPair, null, 2)
    
    pairToGo = identifyClosestPair(targetPair, possiblePairs)
    # log "closest Pair: \n" + JSON.stringify(pairToGo, null, 2)
    lonDigit = pairToGo.lon
    latDigit = pairToGo.lat

identifyClosestPair = (target, options) -> 
    # log "identifyClosestPair"
    closestOption = null
    closestDistance = 1000
    for option in options
        d1 = target.lon - option.lon
        d2 = target.lat - option.lat
        distance = ((d1*d1) + (d2*d2))
        if distance < closestDistance
            closestDistance = distance
            closestOption = option
    return closestOption

generatePossiblePairsFromCurrentNode = ->
    # log "generatePossiblePairsFromCurrentNode"
    lonOptions = Object.keys(currentNode.lonNodes)
    pairOptions = []
    for lonOption in lonOptions
        pairOptions = pairOptions.concat(generatePossiblePairsFromLon(lonOption))
    return pairOptions

generatePossiblePairsFromLon = (lon) ->
    # log "generatePossiblePairsFromLonNode"
    lonNode = currentNode.lonNodes[lon]
    latOptions = Object.keys(lonNode.latNodes)
    pairOptions = []
    for latOption in latOptions
        pair = 
            lon: parseInt(lon)
            lat: parseInt(latOption)
        pairOptions.push(pair)
    return pairOptions

checkNextLevel = ->
    log 'checkNextLevel'

    currentDigitIndex++
    lonDigit = currentLonAsDigits.charAt(currentDigitIndex)
    latDigit = currentLatAsDigits.charAt(currentDigitIndex)

    printSearchState()

    if !currentNode.lonNodes[lonDigit] or !currentNode.lonNodes[lonDigit].latNodes[latDigit]
        findBestFit()

    matchedLonDigits += lonDigit
    matchedLatDigits += latDigit
    currentNode = currentNode.lonNodes[lonDigit].latNodes[latDigit]


#endregion

#region exposed functions
coordsearchmodule.doSearch = (lon, lat) ->
    log "coordsearchmodule.doSearch " + lon + ", " + lat
    currentLonAsDigits = tranformToDigits(lon, true)
    currentLatAsDigits = tranformToDigits(lat, true)
    bestFit = bestFitSearch()
    currentLonAsDigits = ""
    currentLatAsDigits = ""
    matchedLatDigits = ""
    matchedLonDigits = ""
    return bestFit

coordsearchmodule.addEntry = (entry) ->
    # log "coordsearchmodule.addEntry"
    currentEntryToInsert = entry
    # throw "death On Purpose!"
    currentLonAsDigits = tranformToDigits(entry.coord.lon, fasle)
    currentLatAsDigits = tranformToDigits(entry.coord.lat, false)
    insertCityEntry()
    currentLonAsDigits = ""
    currentLatAsDigits = ""
    currentEntryToInsert = null
    return
#endregion exposed functions

export default coordsearchmodule