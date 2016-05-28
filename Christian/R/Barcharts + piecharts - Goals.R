library(dplyr)
library(magrittr)
library(ggplot2)

wd <- "/home/christian/git/localfootviz/New"
setwd(wd)
df = read.csv("Superligaen15-16.csv", header = TRUE)

#4 and 6 are teamname and playername
Goals <- df[c(4, 6, 10, 21:26)]
splitGoals <- split(Goals, Goals$Team)

allteams <- levels(Goals$Team)

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

axis <- character(5*12)
value <- numeric(5*12)
teamlist <- character(5*12)
rank <- numeric(5*12)

#View(allteams)
rank[c(1:5)] <- getRanking(7543)
rank[c(6:10)] <- getRanking(10144)
rank[c(11:15)] <- getRanking(7533)
rank[c(16:20)] <- getRanking(10145)
rank[c(21:25)] <- getRanking(6447)
rank[c(26:30)] <- getRanking(10146)
rank[c(31:35)] <- getRanking(7536)
rank[c(36:40)] <- getRanking(27921)
rank[c(41:45)] <- getRanking(6315)
rank[c(46:50)] <- getRanking(10147)
rank[c(51:55)] <- getRanking(10148)
rank[c(56:60)] <- getRanking(7537)

#View(rank)


for (i in 1:12){
  team = allteams[[i]]
  
  absout <- data.frame(splitGoals[i]) %>%
    dplyr::select(3:9) %>% 
    dplyr::summarise_each(funs(sum(., na.rm = TRUE))) 
  names(absout) <- c(
    "Total", 
    "OpenPlayNotAttack", 
    "PossessionBased", 
    "QuickAttacks", 
    "Penalty", 
    "SetPlay", 
    "WithFoot")
  absout <-  dplyr::mutate(absout, Team = team) 
  percout <- dplyr::transmute(absout, Team = Team,
                              OpenPlayNotAttack = OpenPlayNotAttack/Total,
                              PossessionBased = PossessionBased/Total,
                              QuickAttacks = QuickAttacks/Total,
                              Penalty = Penalty/Total,
                              SetPlay = SetPlay/Total,
                              WithFoot = WithFoot/Total
  ) 
  axis[(5*i)-4] <- "OpenPlayNotAttack"
  axis[(5*i)-3] <- "PossessionBased"
  axis[(5*i)-2] <- "QuickAttacks"
  axis[(5*i)-1] <- "Penalty"
  axis[5*i] <- "SetPlay"
  
 
  teamlist[(5*i)-4] <- team
  teamlist[(5*i)-3]   <- team
  teamlist[(5*i)-2] <- team
  teamlist[(5*i)-1] <- team
  teamlist[(5*i)]   <- team
  
  value[(5*i)-4] <- percout$OpenPlayNotAttack
  value[(5*i)-3] <- percout$PossessionBased
  value[(5*i)-2] <- percout$QuickAttacks
  value[(5*i)-1] <- percout$Penalty
  value[5*i] <- percout$SetPlay-percout$Penalty
  
tempvalue <- numeric(5)
tempvalue[1] <- percout$OpenPlayNotAttack
tempvalue[2]<- percout$PossessionBased
tempvalue[3] <- percout$QuickAttacks
tempvalue[4] <- percout$Penalty
tempvalue[5] <- percout$SetPlay-percout$Penalty

  tempdata <- data.frame(Source=axis[c(1:5)], Percent=tempvalue*100)
  
  pos <- tempdata %>% mutate(pos=cumsum(Percent)-0.5*Percent)
  
  
  
  plot2 <- ggplot(tempdata, aes(x="",  y=Percent, fill=axis[c(1:5)]  )) +
    geom_bar(stat="identity", colour="white", width=1) +
    geom_text(aes(x=1.2, 
                  y=pos$pos,
                  label=round(Percent, digits=1)
                  ),
              size=5) +
    coord_polar(theta="y")# +
  #  facet_grid( ~team. ) 
  
  pdf(paste(team, "Goal_pie.pdf"))
  plot(plot2)
  dev.off()
  
  # Team[i] <- team
  # OpenPlayNotAttack[i] <- percout$OpenPlayNotAttack
  # PossessionBased[i] <- percout$PossessionBased
  # QuickAttacks[i] <- percout$QuickAttacks
  # Penalty[i] <- percout$Penalty
  #  SetPlay[i] <- percout$SetPlay
  
}
#percentdata <- data.frame(axis, value)
#####################SETPLAY GOALS CONTAIN PENALTY GOALS AS WELL###################################
percentdata <- data.frame(Rank=rank, Team=teamlist, Source=axis, Percent=value*100)

percentdata$Team <- factor(percentdata$Team, levels=unique(percentdata$Team[order(percentdata$Rank)]))

plot <- ggplot(percentdata, aes(x=Team, y=Percent, fill=Source  )) +
 
  geom_bar(stat="identity", colour="white", position=position_dodge(width=0.9), width=1) +
  theme(axis.text.x = element_text(angle=70, hjust=1, face="bold", size=12)) +
  ggtitle("Source of goals") +
  scale_fill_discrete(
 #  breaks=c(">34m", "17-34m", "<17m"),
    labels=c("Open Play, not attacking",
             "Penalty",
             "Possession based attack",
             "Quick Attacks",
             "Set plays")
   )

plot 


pdf("Goal_plot.pdf")
plot(plot)
dev.off()

#write.csv(percentdata, file="goaltypes.csv", row.names = FALSE)