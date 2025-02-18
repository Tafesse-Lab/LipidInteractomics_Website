library(BiocManager)
library(limma)
library(GEOquery)
library(msigdbr)
library(fgsea)
library(clusterProfiler)

# install.packages("clusterProfiler")
# BiocManager::install(c("GenomicFeatures", "AnnotationDbi"))
# BiocManager::install("clusterProfiler")
# BiocManager::install("fgsea")
# BiocManager::install("limma")
# BiocManager::install("GEOquery")


gse200250 <- getGEO("GSE200250", AnnotGPL = TRUE)[[1]]

es <- gse200250
es <- es[, grep("Th2_", es$title)]
es$time <- as.numeric(gsub(" hours", "", es$`time point:ch1`))
es <- es[, order(es$time)]

exprs(es) <- normalizeBetweenArrays(log2(exprs(es)), method="quantile")

es <- es[order(rowMeans(exprs(es)), decreasing=TRUE), ]
es <- es[!duplicated(fData(es)$`Gene ID`), ]
rownames(es) <- fData(es)$`Gene ID`
es <- es[!grepl("///", rownames(es)), ]
es <- es[rownames(es) != "", ]

fData(es) <- fData(es)[, c("ID", "Gene ID", "Gene symbol")]

head(fData(es))

es <- es[head(order(rowMeans(exprs(es)), decreasing=TRUE), 12000), ]

head(exprs(es))

pathwaysDF <- msigdbr("mouse", category="H")
pathways <- split(as.character(pathwaysDF$entrez_gene), pathwaysDF$gs_name)
head(pathways)

set.seed(1)
gesecaRes <- geseca(pathways, exprs(es), minSize = 15, maxSize = 500)

head(gesecaRes, 10)


