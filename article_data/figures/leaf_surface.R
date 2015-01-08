# Author: Guillaume Lobet @ Universite de Liege
#
# Script for the analysis of the leaf surface of plants grown 
# in the rhizoponics setup in two conditions: mock and cadmium
# 
# Published in Mathieu et al, 2015, Plant Methods
#--------------------------------------------------------------------------------

# Load the data
rs <- read.csv("rosette_size_2.csv")

# Set the DAS
rs$das <- 0
for(i in 1:20){
  rs$das[grepl(paste("DAT",i,sep=""), rs$image)]  <- i
}

# Set the treatments
rs$tr[grepl("mock", rs$image)]  <- "mock"
rs$tr[grepl("cd", rs$image)]  <- "cadmium"
rs$tr <- factor(rs$tr)

# Create lists with the data
tr <- unique(rs$tr)
das <- unique(rs$das)


# Make an empty plot
var <- "surface"
plot(rs$das, rs[[var]], type='n', col=rs$tr, axes=F, 
     ylab="leaf surface [cm2]", xlab="time [DAS]", cex.lab=1.2)
axis(1)
axis(2)

# Plot the lines per treatments
i <- 0
for(n in tr){
  temp <- rs[rs$tr == n,]
  mean <- tapply(temp[[var]], temp$das, "mean")
  sd <- tapply(temp[[var]], temp$das, "sd")
  das <- tapply(temp$das, temp$das, "mean")
  diff <- i * 0.05 # Used to create a slight lag between bars
  lines(das+diff, mean, col=temp$tr, lwd=2)
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
  text(n, max(rs[[var]]), sig, cex=1.5) 
}

# Add the legend
legend("bottomright", legend=tr, fill=tr, cex=0.8)

