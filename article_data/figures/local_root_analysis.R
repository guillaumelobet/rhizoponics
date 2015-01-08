 
# Author: Guillaume Lobet @ Universite de Liege
#
# Script for the local analysis of the root systems of plants grown 
# in the rhizoponics setup in two conditions: mock and cadmium
# 
# Published in Mathieu et al, 2015, Plant Methods
#--------------------------------------------------------------------------------

# Load libraries
library(plyr)

# Load the data
rs <- read.csv("local_root.csv")

# Retrieve the marks of interest
rs1 <- rs[rs$mark_type=="Number",]

# Compute the lateral root density
rs2 <- ddply(rs1, ~root, summarize, 
             dens = length(root_name) / (max(position) - min(position)))

# Compute the LAUZ (Length of Apical Unbranched Zone) 
rs3 <- ddply(rs, ~root, summarize, 
              image = unique(Img)[1],
              lauz = (max(position[mark_type=="Length"]) - max(position[mark_type=="Number"])))
rs3 <- rs3[rs3$lauz < Inf,]

# Get the data together
rs4 <- merge(rs2, rs3, by="root")

# Set the treatments
rs4$tr[grepl("cd", rs4$image)]  <- "1cd"
rs4$tr[grepl("mock", rs4$image)]  <- "0mock" 
 

# Plot the lateral root density
par(mfrow=c(1,1), mar=c(5, 5, 3, 3))
 
summary(aov(rs4$dens ~rs4$tr))
boxplot(rs4$dens ~ rs4$tr, boxwex=0.3, axes=F, ylab="Lateral root density [root/cm]", 
         cex.axis=1.2, cex.lab=1.2, ylim=range(0, rs4$dens)*c(1, 1.1), col=c("red", "darkgrey"))
text(2, max(rs4$dens)+0.5, "*", cex=2)
axis(1, at=c(1,2), labels=c("Mock", "Cd"), cex.axis=1.2); axis(2, at=c(0:4), labels=c(0:4), cex.axis=1.2, las = 1)

 
# Plot the LAUZ
summary(aov(rs4$lauz ~rs4$tr))
boxplot(rs4$lauz ~ rs4$tr, boxwex=0.3, axes=F, ylab="Length of apical unbranched zone [cm]", 
         cex.axis=1.2, cex.lab=1.2, ylim=range(0, rs4$lauz)*c(1, 1.1), col=c("red", "darkgrey"))
text(2, max(rs4$lauz)+0.5, "*", cex=2)
axis(1, at=c(1,2), labels=c("Mock", "Cd"), cex.axis=1.2); axis(2, at=seq(from=0, to=12, by=3), labels=seq(from=0, to=12, by=3), cex.axis=1.2, las=1)

 
# read the data for the lateral roots length
rs <- read.csv("lateral_root.csv")
color <- c("#FF001D80", "#00000080")
 
# Set the treatments
rs$tr[grepl("cd", rs$image)]  <- "1cd"
rs$tr[grepl("mock", rs$image)]  <- "0mock" 
rs$tr <- factor(rs$tr)

# Plot the lateral root length as a functino for their position on the primary
# This is a proxi for the lateral root growth
plot(rs$insertion_position, rs$length, col=color[rs$tr], axes=F, xlab="insertion position of the lateral [cm from parent apex]", ylab="lateral root length [cm]", cex.lab=1.2,pch=16)
axis(1, cex.axis=1.2); axis(2, cex.axis=1.2)
fit1 <- lm(rs$length[rs$tr == "1cd"]~rs$insertion_position[rs$tr == "1cd"])
abline(fit1, col="black", lwd=4)
fit2 <- lm(rs$length[rs$tr == "0mock"]~rs$insertion_position[rs$tr == "0mock"])
abline(fit2, col="red", lwd=4)
legend("topleft", fill=c("red", "black"), legend=c("Mock", "Cd"), cex=1.2)
 
 
 