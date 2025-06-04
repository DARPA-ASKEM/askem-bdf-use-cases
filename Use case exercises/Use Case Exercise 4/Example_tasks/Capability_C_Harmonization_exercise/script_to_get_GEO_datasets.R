#R script to obtain GEO datasets for Use Case Exercise 4 Capability C

#https://bioconductor.org/packages/release/bioc/html/GEOquery.html
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("GEOquery")

library(GEOquery)

# load series and platform data from GEO
# Specify GEO datasets to obtain
ids<-c("GSE50442","GSE2841","GSE67066","GSE51081","GSE19422","GSE39716","GSE19987")

#set directory to write files to
#setwd("<DIRECTORY>")

# obtain datasets from GEO, extract data of interest, and write to files

for (i in 1:length(ids)){
  gset <- getGEO(ids[i], GSEMatrix =TRUE, getGPL=FALSE)
  if (length(gset) > 1) idx <- grep("GPL6244", attr(gset, "names")) else idx <- 1
  gset <- gset[[idx]]
  gsetdf<-gset@phenoData@data
  write.csv(gsetdf,paste0(ids[i],"SampleData.csv"),row.names=FALSE)
}

#Note: gset is an S4 object

# "GSE19987" seems to have 2 separate S4 objects and threw an error, so I then did this:
gsetdf_1<-gset[[1]]@phenoData@data
gsetdf_2<-gset[[2]]@phenoData@data
gsetdf<-rbind(gsetdf_1,gsetdf_2)
write.csv(gsetdf,paste0(ids[i],"SampleData.csv"),row.names=FALSE)

