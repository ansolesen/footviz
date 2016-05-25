library(XML)

getScore <- function(XL, minutes, seconds) {
  return("N/A")
  allMatches <- xL[['apiResults']][["sport"]][["league"]][["season"]][["eventType"]][["eventTypeItem"]][['events']][['event']][['periodDetails']]
  allMatches
  if(xL[['apiResults']][["sport"]][["league"]][["season"]][["eventType"]][["eventTypeItem"]][['events']][['event']][['teams']][[1]][['abbreviation']] == "FCM"){
    home= TRUE
  }
  else{
    home = FALSE
  }
  data <- data.frame(lead = character())
  for(i in length(allMatches):1){
    for(j in length(allMatches[[i]][['goals']]):1){
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
}
  return("Tied") 
}

data <- data.frame(good=numeric(), bad=numeric() ,x = numeric(), y = numeric(), lead=character(), time=numeric())
failed = 0
suceeded = 0
for(temp in c("C:/Users/Andreas/Desktop/R/singular/viborg_fcm_1_1.xml")){#,"C:/Users/Andreas/Desktop/R/singular/fcm_viborg_2_4.xml", "C:/Users/Andreas/Desktop/R/singular/agf_fcm_2_1.xml")){
  doc <- xmlParse(temp,useInternalNodes = TRUE)
  xL <- xmlToList(doc)
  
  allMatches <- xL[['apiResults']][["sport"]][["league"]][["season"]][["eventType"]][["eventTypeItem"]][['events']][['event']][['touches']]
  periods <- xL[['apiResults']][["sport"]][["league"]][["season"]][["eventType"]][["eventTypeItem"]][['events']][['event']][['periodDetails']]
  
  #Prepare dataframe

  
  periods[[2]][['shots']][['shot']]
  fails = 0
  suceeded = 0
  for(i in 1:length(allMatches)){
    touch <- allMatches[[i]]
    if(touch[['team']][['abbreviation']] == "FCM" && (touch[['touchType']][['name']] == "Good Pass" || touch[['touchType']][['name']] == "Bad Pass")){
      if(touch[['touchType']][['name']] == "Bad Pass"){
        fails = fails +1
      }
      else{
        suceeded = suceeded +1
      }
    new_row <- data.frame(type=touch[['touchType']][['name']], failCount=as.numeric(fails), suceeded=as.numeric(suceeded), x=as.numeric(touch[['fieldCoordinates']][['x']]), y=as.numeric(touch[['fieldCoordinates']][['y']]), lead = getScore(XL, touch[['time']][['minutes']], touch[['time']][['seconds']]), time = (as.numeric(touch[['time']][['minutes']])*60+as.numeric(touch[['time']][['seconds']])))
    data <- rbind(data, new_row) 
    }
  }
  for(j in 1:length(periods)){
    period <- periods[[j]][['shots']]

    for(i in 1:length(period)){
      touch <- period[[i]]
      if(touch[['team']][['abbreviation']] == "FCM"){
        if(as.numeric(touch[['fieldCoordinates']][['x']]) > 57.5){
          new_row <- data.frame(type="Shot", failCount=as.numeric(fails),suceeded=as.numeric(suceeded),x=(as.numeric(touch[['fieldCoordinates']][['x']]) %% 57.5), y=(as.numeric(touch[['fieldCoordinates']][['y']]) %% 34), lead = getScore(XL, as.numeric(touch[['time']][['minutes']]), as.numeric(touch[['time']][['seconds']])), time = (as.numeric(touch[['time']][['minutes']])*60+as.numeric(touch[['time']][['seconds']])))
          
        }else{
          new_row <- data.frame(type="Shot", failCount=as.numeric(fails),suceeded=as.numeric(suceeded),x=(as.numeric(touch[['fieldCoordinates']][['x']]) %% 57.5), y=(as.numeric(touch[['fieldCoordinates']][['y']])), lead = getScore(XL, as.numeric(touch[['time']][['minutes']]), as.numeric(touch[['time']][['seconds']])), time = (as.numeric(touch[['time']][['minutes']])*60+as.numeric(touch[['time']][['seconds']])))
          
        }
         data <- rbind(data, new_row) 
    }
    }
  }  
  
}
head(data)
write.csv(data, file = "C:/Users/Andreas/Desktop/R/passes_bar.csv")
# 
# barplot(prop.table(ctable, 2)[2,]*100, main="Passes when in front and behind", ylab="Failed passes in percent",xlab="Status of the match", col=c("darkblue","red", "green"), beside=TRUE)
# 
# 
# 
