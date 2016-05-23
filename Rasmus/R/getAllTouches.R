# Creates a file "allTouches.json" containing all shot info from the current season in json format
# does this by first getting a list of all team ids
# then getting a list of all unique event ids
# then gets the shot data from all the event ids and appends it to a single data.frame
# then turns the data.frame into a json object and saves to disk
# NOTE: the allTouches.json file will be ~ 130MB in size

source("prozoneAPI.R")
require("dplyr")

teams <- getDataFrame("http://api.stats.com/v1/stats/soccer/den/teams/?accept=json")

collected <- data.frame()

for(teamID in teams$apiResults.league$season$conferences[[1]]$divisions[[1]]$teams[[1]]$teamId)
{
  # sleep to restrict api calls per second
  Sys.sleep(0.4)
  
  request <- paste0("http://api.stats.com/v1/stats/soccer/den/stats/teams/", teamID, "/events/?accept=json")
  response <- getDataFrame(request)
  events <- response$apiResults.league$teams[[1]]$seasons[[1]]$eventType[[1]]$splits[[1]]$events[[1]]
  
  events <- flatten(events, recursive = TRUE)
  
  print(teamID)
  
  collected <- rbind(collected, events)
}

uniqueEventIDs <- distinct(collected, eventId)

selectedEventIDs <- uniqueEventIDs

print(nrow(selectedEventIDs))

touches <- data.frame()

for(eventID in selectedEventIDs$eventId)
{
  # sleep to restrict api calls per second
  Sys.sleep(0.4)
  
  print(eventID)
  
  request <- paste0("http://api.stats.com/v1/stats/soccer/den/comm/", eventID, "?touches=true&accept=json")
  
  response <- getDataFrame(request)
  
  response <- flatten(response, recursive = TRUE)
  
  currentTouches <- response$apiResults.league.season.eventType[[1]]$events[[1]]$touches
  
  currentTouches <- data.frame(currentTouches)
  
  currentTouches <- flatten(currentTouches, recursive = TRUE)
  
  touches <- rbind(touches, currentTouches, make.row.names = FALSE)
  
  print(nrow(touches))
}

out <- toJSON(touches, pretty = TRUE)

write(out, "allTouches.json")