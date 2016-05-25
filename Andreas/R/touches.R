library(XML)

getScore <- function(XL, minutes, seconds) {
  allMatches <- xL[['apiResults']][["sport"]][["league"]][["season"]][["eventType"]][["eventTypeItem"]][['events']][['event']][['periodDetails']]
  if(xL[['apiResults']][["sport"]][["league"]][["season"]][["eventType"]][["eventTypeItem"]][['events']][['event']][['teams']][[1]][['abbreviation']] == "FCM"){
    home= TRUE
  }
  else{
    home = FALSE
  }
  data <- data.frame(lead = character())
  for(i in length(allMatches):1){
    for(j in length(allMatches[[i]][['goals']]):1)
      if(as.numeric(allMatches[[i]][['goals']][[j]][['time']][['minutes']]) < as.numeric(minutes) || (as.numeric(allMatches[[i]][['goals']][[j]][['time']][['minutes']]) == as.numeric(minutes) && as.numeric(allMatches[[i]][['goals']][[j]][['time']][['seconds']]) < as.numeric(seconds))){
        if(as.numeric(allMatches[[i]][['goals']][[j]][['currentScore']][['homeScore']]) > as.numeric(allMatches[[i]][['goals']][[j]][['currentScore']][['awayScore']] )){
          if(home){
            return("Winning")
          }
          else{
            return("Losing")
          }
        }
        else if(as.numeric(allMatches[[i]][['goals']][[j]][['currentScore']][['homeScore']]) < as.numeric(allMatches[[i]][['goals']][[j]][['currentScore']][['awayScore']] )){
          if(home){
            return("Losing")
          }
          else{
            return("Winning")
          }
        }
        else{
          return("Tied")
        }
      }
  }
  return("Tied") 
}

data <- data.frame(type=character() ,x = numeric(), y = numeric(), lead=character(), time=numeric())
for(temp in c("C:/Users/Andreas/Desktop/R/singular/fcm_viborg_2_0.xml")){#,"C:/Users/Andreas/Desktop/R/singular/fcm_viborg_2_4.xml", "C:/Users/Andreas/Desktop/R/singular/agf_fcm_2_1.xml")){
  doc <- xmlParse(temp,useInternalNodes = TRUE)
  xL <- xmlToList(doc)
  
  allMatches <- xL[['apiResults']][["sport"]][["league"]][["season"]][["eventType"]][["eventTypeItem"]][['events']][['event']][['touches']]
  
  #Prepare dataframe
  
  
  
  
  for(i in 1:length(allMatches)){
    touch <- allMatches[[i]]
    if(touch[['team']][['abbreviation']] == "FCM" && (touch[['touchType']][['name']] == "Good Pass" || touch[['touchType']][['name']] == "Bad Pass")){
      new_row <- data.frame(type=touch[['touchType']][['name']] , x=as.numeric(touch[['fieldCoordinates']][['x']]), y=as.numeric(touch[['fieldCoordinates']][['y']]), lead = getScore(XL, touch[['time']][['minutes']], touch[['time']][['seconds']]), time = as.numeric(touch[['time']][['minutes']]))
      data <- rbind(data, new_row)  
    }
  }

}
out <- dplyr::select(data, time, type, lead)
out
#ctable <- table(dplyr::select(data, type ,lead))
#ctable

#barplot(prop.table(ctable, 2)[2,]*100, main="Passes when in front and behind", ylab="Failed passes in percent",xlab="Status of the match", col=c("darkblue","red", "green"), beside=TRUE)



