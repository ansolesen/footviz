library(XML)
library(ggplot2)

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


  x <- numeric()
  y <- numeric()
  c <- numeric()
  d <- numeric()
  e <- numeric()
  f <- numeric()
  g <- numeric()
  h <- numeric()  
  j <- numeric()
  z <- numeric()
  
  for(temp in c("C:/Users/Andreas/Desktop/R/agf.xml","C:/Users/Andreas/Desktop/R/fcn.xml","C:/Users/Andreas/Desktop/R/viborg.xml","C:/Users/Andreas/Desktop/R/ob.xml","C:/Users/Andreas/Desktop/R/randers.xml","C:/Users/Andreas/Desktop/R/aab.xml","C:/Users/Andreas/Desktop/R/brondby.xml","C:/Users/Andreas/Desktop/R/fck.xml","C:/Users/Andreas/Desktop/R/fcm.xml","C:/Users/Andreas/Desktop/R/sje.xml","C:/Users/Andreas/Desktop/R/hobro.xml", "C:/Users/Andreas/Desktop/R/esbjerg.xml")){
    doc <- xmlParse(temp,useInternalNodes = TRUE)
    xL <- xmlToList(doc)
  
    allMatches <- xL[['apiResults']][["sport"]][["league"]][["teams"]][["team"]][["seasons"]][['season']][['eventType']][['eventTypeItem']][['splits']][['split']][['events']]
    
    rank <- getRanking(as.numeric(allMatches[[1]][['team']][['teamId']]))
    

    if(as.numeric(rank) <= 3){
      color = "Top 3"
      
    }
    else if(as.numeric(rank) >= 10){
      color = "Bottom 3"
      
    }
    else{
      next
    }
    for(i in 1:length(allMatches)){
      
      x <- c(x, as.numeric(allMatches[[i]][['teamStats']][['teamStats']][['possessionPercentage']]))
      y <- c(y, as.numeric(allMatches[[i]][['teamStats']][['teamStats']][['touches']][['passes']]))
      
      z <- c(z, color)
      
    }
  }
  winner = data.frame(
    Possesion = x,
    Passes = y,
    col = z
  ) 
  lm(y ~ x, winner)
  ggplot(winner, aes(x=Possesion, y=Passes, colour=col))  + geom_point( )+  geom_smooth(method=lm, se=F) + scale_colour_manual(name="Ranking", values = c("Top 3"="steelblue", "Bottom 3"="orangered1"))
  #11.69 *x -271.98 = 10.79 * x -228.09
  #pca <- prcomp(winner, scale.=T, center=T)
  
  pca <- princomp(winner, cor=TRUE, scores=T)
  # pca
   summary(pca)
  # pca$loadings
  # stand <- function(x){ (x - mean(x))}
  # yeya <- apply(winner, 2, function(x){(x-mean(x))})
  # plot(yeya)
   pca$scores
   plot(pca$scores, ylim=c(-4,4), xlim=c(-4,4))
   abline(0,0, col="red" )
   abline(0,9999, col="green" )
  # abline(0, loadings(pca)[1,1]/loadings(pca)[2,1], col = "red")
  # abline(0, loadings(pca)[1,2]/loadings(pca)[2,2], col = "green")
  # 
  # loadings(pca)[1,2]/loadings(pca)[2,2]
  