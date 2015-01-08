# Author: Guillaume Lobet @ Universite de Liege
#
# Script for the analysis of the root surface of plants grown 
# in the rhizoponics setup in two conditions: mock and cadmium
# 
# Published in Mathieu et al, 2015, Plant Methods
#--------------------------------------------------------------------------------

# Load the data
rs <- read.csv("root_size.csv")

# Set the DAS
rs$das <- 0
for(i in 1:20){
  rs$das[grepl(paste("DAT",i,sep=""), rs$image)]  <- i
}

## Set the treatments
myStr <- "\\)"
rs <- rs[rs$das < 20 & rs$area > 0 & !grepl(myStr,rs$image) & !grepl("PA_",rs$image),]
rs$tr[grepl("mock", rs$image)]  <- "mock"
rs$tr[grepl("cd", rs$image)]  <- "cadmium"
rs$tr <- factor(rs$tr)

# Create lists with the data
tr <- unique(rs$tr)
das <- unique(rs$das)


# Make an empty plot
var <- "area"
plot(rs$das, rs[[var]], type='n', axes=F, ylab="root surface [cm2]", xlab="time [DAS]", cex.lab=1.2)
axis(1)
axis(2)

# Plot the loines per treatments
i <- 0
for(n in tr){
  temp <- rs[rs$tr == n,]
  mean <- tapply(temp[[var]], temp$das, "mean")
  sd <- tapply(temp[[var]], temp$das, "sd")
  das <- tapply(temp$das, temp$das, "mean")
  diff <- i * 0.05 # Used to create a slight lag between bars
  lines(das+diff, mean, col=temp$tr, lwd=2, lty=as.numeric(temp$tr))
  arrows(das+diff, mean-sd, das+diff, mean+sd, length=0, col=temp$tr, lwd=2)
  points(das+diff, mean, pch=21, col=temp$tr, bg="white", lwd=2)
  i <- i+1
}

# Add the signification levels
for(n in das){
  temp <- rs[rs$das == n,]
  fit <- aov(temp[[var]] ~ temp$tr)
  sig <- "-"
  if(summary(fit)[[1]][1,5] < 0.05) sig <- "*"
  #if(summary(fit)[[1]][1,5] < 0.01) sig <- "**"
  text(n, max(rs[[var]]), sig, cex=1.5) 
}

# Add the legend
legend("bottomright", legend=tr, col=tr, cex=0.8, lty=as.numeric(tr), lwd=2)

