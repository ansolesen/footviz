source("prozoneAPI.R")
require("dplyr")

teams <- getDataFrame("http://api.stats.com/v1/stats/soccer/den/teams/?accept=json")

teamRankings <- getDataFrame("http://api.stats.com/v1/stats/soccer/den/standings/?expanded=true&accept=json")
teamRankings <- teamRankings$apiResults.league$season$eventType[[1]]$conferences[[1]]$divisions[[1]]$teams
teamRankings <- data.frame(teamRankings)
teamRankings <- flatten(teamRankings, recursive = TRUE)

teamsInfo <- teams$apiResults.league$season$conferences[[1]]$divisions[[1]]$teams[[1]]

collected <- data.frame()


for(currentID in teams$apiResults.league$season$conferences[[1]]$divisions[[1]]$teams[[1]]$teamId)
{
  
  Sys.sleep(0.4)
  
  print(paste0("Fetching ", currentID))
  
  request = paste0("http://api.stats.com/v1/stats/soccer/den/stats/teams/", currentID, "?accept=json")
  
  stats <- getDataFrame(request)
  
  stats <- stats$apiResults.league$teams[[1]]$seasons[[1]]$eventType[[1]]$splits[[1]]$teamStats[[1]]
  
  stats <- flatten(stats, recursive = T)
  
  stats <- select(stats, -teamOwnFlag)
  
  stats <- Filter(is.integer, stats)
  
  stats <- colSums(stats)
  
  stats <- data.frame(lapply(stats, function(x) t(data.frame(x))))
  
  rownames(stats) <- NULL
  
  # get team name
  
  teamInfo <- subset(teamsInfo, teamId == currentID)
  
  teamName <- teamInfo$displayName
  
  stats <- mutate(stats, name = teamName)
  
  # get team rank (team rank is inverted such that rank 1 becomes rank 12).
  # is done because the D3 visualization considers a big value good
  teamLeagueInfo <- subset(teamRankings, teamId == currentID)
  
  teamRank <- teamLeagueInfo$league.rank
  
  teamRank <- 13 - teamRank
  
  stats <- mutate(stats, rank = teamRank)
  
  
  collected <- rbind(collected, stats)
}

out <- toJSON(collected, pretty = TRUE)

write(out, "teamData.json")