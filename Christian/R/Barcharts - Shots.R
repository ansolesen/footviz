library(dplyr)
library(magrittr)
library(ggplot2)
library(tidyr)
library(XML)

wd <- "/home/christian/git/localfootviz/New"
setwd(wd)
df = read.csv("Superligaen15-16.csv", header = TRUE)

getRanking <- function(id) {
  fileurl <- "rankings.xml"
  doc <- xmlParse(fileurl,useInternalNodes = TRUE)
  xL <- xmlToList(doc)
  teamInfo <- xL[['apiResults']][["sport"]][["league"]][["season"]][['eventType']][['eventTypeItem']][['conferences']][['conference']][['divisions']][['division']][['teams']]
  for(i in 1:length(teamInfo)){
    if(teamInfo[[i]][['teamId']] == id){
      return(as.numeric(teamInfo[[i]][['league']][['rank']]))
    }
  }  
}
#4 and 6 are teamname and playername
Shots <- df[c(4, 6, 32:42, 10, 17)]
ShotStats <- Shots[c(1, 3, 5:6, 9, 13, 12, 14, 15)]
allteams <- levels(ShotStats$Team)
splitShots <- split(ShotStats, ShotStats$Team)
#nvars = number of variables (long, medium, short passes for instance)
nvars = 2 #Header or Footer

axis1 <- character(3*12)
value1 <- numeric(3*12)
axis2 <- character(3*12)
value2 <- numeric(3*12)

teamlist1 <- character(nvars*12)
teamlist2 <- character(3*12)
rank1 <- numeric(nvars*12)
rank2 <- numeric(3*12)

#View(allteams)
rank1[c(1:2)] <- getRanking(7543)
rank1[c(3:4)] <- getRanking(10144)
rank1[c(5:6)] <- getRanking(7533)
rank1[c(7:8)] <- getRanking(10145)
rank1[c(9:10)] <- getRanking(6447)
rank1[c(11:12)] <- getRanking(10146)
rank1[c(13:14)] <- getRanking(7536)
rank1[c(15:16)] <- getRanking(27921)
rank1[c(17:18)] <- getRanking(6315)
rank1[c(19:20)] <- getRanking(10147)
rank1[c(21:22)] <- getRanking(10148)
rank1[c(23:24)] <- getRanking(7537)

rank2[c(1:3)] <- getRanking(7543)
rank2[c(4:6)] <- getRanking(10144)
rank2[c(7:9)] <- getRanking(7533)
rank2[c(10:12)] <- getRanking(10145)
rank2[c(13:15)] <- getRanking(6447)
rank2[c(16:18)] <- getRanking(10146)
rank2[c(19:21)] <- getRanking(7536)
rank2[c(22:24)] <- getRanking(27921)
rank2[c(25:27)] <- getRanking(6315)
rank2[c(28:30)] <- getRanking(10147)
rank2[c(31:33)] <- getRanking(10148)
rank2[c(34:36)] <- getRanking(7537)



for (i in 1:12){
  team = allteams[[i]]
  # testing <- data.frame(splitShots[1])
  absout <- data.frame(splitShots[i]) %>%
    dplyr::select(2:9) %>% 
    dplyr::summarise_each(funs(sum(., na.rm = TRUE))) 
  names(absout) <- c(
    "Total", 
    "Foot", 
    "Head", 
    "InsideBox",
    "OutsideBox", 
    "OnTarget",
    "Goals",
    "Chances")
  absout <-  dplyr::mutate(absout, Team = team) 
  percout <- dplyr::transmute(absout, Team = Team,
                              Foot = Foot/Total,
                              Head = Head/Total,
                              InsideBox = InsideBox/Total,
                              OutsideBox = OutsideBox/Total,
                              OnTarget = Goals/Chances
  ) 
  # percout
  #  pd1 <- dplyr::select(percout, 2:6)
  #  plotdata1 <- tidyr::gather(dplyr::select(percout, 2:6))
  #  plotdata1
  #  plot <- ggplot(plotdata1, aes(x = key, y=value, fill=factor(key), )   )
  #  plot + geom_bar(width=1, stat="identity")
  
  #  percout
  #  pd1
  #  p1 <- ggplot(percout, aes(x=Team, y=value, fill=Team))
  #  p1 + geom_bar(stat="identity")
  
  teamlist1[(nvars*i)-1] <- team
  teamlist1[(nvars*i)] <- team
  
  teamlist2[(3*i)-2] <- team
  teamlist2[(3*i)-1] <- team
  teamlist2[(3*i)]   <- team
  
  axis1[(3*i)-2] <- "Foot"
  axis1[(3*i)-1] <- "Head"
  axis1[(3*i)] <- "OnTarget"
  
  axis2[(3*i)-2] <- "InsideBox"
  axis2[(3*i)-1] <- "OutsideBox"
  axis2[3*i] <- "OnTarget"
  
  
  value1[(3*i)-2] <- percout$Foot
  value1[(3*i)-1] <- percout$Head
  value1[(3*i)] <- percout$OnTarget
  
  value2[(3*i)-2] <- percout$InsideBox
  value2[(3*i)-1] <- percout$OutsideBox
  value2[3*i] <- percout$OnTarget
  
  # Team[i] <- team
  # OpenPlayNotAttack[i] <- percout$OpenPlayNotAttack
  # PossessionBased[i] <- percout$PossessionBased
  # QuickAttacks[i] <- percout$QuickAttacks
  # Penalty[i] <- percout$Penalty
  #  SetPlay[i] <- percout$SetPlay
  
  #tes1 <- tidyr::gather(dplyr::select(percout, 2:3))
#  p1 <- ggplot(tes1, aes(x=team, y=value, fill=key   )) + 
 #   geom_bar(stat="identity", position="stack", width=0.1)
 # p1 
}
hedr <- data.frame(Rank=rank2, Team=teamlist2, Variables=axis1, Percent=value1*100)
hedr$Team <- factor(hedr$Team, levels=unique(hedr$Team[order(hedr$Rank)]))

io <- data.frame(Rank=rank2, Team=teamlist2, Variables=axis2, Percent=value2*100)
io$Team <- factor(io$Team, levels=unique(io$Team[order(io$Rank)]))

#percentdata <- data.frame(Team=teamlist, axis, value)

#Sorter

hedrplot <- ggplot(hedr, aes(x=Team, y=Percent, fill=Variables  ))
hedrplot <- hedrplot + 
  geom_bar(stat="identity", colour="white", position=position_dodge(width=0.5)) + 
  theme(axis.text.x = element_text(angle=60, hjust=1, face="bold", size=12)) +
  ggtitle("Shots with foot or head + successful chances") + 
  scale_fill_discrete(
    breaks=c("Foot", "Head", "OnTarget"),
    labels=c("Shots with foot", "Shots with head", "Successful chances")
  )
 # facet_grid(~Team)

ioplot <- ggplot(io, aes(x=Team, y=Percent, fill=Variables  ))
ioplot <- ioplot + 
  geom_bar(stat="identity", colour="white", position=position_dodge(width=0.8), width=1) +
  theme(axis.text.x = element_text(angle=70, hjust=1, face="bold", size=12)) +
  ggtitle("Ratio of shots from inside box vs outside box") + 
  scale_fill_discrete(
    breaks=c("InsideBox", "OutsideBox", "OnTarget"),
    labels=c("Shots from inside the box", "Shots from outside the box", "Successful chances")
    )

pdf("Shots_hf.pdf")
plot(hedrplot)
dev.off()

pdf("Shots_io.pdf")
plot(ioplot)
dev.off()

  #io

#write.csv(percentdata, file="shots.csv", row.names = FALSE)
