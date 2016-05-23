# to use this:
# place source("prozoneAPI.R") in top of your script
# example call:
# teams <- getDataFrame("http://api.stats.com/v1/stats/soccer/den/teams/?accept=json")

require(digest)
require(jsonlite)

getDataFrame <- function(request) {
  # generate the signature
  currentTime <- as.integer(Sys.time())
  
  sharedKey <- "m5VbeKVA2n"
  apiKey <- "qssewktagf2dqx5sjytz63cb"
  
  toHash <- paste0(apiKey, sharedKey, currentTime)
  
  sig <- digest(toHash, algo = "sha256", serialize = FALSE)
  
  # generate the request URL
  
  keys <- paste0("&api_key=", apiKey, "&sig=", sig)
  
  urlString <- paste0(request, keys)
  
  response <- fromJSON(urlString)
  
  return (data.frame(response))
}