library(here)
library(BiocManager)
library(limma)
library(GEOquery)
library(msigdbr)
library(fgsea)
library(clusterProfiler)
library(org.Hs.eg.db)
library(docstring)

## Opening the source file for the ggplot custom theme
source(paste0(here(), "/Resources/ggplot_styles.R"))



# install.packages("clusterProfiler")
# BiocManager::install(c("GenomicFeatures", "AnnotationDbi"))
# BiocManager::install("clusterProfiler")
# BiocManager::install("fgsea")
# BiocManager::install("limma")
# BiocManager::install("GEOquery")
BiocManager::install(c("org.Hs.eg.db"))

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

####################################################
# Modifying Frank's script to get GO outputs for genesets

library(clusterProfiler)
library(org.Hs.eg.db)
library(here)

calculateFE <- function(GeneRatio, BgRatio)
{
  GeneRatio <- as.numeric(unlist(str_split(GeneRatio, pattern = "/")))
  BgRatio <- as.numeric(unlist(str_split(BgRatio, pattern = "/")))
  odds_ratio <- (GeneRatio[1] / GeneRatio[2]) / (BgRatio[1] / BgRatio[2])
  return(odds_ratio)
}

customPlot <- list(
  theme_bw(base_size = 12), 
  scale_fill_brewer(palette = "Set1"), 
  scale_colour_brewer(palette = "Set1")
)

# Data extraction Doris's
DH_2017_data <- read.csv(paste0(here(),"/IndividualStudies/DataTables/DH_PNAS_2017_download.csv")) |>
  mutate(gene_name = str_extract(Description, "GN=([^\\s]+)") |> str_remove("GN=")) |>
  mutate(Species = str_extract(Description, "OS=([^=]+?)\\sGN=") |> str_remove("OS=") |> str_remove("GN=")) |>
  filter(Species == "Homo sapiens ") |>
  mutate(PSM_Sph = (PSM_Sph1 + PSM_Sph2) / 2,
         PSM_FA = (PSM_FA1 + PSM_FA2) / 2,
         PSM_DAG = (PSM_DAG1 + PSM_DAG2) /2) |>
  select(gene_name, PSM_Sph, PSM_FA, PSM_DAG) |>
  arrange(gene_name) |>
  group_by(gene_name) |>
  summarise(PSM_DAG = mean(PSM_DAG),
            PSM_FA = mean(PSM_FA),
            PSM_Sph = mean(PSM_Sph))


# Making lookup table with ENTREZID identifiers from data
ID_LUT <- clusterProfiler::bitr(geneID = DH_2017_data$gene_name, fromType = "SYMBOL", toType = "ENTREZID", OrgDb = org.Hs.eg.db)
names(ID_LUT) <- c("gene_name", "ENTREZID")

glimpse(ID_LUT)

# Merging ENTREZIDs to data
DH_2017_data <- left_join(DH_2017_data, ID_LUT)


ego_Identification_data <- DH_2017_data %>%
	pivot_longer(cols = starts_with("PSM_"),
								values_to = "PSM_count",
								names_to = "sample",
								names_pattern = "PSM_?(.*)") |>
  dplyr::select(ENTREZID, sample) %>%
	filter(sample == "Sph" | sample == "DAG") |>
  unique() |>
	glimpse()


# Data extraction Alix's

AT_2025_Long <- readr::read_csv(paste0(here(),"/IndividualStudies/DataTables/AT_ChemicalCommunications_2025_download.csv")) 

# Making lookup table with ENTREZID identifiers from data
ID_LUT <- clusterProfiler::bitr(geneID = AT_2025_Long$gene_name, fromType = "SYMBOL", toType = "ENTREZID", OrgDb = org.Hs.eg.db)
names(ID_LUT) <- c("gene_name", "ENTREZID")

glimpse(ID_LUT)

# Merging ENTREZIDs to data
AT_2025_Long <- left_join(AT_2025_Long, ID_LUT)

ego_Identification_data <- AT_2025_Long %>%
	mutate(sample = LipidProbe) |>
  dplyr::select(ENTREZID, sample, hit_annotation) %>%
  unique() |>
	glimpse()

ego_Identification_data_enriched <- ego_Identification_data |>
	filter((hit_annotation == "enriched candidate" | hit_annotation == "enriched hit"))

ego_results_Identification_CC <- NULL

try(
	ego_results_Identification_CC <- clusterProfiler::compareCluster(ENTREZID ~ sample,
                                    data = ego_Identification_data_enriched, fun = "enrichGO",
                                    OrgDb = org.Hs.eg.db,
                                    keyType = "ENTREZID",
                                    ont = "CC",
                                    readable = TRUE,
                                    universe = ID_LUT$ENTREZID)
																		)

