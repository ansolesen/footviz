# #install.packages("XLConnect")
# #install.packages(c("tidyr", "devtools"))
# library(XLConnect)
# theData <- readWorksheet(loadWorkbook("C:/Users/Andreas/Desktop/R/data.xlsx"),sheet=1)
# 
# theData <- dplyr::mutate(theData, Minutes = round(Seconds/60, digits=0))
# 
# onlyAab <- dplyr::filter(theData, Body.Part == 'Foot' & is.na(Free.Kick.))
# 
# selected <- dplyr::select(onlyAab, Minutes, Team, Shot, Scoreline, X, Y)
# 
# score <- tidyr::separate(selected, Scoreline, c("Self", "Other"), "-")
# 
# distance <- dplyr::mutate(score, Distance = (round(sqrt((X-5250)^2 + Y^2), digits=0)*105/10500))
# write.csv(distance, file = "C:/Users/Andreas/Desktop/R/MyData.csv")
# 
# #Aggregation
# 
# 
# #install.packages('data.tree');
#library(plyr)
#library(XML)
#install.packages("ggplot2")
library(ggplot2)
#multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


getRanking <- function(id) {
  fileurl <- "C:/Users/Andreas/Desktop/R/rankings.xml"
  doc <- xmlParse(fileurl,useInternalNodes = TRUE)
  xL <- xmlToList(doc)
  teamInfo <- xL[['apiResults']][["sport"]][["league"]][["season"]][['eventType']][['eventTypeItem']][['conferences']][['conference']][['divisions']][['division']][['teams']]
  for(i in 1:length(teamInfo)){
    if(teamInfo[[i]][['teamId']] == id){
      return(as.numeric(teamInfo[[i]][['league']][['rank']]))
    }
  }  
}

teamPlot <- function(url) {
  
  WX <- numeric()
  WY <- numeric()
  WZ <- numeric()
  LX <- numeric()
  LY <- numeric()
  LZ <- numeric()
  TX <- numeric()
  TY <- numeric()   
  TZ <- numeric() 
  
  for(temp in url){
    doc <- xmlParse(temp,useInternalNodes = TRUE)
    xL <- xmlToList(doc)
    
    id <- allMatches[[1]][['team']][['teamId']]
    allMatches <- xL[['apiResults']][["sport"]][["league"]][["teams"]][["team"]][["seasons"]][['season']][['eventType']][['eventTypeItem']][['splits']][['split']][['events']]
    x <- numeric()
    y <- numeric()
    z <- numeric()
    for(i in 1:length(allMatches)){
      
      x <- as.numeric(allMatches[[i]][['teamStats']][['teamStats']][['touches']][['interceptions']])
      y <- as.numeric(allMatches[[i]][['teamStats']][['teamStats']][['goals']][['total']])
      #z <- as.numeric(allMatches[[i]][['teamStats']][['teamStats']][['touches']][['passes']])
      
      
      if(getRanking(id) <= 4){ #good team
        WX <- c(WX, x)
        WY <- c(WY, y)
        WZ <- c(WZ, z)
      }
      else if(getRanking(id) >= 9){
        LX <- c(LX, x)
        LY <- c(LY, y)
        LZ <- c(LZ, z)
      }
      else{
        TX <- c(TX, x)
        TY <- c(TY, y) 
        TZ <- c(TZ, z) 
      }
    }
  
    # id <- allMatches[[1]][['team']][['teamId']]
    # rank <- getRanking(id)
    # if(rank >= 7){
    #   LPossesion <- c(LPossesion, x)
    #   LShots <- c(LShots, y)
    # }
    # else{
    #   WPossesion <- c(WPossesion, x)
    #   WShots <- c(WShots, y)
    # }  

    
    
  }
  winner = data.frame(
    Var1 = WX,
    Var2 = WY,
    #value = WZ
  )  
  loser = data.frame(
    Var1 = LX,
    Var2 = LY,
    value = LZ
  )
  middle = data.frame(
    Var1 = TX,
    Var2 = TY,
    value = TZ
  )   
  head(data)
  a <- ggplot(data = winner, aes(x=Var1, y=Var2, fill=value)) + geom_tile(aes(fill = value),colour = "white") + scale_fill_gradient(low = "white", high = "green") +xlab("Ball Possesion")+ylab("Total Shots")+labs(fill="On Target") +ggtitle("The four top ranked teams.")+ stat_summary(geom="line", fun.y=mean, color = "blue",lwd=1)+theme_classic()+geom_smooth(method="lm") #+coord_cartesian(xlim = c(35, 65), ylim =c(5,25))
  #b <- ggplot(data = middle, aes(x=Var1, y=Var2, fill=value)) + geom_tile(aes(fill = value),colour = "white") + scale_fill_gradient(low = "white", high = "yellow") +xlab("Ball Possesion")+ylab("Total Shots")+labs(fill="On Target") +ggtitle("The four middle ranked teams.") + stat_summary(geom="line", fun.y=mean, color = "blue",lwd=1)+theme_classic()+geom_smooth(method="lm")# +coord_cartesian(xlim = c(35, 65), ylim =c(5,25))
  #c <- ggplot(data = loser, aes(x=Var1, y=Var2, fill=value)) + geom_tile(aes(fill = value),colour = "white") + scale_fill_gradient(low = "white", high = "red") +xlab("Ball Possesion")+ylab("Total Shots")+labs(fill="On Target")+ggtitle("The four lowest ranked teams.") + stat_summary(geom="line", fun.y=mean, color = "blue",lwd=1)+geom_smooth(method="lm")+theme_classic()# +coord_cartesian(xlim = c(35, 65), ylim =c(5,25))
  multiplot(a,b,c,cols=1)
  # plot(WY~WX, col="green")
  # points(LY~LX, col="red")
  # points(TY~TX, col="orange")


  }
teamPlot(c("C:/Users/Andreas/Desktop/R/agf.xml","C:/Users/Andreas/Desktop/R/fcn.xml","C:/Users/Andreas/Desktop/R/viborg.xml","C:/Users/Andreas/Desktop/R/ob.xml","C:/Users/Andreas/Desktop/R/randers.xml","C:/Users/Andreas/Desktop/R/aab.xml","C:/Users/Andreas/Desktop/R/brondby.xml","C:/Users/Andreas/Desktop/R/fck.xml","C:/Users/Andreas/Desktop/R/fcm.xml","C:/Users/Andreas/Desktop/R/sje.xml","C:/Users/Andreas/Desktop/R/hobro.xml", "C:/Users/Andreas/Desktop/R/esbjerg.xml"))


#abline(lm(y ~ x))
#lines(lowess(x,y), col="blue")



# 
# length(FCM)
# FCM['season']
# Opponent <- xL[["teamStats"]][[2]] #oponent
# 
# 
# data <- ldply(FCM['event'], data.frame)
# 
# data

