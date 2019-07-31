
stringsearchmodule = {name: "stringsearchmodule"}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["stringsearchmodule"]?  then console.log "[stringsearchmodule]: " + arg
    return

#region internal variables
dataStruct = 
    rootNode:
        cityCount: 0
        cityID: 0
        cityName: ''
    currentEntryToInsert: null
    currentCityName: ''
    currentSensitiveCityName: ''
    currentCityID: 0
    currentCharIndex: 0
    currentNode: null
    initialized: false

resultStruct = 
    maxResults: 30
    results: []
#endregion


##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
stringsearchmodule.initialize = () ->
    log "stringsearchmodule.initialize"
    
#region internal functions
#==========================================================================================
# insert Data functions
#==========================================================================================
# inserts the current entry which at this point should have been set into the datastructure
insertCityEntry = ->
    #start off @ 0
    dataStruct.currentCharIndex = 0
    currentChar = dataStruct.currentCityName.charAt(dataStruct.currentCharIndex)
    #insert for root entry - cityCount represents the number of cities wich may be reached at this or any child nodes 
    dataStruct.rootNode.cityCount++
    #insert stuff for the next Node
    if !dataStruct.rootNode[currentChar]
        #create leave(potential node) if there is no appropriate one yet
        dataStruct.rootNode[currentChar] = cityCount: 1
    else
        dataStruct.rootNode[currentChar].cityCount++
    #otherwise the city is at or at any child of this leave/node
    #we set a new base node for where we continue to insert the parts of the rest of the names
    dataStruct.currentNode = dataStruct.rootNode[currentChar]
    #insert further nodes
    while dataStruct.currentNode
        insertNextNode()
    #clean datastruct
    dataStruct.currentCharIndex = 0
    dataStruct.currentNode = null
    dataStruct.currentEntryToInsert = null
    return

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# is called for every character of the object to insert the node for it's seach path
insertNextNode = ->
    dataStruct.currentCharIndex++
    currentChar = dataStruct.currentCityName.charAt(dataStruct.currentCharIndex)

  ###
    console.log("____________________________________________");
    console.log("City Name: " + dataStruct.currentCityName);
    console.log("City ID: " + dataStruct.currentCityID);
    console.log("current Char index: " + dataStruct.currentCharIndex);
    console.log("current Char: " + currentChar);
    console.log("- - - - - - - - - - - - - - - - - - - - - - \n");
  ###

    if !currentChar
        # we reached the end
        dataStruct.currentNode.cityID = dataStruct.currentCityID
        dataStruct.currentNode.cityName = dataStruct.currentSensitiveCityName
        dataStruct.currentNode = null
        #is the break condition to recognize we're through
        return
    #create new leave(potential node) if there is no appropriate one yet
    if !dataStruct.currentNode[currentChar]
        dataStruct.currentNode[currentChar] = cityCount: 1
    else
        dataStruct.currentNode[currentChar].cityCount++
    #progress to next node
    dataStruct.currentNode = dataStruct.currentNode[currentChar]
    return

#==========================================================================================
# search functions
#===========================================================================================
# this will start the loop to go through all relevant nodes
# when this function is called the seachString has been stored @ datastruct.currentCityName
# also the maximum number of search results is stored @ resultStruct.maxResults
retrieveSearchResults = ->
    log 'retrieveSearchResults'
    #reset all relevant parameters
    dataStruct.currentNode = dataStruct.rootNode
    dataStruct.currentCharIndex = 0
    resultStruct.results = []
    #iterating over the searchString
    currentChar = dataStruct.currentCityName.charAt(dataStruct.currentCharIndex)
    while currentChar
        if dataStruct.currentNode[currentChar]
            dataStruct.currentNode = dataStruct.currentNode[currentChar]
        else
            #when we donot find any we have no results and may end the search
            log 'The search String does not fit any results!'
            return
        #prepare for next round
        dataStruct.currentCharIndex++
        currentChar = dataStruct.currentCityName.charAt(dataStruct.currentCharIndex)
    #now we have gone through the whole searchString we now should have a search Result
    if dataStruct.currentNode.cityCount > resultStruct.maxResults
        #We have too many search results, so we send back none
        log 'there are too many results!'
        return
    log "we have " + dataStruct.currentNode.cityCount + " results!"
    collectSearchResults()
    return

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# we have one through the whole searchString and the currentNode is @ the beginning of all 
# search results
collectSearchResults = ->
    log 'collectSearchResults'
    currentNode = dataStruct.currentNode
    #start recursive depth first search to retreive all search results
    for key of currentNode
        # skip loop if the property is from prototype
        if currentNode.hasOwnProperty(key)
            # console.log 'key: \'' + key + '\' / value: \'' + currentNode[key] + '\''
            #if there is a cityID this node represents a complete city
            if key == 'cityID' and currentNode[key]
                result = 
                    cityID: currentNode.cityID
                    cityName: currentNode.cityName
                resultStruct.results.push result
            #every key length 1 is pointing to a child node
            if key.length == 1
                dataStruct.currentNode = currentNode[key]
                collectSearchResults()
    return
#endregion

#region exposed functions
stringsearchmodule.doSearch = (searchString, maxResults) ->
    log "stringsearchmodule.doSearch " + searchString + ", " + maxResults
    dataStruct.currentCityName = searchString
    resultStruct.maxResults = maxResults
    retrieveSearchResults()
    return resultStruct.results

stringsearchmodule.addEntry = (entry) ->
    # log "stringsearchmodule.addEntry"
    dataStruct.currentEntryToInsert = entry
    dataStruct.currentCityID = entry.id
    dataStruct.currentCityName = entry.name.toLowerCase() + ', ' + entry.country.toLowerCase()
    dataStruct.currentSensitiveCityName = entry.name + ', ' + entry.country
    insertCityEntry()
    return
#endregion exposed functions

export default stringsearchmodule