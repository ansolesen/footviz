require(jsonlite)
require(dplyr)

touchesFile <- file("allTouches.json")
touches <- fromJSON(touchesFile)

splitted <- split(touches, f = touches$touchType.name)

for(df in splitted)
{
  print(df$touchType.name[1])
  
  for (i in 0:8)
  {
    out <- filter(df, time.minutes >= i*10 & time.minutes < (i+1)*10)
    out <- rename(out, x = fieldCoordinates.x, y = fieldCoordinates.y)
    out <- select(out, c(x,y))
    
    toWrite <- toJSON(out, pretty = T)
    
    fileName <- paste0("data/", df$touchType.name[1], i + 1, ".json")
    
    write(toWrite, fileName)
  }
}  