if (!is.null(ego_results_Identification_CC))
{
  ego_results_Identification_CC_table <- ego_results_Identification_CC@compareClusterResult
  ego_results_Identification_CC_table <- ego_results_Identification_CC_table %>% 
    group_by(ID, sample) %>%
    mutate(odds_ratio = calculateFE(GeneRatio, BgRatio))
  ego_results_Identification_CC_table$Description <- factor(ego_results_Identification_CC_table$Description, levels = unique(rev(ego_results_Identification_CC_table$Description)))
  #write.csv(ego_results_Identification_CC_table, file.path(dir_save, paste0("GO_enrichment_Identification_CC_limma_results_", script.version, ".csv")), row.names = FALSE)
  ego_sub <- ego_results_Identification_CC_table %>% 
    group_by(sample) %>%
    slice_head(n = 10)
  ggplot(data = ego_sub, aes(sample, Description)) +
    geom_point(aes(size = odds_ratio, colour = -log10(p.adjust))) +
    theme_bw(base_size = 12) +
    scale_colour_gradientn(colours = c("#377eb8", "#984ea3", "#e41a1c", "#ff7f00", "#ffff33")) +
    ggtitle("Cellular compartment") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
  # ggsave(file.path(dir_save, paste0("GO_enrichment_Identification_CC_dotplot_", script.version, ".pdf")), 
  #        width = max(nchar(as.character(ego_sub$Description))) * 0.06 + length(unique(ego_sub$sample)) * 0.5 + 3,
  #        height = length(unique(ego_sub$Description)) * 0.12 + 4)
 clusterProfiler::cnetplot(ego_results_Identification_CC, categorySize = "pvalue") +
   ggtitle("Cellular compartment") +
   customPlot
#  ggsave(file.path(dir_save, paste0("GO_enrichment_Identification_CC_cnetplot_", script.version, ".pdf")), 
#         width = 15, height = 15)
}

ggplotly()
library(clusterProfiler)
library(enrichplot)
library(igraph)
library(ggtangle)
?clusterProfiler::geom_cnet_label()

data <- AT_2025_Long

CellCompartment_enrichment_plots <- function(data, plotReturnType){

	################
	#' Makes some GO enrichment plots of the cellular compartment
	#' data must have at least the columns "gene_name", "LipidProbe" and "hit_annotation"
	#' User must select either a dotplot or a cnet plot to return
	#' Selects only the proteins which are "enriched candidate" and "enriched hit" and seeks the enriched pathways among them.
	#' If no pathways enriched, returns a text response to put in the output box
	#' Basically uses Frank's analysis pipeline to make these plots fresh on each call.
	################

	# Making lookup table with ENTREZID identifiers from data
	ID_LUT <- clusterProfiler::bitr(geneID = data$gene_name, fromType = "SYMBOL", toType = "ENTREZID", OrgDb = org.Hs.eg.db)
	names(ID_LUT) <- c("gene_name", "ENTREZID")

	# Merging ENTREZIDs to data
	data <- left_join(data, ID_LUT)

	ego_Identification_data <- data %>%
	mutate(sample = LipidProbe) |>
  dplyr::select(ENTREZID, sample, hit_annotation) %>%
  unique()

	ego_Identification_data_enriched <- ego_Identification_data |>
	filter((hit_annotation == "enriched candidate" | hit_annotation == "enriched hit"))

	# Initializes a ego results vector as NULL in the event that no pathways get identified
	ego_results_Identification_CC <- NULL

	# Attempts to identify pathways in the dataset
	try(
		ego_results_Identification_CC <- clusterProfiler::compareCluster(ENTREZID ~ sample,
																			data = ego_Identification_data_enriched, fun = "enrichGO",
																			OrgDb = org.Hs.eg.db,
																			keyType = "ENTREZID",
																			ont = "CC",
																			readable = TRUE,
																			universe = ID_LUT$ENTREZID)
																			) 

	# If no pathway identified, returns text warning user.
	if (is.null(ego_results_Identification_CC)) {
		return("No pathways identified among enriched hits and candidates.")
	}

	# If pathways identified, produces both plots for viewing.
	if (!is.null(ego_results_Identification_CC))
		{
		ego_results_Identification_CC_table <- ego_results_Identification_CC@compareClusterResult
		ego_results_Identification_CC_table <- ego_results_Identification_CC_table %>% 
			group_by(ID, sample) %>%
			mutate(odds_ratio = calculateFE(GeneRatio, BgRatio))
		ego_results_Identification_CC_table$Description <- factor(ego_results_Identification_CC_table$Description, levels = unique(rev(ego_results_Identification_CC_table$Description)))

		ego_sub <- ego_results_Identification_CC_table %>% 
			group_by(sample) %>%
			slice_head(n = 10)
		
		

	
	if(plotReturnType == "cnet") {
			# Makes the cnet plot
		cnet <- clusterProfiler::cnetplot(ego_results_Identification_CC, categorySize = "pvalue") +
		ggtitle("Cellular compartment") +
		customPlot

		cnet
	} else {
			# Makes the dot plot
			dot <- ggplot(data = ego_sub, aes(sample, Description)) +
				geom_point(aes(size = odds_ratio, colour = -log10(p.adjust))) +
				theme_bw(base_size = 12) +
				scale_colour_gradientn(colours = c("#377eb8", "#984ea3", "#e41a1c", "#ff7f00", "#ffff33"), ) +
				ggtitle("Cellular compartment") +
				ylab("") +
				xlab("LipidProbe")
				theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust = 1))
			ggplotly(dot)
		}
	}
}

CellCompartment_enrichment_plots(AT_2025_Long, "cnet")
CellCompartment_enrichment_plots(AT_2025_Long, "dot")

