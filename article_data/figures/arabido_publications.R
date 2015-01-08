# Author: Guillaume Lobet @ Universite de Liege
#
# Script for the creation of a bar plot comparing the number of publications about different plant modes
# Data are coming from the Scopus database in the Biochemistry, Genetics and Molecular Biology section. 
# Vernacular names were used for search in abstracts, title and keywords.
# 
# Published in Mathieu et al, 2015, Plant Methods

# Data from Scopus (manually curated)
plants <- c("Arabidopsis thaliana","Oriza sativa", "Zea mays", "Hordeum vulgare", "Triticum aestivum", "Solanum lycopersicum", "Solanum tuberosum", "Brassica napus", "Glycine max")
publis <- c(3997,2303,1250,606,1883,960,701,222,1287)

# Create a data frame with the results
rs <- data.frame(cbind(plants,publis))
rs$publis <- as.numeric(as.character(rs$publis))
rs <- rs[order(rs$publis, decreasing = T),]

# Plot the data using a custom bar plot (better looking)
par(mar=c(8, 5, 2, 2))
plot(1, 1, type="n", axes=F, ylab="number of publications [-]", xlab="", 
     ylim=range(0, max(publis)), xlim=range(0, length(plants)), cex.lab=1.2)
axis(2)
colors <- c("#136632", rep("grey", length(plants)))
dev <- 0.3
for(i in 1:length(plants)){
  end <- rs$publis[i]
  polygon(c(i-dev, i-dev, i+dev, i+dev), c(0, end, end, 0), col=colors[i])
}
text(1:length(rs$publis), -200, srt = 45, adj = 1, labels = rs$plants, xpd = TRUE, cex=1)

legend("topright", legend="Number of publications in 2013 \nin Biochemistry, Genetics and \nMolecular Biology. \n\nVernacular names were used \nfor search in abstracts, title \nand keywords.\n\nSource: Scopus", box.col = "white", cex=0.8)
