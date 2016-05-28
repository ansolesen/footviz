library(dplyr)
library(magrittr)
library(ggplot2)
wd <- "C:/Users/chris/workspace/FootViz"
setwd(wd)
df = read.csv("Superligaen15-16.csv", header = TRUE)

#4 and 6 are teamname and playername
Passes <- df[c(4, 6, 58, 64:70)]
PassDist <- Passes[c(1, 7, 5:6, 9)]
PassDir <- Passes[c(1, 7, 3:4, 10)]
splitDir <- split(PassDir, PassDir$Team)
allteams <- levels(PassDist$Team)
splitPasses <- split(PassDist, PassDist$Team)
#nvars = number of variables (long, medium, short passes for instance)
nvars = 3
axis <- character(nvars*12)
value <- numeric(nvars*12)
axis2 <- character(nvars*12)
value2 <- numeric(nvars*12)
teamlist <- character(nvars*12)
rank2 <- numeric(3*12)

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
 
  absout <- data.frame(splitPasses[i]) %>%
    dplyr::select(2:5) %>% 
    dplyr::summarise_each(funs(sum(., na.rm = TRUE))) 
  names(absout) <- c(
    "Total", 
    ">34m", 
    "17-34m", 
    "<17m")
  absout <-  dplyr::mutate(absout, Team = team) 
  
  dirabs <- data.frame(splitDir[i]) %>%
    dplyr::select(2:5) %>%
    dplyr::summarise_each(funs(sum(., na.rm = TRUE)))
  names(dirabs) <- c(
    "Total", 
    "Backward",
    "Forward",
    "Sideways"
  )
  dirabs <- dplyr::mutate(dirabs, Team=team)
  
  percout <- dplyr::transmute(absout, Team = Team,
                              '>34m' = absout$`>34m`/Total,
                              '17-34m' = absout$`17-34m`/Total,
                              '<17m' = absout$`<17m`/Total) 
  dirperc <- dplyr::transmute(dirabs, Team=Team, 
                              "Backward" = dirabs$Backward/Total,
                              "Forward" = dirabs$Forward/Total,
                              "Sideways" = dirabs$Sideways/Total)

  axis[(nvars*i)-2] <- '>34m'
  axis[(nvars*i)-1] <- '17-34m'
  axis[nvars*i] <- '<17m'
  
  value[(nvars*i)-2] <- percout$'>34m'
  value[(nvars*i)-1] <- percout$'17-34m'
  value[nvars*i] <- percout$'<17m'
  
  axis2[nvars*i-2] <- "Backward"
  axis2[nvars*i-1] <- "Forward"
  axis2[nvars*i] <- "Sideways"
  
  value2[(nvars*i)-2] <- dirperc$Backward
  value2[(nvars*i)-1] <- dirperc$Forward
  value2[nvars*i] <- dirperc$Sideways
  
  teamlist[(3*i)-2] <- team
  teamlist[(3*i)-1] <- team
  teamlist[(3*i)]   <- team
  
  
  
  # Team[i] <- team
  # OpenPlayNotAttack[i] <- percout$OpenPlayNotAttack
  # PossessionBased[i] <- percout$PossessionBased
  # QuickAttacks[i] <- percout$QuickAttacks
  # Penalty[i] <- percout$Penalty
  #  SetPlay[i] <- percout$SetPlay
  
}
percentdata <- data.frame(Rank=rank2, Team=teamlist, Length=axis, Percent=value*100)
percentdata$Team <- factor(percentdata$Team, levels=unique(percentdata$Team[order(percentdata$Rank)]))

passdirdat <- data.frame(Rank=rank2, Team=teamlist, Direction=axis2, Percent=value2*100)
passdirdat$Team <- factor(passdirdat$Team, levels=unique(passdirdat$Team[order(passdirdat$Rank)]))


plot <- ggplot(percentdata, aes(x=Team, y=Percent, fill=Length  ))
plot <- plot + 
  geom_bar(stat="identity", colour="white", position=position_dodge(width=0.8), width=1) +
  theme(axis.text.x = element_text(angle=70, hjust=1, face="bold", size=12)) +
  ggtitle("Average length of passes (%)") 

plot2 <- ggplot(passdirdat, aes(x=Team, y=Percent, fill=Direction  ))
plot2 <- plot2 + 
  geom_bar(stat="identity", colour="white", position=position_dodge(width=0.8), width=1) +
  theme(axis.text.x = element_text(angle=70, hjust=1, face="bold", size=12)) +
  ggtitle("Average direction of passes (%)")
#  scale_fill_discrete(
#    breaks=c(">34m", "17-34m", "<17m"),
   # labels=c("Shots from inside the box", "Shots from outside the box", "Shots on target")
#  )

pdf("Pass_Length.pdf")
plot(plot)
dev.off()
pdf("Pass_Direction.pdf")
plot(plot2)
dev.off()

#write.csv(percentdata, file="passtypes.csv", row.names = FALSE)
