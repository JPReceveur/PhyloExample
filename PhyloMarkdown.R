---
  title: "Creating a phylogeny from the 1000 Genome Database"
author: "JReceveur"
date: "June 11, 2017"
output: html_document
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Creating a Dendrogram from a  downloaded VCF file
This document provides an example of creating a dendrogram from a VCF file. The VCF file can be altered using VCFtools to look at a specific area of the genome. The lines in red are the code you should enter, while the lines starting with ## are what you would expect to see for the output

This document was created using Rmarkdown <http://rmarkdown.rstudio.com>.


```
#Loading Packages
The packages will have to be loaded each time you open R or Rstudio.
```{r}
library(gdsfmt)
library(SNPRelate)
library(ggplot2)
```
#Loading VCF file 
There are two ways that the VCF file can be loaded into Rstudio. The first is directly specifying the file path and name, the second is using the file.choose option which will open a browser so you can search for the file. The second optio that is currently commented out with # (putting a # before any code means it will be treated as text, to run it, just remove the #).
```{r}
vcf.fn <- "C:\\Users\\Joe Receveur\\Documents\\Virtual Box\\Benin\\10kb.recode.vcf"
#vcf.fn<- file.choose()
```

#Parsing
The next command will turn the VCF file into a less data intensive form (GDS) for easier computing. If you have loaded the entire genome, expect this command to take an hour or more.  
```{r}
snpgdsVCF2GDS(vcf.fn,"data.gds",method ="biallelic.only")
```

#Formatting for dissimilarity matrix
These commands prepare the data so it is formatted correctly to create a dissimilarity matrix.
```{r}
genofile<-snpgdsOpen("data.gds")
set.seed(100)
ibs.hc<-snpgdsHCluster(snpgdsIBS(genofile,num.thread=2, autosome.only=FALSE))
```

#Turn the clustering into a tree file and plotting tree
This step takes the clustering results from before and turns the numerical values into a dendrogram
```{r}
rv <- snpgdsCutTree(ibs.hc)
plot(rv$dendrogram,main="Within 10 kb of ACE-1")

```

#Dissimilarity matrix
This command creates a dissimilarity matrix between all the samples. If you are looking at the X chromosome, make sure the autosome.only= code is changed to autosome.only=False.
```{r}
dissMatrix  =  snpgdsIBS(genofile , sample.id=NULL, autosome.only=TRUE,remove.monosnp=TRUE,  maf=NaN, missing.rate=NaN, num.thread=2, verbose=TRUE)

```

#Clustering Analysis
This step performs a clustering analysis similar to above but with a different equation.The next line creates a tree file based on dissimilarity rather than relatedness.
```{r}
snpHCluster =  snpgdsHCluster(dissMatrix, sample.id=NULL, need.mat=TRUE, hang=0.01)
cutTree = snpgdsCutTree(snpHCluster, z.threshold=15, outlier.n=5, n.perm = 5000, samp.group=NULL, 
                        col.outlier="red", col.list=NULL, pch.outlier=4, pch.list=NULL,label.H=FALSE, label.Z=TRUE, 
                        verbose=TRUE)
cutTree
snpgdsClose(genofile)
```

#Displaying a tree based on dissimilarity
Even though the tree is based on dissimilarity, the closest samples are still the most similar or to be more accurate, least dissimilar. 
```{r}
snpgdsDrawTree(cutTree, main = "Phylogenetic Tree",edgePar=list(col=rgb(0.5,0.5,0.5,0.75),t.col="black"),
               y.label.kinship=T,leaflab="perpendicular")
```

#Session Info
```{r}
sessionInfo()
```
