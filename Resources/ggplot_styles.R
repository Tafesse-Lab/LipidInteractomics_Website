################ Library Initialization ################

library(ggplot2)
library(ggrepel)
library(emojifont)
library(dplyr)
library(tidyr)
library(docstring)
library(clusterProfiler)
library(org.Hs.eg.db)
library(enrichplot)
library(igraph)
library(ggtangle)
library(stringr)

################ Helper Functions ################

safe_abs <- function(x, default = NA) {
  #' Performs some error handling in the event of NA in joined datasets -- intended to be used while finding the limits of ggplots, as in VolcanoPlotStandardized.
  #' Takes an input, tries to coerce it into a numeric, performs the abs() operation on it
  #' Returns an input default value so the user can use trial and error.
 
  tryCatch({
    # Ensures that x is numeric before taking abs()
    abs(as.numeric(x))
  }, error = function(e) {
    default
  })
}

safe_log10 <- function(x, default = NA) {
  #' Takes an input, tries to coerce it into a numeric, performs the  log10() operation on it
  #' Performs some error handling in the event of NA in joined datasets -- intended to be used while finding the limits of ggplots, as in VolcanoPlotStandardized.
  #' Returns an input default value so the user can use trial and error.
  
     tryCatch({
        # Ensures that x is numeric before taking log10()
        log10(as.numeric(x))
    }, error = function(e) {
        default
    })
}

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


################ Plotting Functions ################

MAStandard <- function(data) {

    ################
    #' A standardized MA plot function
    #' Receives a dataframe. Needs to have the following columns for the aes() to work: AveExpr, logFC, hit_annotation, gene_name.
    #' Dynamically determines the limits of the plot under the scale_x/y_scontinuous calls
    #' Produces first a facet-wrapped ggplot, then converts it to a plotly plot.
    ################

    MAPlots <- data |>
        ggplot(aes(x = AveExpr,
                   y = logFC,
                   color = factor(hit_annotation),
                   fill = factor(hit_annotation),
                   shape = factor(hit_annotation),
                   alpha = factor(hit_annotation),
                   size = factor(hit_annotation))) +
        geom_point(aes(text = paste0("Gene name: ", gene_name, "\n",
                                    "LogFC: ", logFC, "\n",
                                    "p-value: ", pvalue, "\n",
                                    "AveExper: ", AveExpr, "\n"))) +
        geom_hline(yintercept = 0, linetype = 2) +
        geom_vline(xintercept = 0, linetype = 2) +
        scale_x_continuous(limits = c(0.9 * min(abs(data$AveExpr)), 1.1 * max(abs(data$AveExpr))))+
        scale_y_continuous(limits = c(-1.1 * max(abs(data$logFC)), 1.1 * max(abs(data$logFC))))+
        scale_shape_manual(values = c("enriched hit" = 21,
                                    "hit" = 21,
                                    "enriched candidate" = 24,
                                    "candidate" = 24,
                                    "no hit" = 22), 
                        name = "Trend") +
        scale_color_manual(values = c("enriched hit" = "black",
                                    "hit" = "black",
                                    "enriched candidate" = "black",
                                    "candidate" = "black",
                                    "no hit" = "black"), 
                        name = "Trend") +
        scale_fill_manual(values = c("enriched hit" = "orange",
                                    "hit" = "orange",
                                    "enriched candidate" = "purple",
                                    "candidate" = "purple",
                                    "no hit" = "black"), 
                        name = "Trend") +
        scale_alpha_manual(values = c("enriched hit" = 0.8,
                                    "hit" = 0.8,
                                    "enriched candidate" = 0.5,
                                    "candidate" = 0.5,
                                    "no hit" = 0.25), 
                        name = "Trend") +
        scale_size_manual(values = c("enriched hit" = 4,
                                    "hit" = 4,
                                    "enriched candidate" = 2,
                                    "candidate" = 2, 
                                    "no hit" = 0.75), 
                        name = "Trend") +
        facet_wrap(~LipidProbe) +
        ylab("Log2 fold-change") +
        xlab("Average Ion Intensity") +
        theme_minimal() +
        theme(text = element_text(family = "serif")) +
        theme(panel.border = element_rect(color = NA, fill = NA)) +
        theme(legend.title = element_text(size = 12, face = "bold")) +
        theme(axis.title = element_text(size = 12, face = "bold")) +
        theme(legend.text = element_text(size = 12)) +
        theme(strip.text = element_text(
    size = 20))

    m <- list(l=50, r = 50, b= 100, pad = 4)
	
    MAPlotly <- ggplotly(MAPlots,
                            tooltip = c("text", dynamicTicks = TRUE),
                            hovermode = "closest",
                            autosize = T,
                            margin = m) |>
                    layout(showlegend = FALSE)
    
    return(MAPlotly)
}


# 

RankedOrderPlotStandard <- function(data) {
    ################
    #' A standardized Ranked Order plot theme
    #' Requires an input dataframe with the columns "gene_name", "LipidProbe", "logFC", "pvalue", and "hit_annotation"
    ################
    
    # First makes a ggplot template to later apply ggplotly
    RankedOrderPlots <- data |>
        ggplot(aes(x = ID,
                   y = logFC,
                   color = factor(hit_annotation),
                   fill = factor(hit_annotation),
                   shape = factor(hit_annotation),
                   alpha = factor(hit_annotation),
                   size = factor(hit_annotation))) +
        geom_point(aes(text = paste0("Gene name: ", gene_name, "\n",
                                    "LogFC: ", logFC, "\n",
                                    "p-value: ", pvalue, "\n"))) +
        geom_hline(yintercept = 0, linetype = 2) +
        geom_vline(xintercept = 0, linetype = 2) +
        scale_shape_manual(values = c("enriched hit" = 21,
                                    "hit" = 21,
                                    "enriched candidate" = 24,
                                    "candidate" = 24,
                                    "no hit" = 22), 
                        name = "Trend") +
        scale_color_manual(values = c("enriched hit" = "black",
                                    "hit" = "black",
                                    "enriched candidate" = "black",
                                    "candidate" = "black",
                                    "no hit" = "black"), 
                        name = "Trend") +
        scale_fill_manual(values = c("enriched hit" = "orange",
                                    "hit" = "orange",
                                    "enriched candidate" = "purple",
                                    "candidate" = "purple",
                                    "no hit" = "black"), 
                        name = "Trend") +
        scale_alpha_manual(values = c("enriched hit" = 0.8,
                                    "hit" = 0.8,
                                    "enriched candidate" = 0.5,
                                    "candidate" = 0.5,
                                    "no hit" = 0.25), 
                        name = "Trend") +
        scale_size_manual(values = c("enriched hit" = 4,
                                    "hit" = 4,
                                    "enriched candidate" = 2,
                                    "candidate" = 2, 
                                    "no hit" = 0.75), 
                        name = "Trend") +
        facet_wrap(~LipidProbe) +
        ylab("Log2 fold-change") +
        xlab("Ranked-order gene") +
        theme_minimal() +
        theme(text = element_text(family = "serif")) +
        theme(panel.border = element_rect(color = NA, fill = NA)) +
        theme(legend.title = element_text(size = 12, face = "bold")) +
        theme(axis.title = element_text(size = 12, face = "bold")) +
        theme(legend.text = element_text(size = 12))  +
        theme(strip.text = element_text(
    size = 20))

    m <- list(l=50, r = 50, b= 100, pad = 4)
	
    RankedOrderPlotly <- ggplotly(RankedOrderPlots,
                            tooltip = c("text", dynamicTicks = TRUE),
                            hovermode = "closest",
                            autosize = T,
                            margin = m) |>
                    layout(showlegend = FALSE)
    
    return(RankedOrderPlotly)
}

VolcanoPlotStandardized <- function(data) {

    ################
    #' A standardized Volcano plot theme
    #' Requires an input dataframe with the columns "gene_name", "LipidProbe", "logFC", "pvalue", and "hit_annotation"
    ################

    limits <- c(max(c(safe_abs(data$logFC), 4), na.rm=TRUE) , max(c(-safe_log10(data$pvalue), 8), na.rm=TRUE))


    VolcanoPlots <- data |>
        ggplot(aes(x = logFC,
                   y = -log10(pvalue),
                   color = factor(hit_annotation),
                   fill = factor(hit_annotation),
                   shape = factor(hit_annotation),
                   alpha = factor(hit_annotation),
                   size = factor(hit_annotation))) +
        geom_point(aes(text = paste0("Gene name: ", gene_name, "\n",
                                     "LogFC: ", logFC, "\n",
                                     "p-value: ", pvalue, "\n"))) +
        geom_hline(yintercept = 0, linetype = 2) +
        geom_vline(xintercept = 0, linetype = 2) +
        scale_x_continuous(limits=c(-1.1 * limits[1], 1.1* limits[1])) +
        scale_y_continuous(limits=c(0, 1.1 * limits[2])) +
        scale_shape_manual(values = c("enriched hit" = 21,
                                    "hit" = 21,
                                    "enriched candidate" = 24,
                                    "candidate" = 24,
                                    "no hit" = 22), 
                        name = "Trend") +
        scale_color_manual(values = c("enriched hit" = "black",
                                    "hit" = "black",
                                    "enriched candidate" = "black",
                                    "candidate" = "black",
                                    "no hit" = "black"), 
                        name = "Trend") +
        scale_fill_manual(values = c("enriched hit" = "orange",
                                    "hit" = "orange",
                                    "enriched candidate" = "purple",
                                    "candidate" = "purple",
                                    "no hit" = "black"), 
                        name = "Trend") +
        scale_alpha_manual(values = c("enriched hit" = 0.8,
                                    "hit" = 0.8,
                                    "enriched candidate" = 0.5,
                                    "candidate" = 0.5,
                                    "no hit" = 0.25), 
                        name = "Trend") +
        scale_size_manual(values = c("enriched hit" = 4,
                                    "hit" = 4,
                                    "enriched candidate" = 2,
                                    "candidate" = 2, 
                                    "no hit" = 0.75), 
                        name = "Trend") +
        facet_wrap(~LipidProbe, ncol = 2) +
        xlab("Log2 fold-change") +
        ylab("-log10(p-value)") +
        theme_minimal() +
        theme(text = element_text(family = "serif")) +
        theme(panel.border = element_rect(color = NA, fill = NA))+
        theme(strip.text = element_text(size = 12, face = "bold")) +
        theme(legend.title = element_text(size = 12, face = "bold")) +
        theme(axis.title = element_text(size = 12, face = "bold")) +
        theme(legend.text = element_text(size = 12))  +
        theme(strip.text = element_text(
    size = 20))

    
    m <- list(l=50, r = 50, b= 100, pad = 10)

    VolcanoPlotly <- ggplotly(VolcanoPlots,
                            tooltip = c("text", dynamicTicks = TRUE),
                            hovermode = "closest",
                            autosize = T,
                            margin = m) |>
                    layout(showlegend = FALSE)

    return(VolcanoPlotly)
}


CC_enrichment_plots <- function(data, plotReturnType){

	################
	#' Makes some GO enrichment plots of the Cellular Compartment
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
		cnet <- NULL

    try(
			# Makes the cnet plot
		cnet <- clusterProfiler::cnetplot(ego_results_Identification_CC, categorySize = "pvalue") +
		# ggtitle("Cellular compartment") +
		customPlot
    )

    if(!is.null(cnet)){
      cnet
    } else {
      return("Cnet plot failed in production.")
    }
    
	} else {
			# Makes the dot plot
			dot <- ggplot(data = ego_sub, aes(sample, Description)) +
				geom_point(aes(size = odds_ratio, colour = -log10(p.adjust))) +
				theme_bw(base_size = 12) +
				scale_colour_gradientn(colours = c("#377eb8", "#984ea3", "#e41a1c", "#ff7f00", "#ffff33"), ) +
				# ggtitle("Cellular compartment") +
				ylab("") +
				xlab("LipidProbe")
				theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust = 1))
			ggplotly(dot)
		}
	}
}



MF_enrichment_plots <- function(data, plotReturnType){

	################
	#' Makes some GO enrichment plots of the molecular function
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
	ego_results_Identification_MF <- NULL

	# Attempts to identify pathways in the dataset
	try(
		ego_results_Identification_MF <- clusterProfiler::compareCluster(ENTREZID ~ sample,
																			data = ego_Identification_data_enriched, fun = "enrichGO",
																			OrgDb = org.Hs.eg.db,
																			keyType = "ENTREZID",
																			ont = "MF",
																			readable = TRUE,
																			universe = ID_LUT$ENTREZID)
																			) 

	# If no pathway identified, returns text warning user.
	if (is.null(ego_results_Identification_MF)) {
		return("No pathways identified among enriched hits and candidates.")
	}

	# If pathways identified, produces both plots for viewing.
	if (!is.null(ego_results_Identification_MF))
		{
		ego_results_Identification_MF_table <- ego_results_Identification_MF@compareClusterResult
		ego_results_Identification_MF_table <- ego_results_Identification_MF_table %>% 
			group_by(ID, sample) %>%
			mutate(odds_ratio = calculateFE(GeneRatio, BgRatio))
		ego_results_Identification_MF_table$Description <- factor(ego_results_Identification_MF_table$Description, levels = unique(rev(ego_results_Identification_MF_table$Description)))

		ego_sub <- ego_results_Identification_MF_table %>% 
			group_by(sample) %>%
			slice_head(n = 10)
		
		

	
	if(plotReturnType == "cnet") {
    cnet <- NULL

    try(
			# Makes the cnet plot
		cnet <- clusterProfiler::cnetplot(ego_results_Identification_MF, categorySize = "pvalue") +
		# ggtitle("Cellular compartment") +
		customPlot
    )

    if(!is.null(cnet)){
      cnet
    } else {
      return("Cnet plot failed in production.")
    }

	} else {
			# Makes the dot plot
			dot <- ggplot(data = ego_sub, aes(sample, Description)) +
				geom_point(aes(size = odds_ratio, colour = -log10(p.adjust))) +
				theme_bw(base_size = 12) +
				scale_colour_gradientn(colours = c("#377eb8", "#984ea3", "#e41a1c", "#ff7f00", "#ffff33"), ) +
				# ggtitle("Cellular compartment") +
				ylab("") +
				xlab("LipidProbe")
				theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust = 1))
			ggplotly(dot)
		}
	}
}



BP_enrichment_plots <- function(data, plotReturnType){

	################
	#' Makes some GO enrichment plots of the biological process
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
	ego_results_Identification_BP <- NULL

	# Attempts to identify pathways in the dataset
	try(
		ego_results_Identification_BP <- clusterProfiler::compareCluster(ENTREZID ~ sample,
																			data = ego_Identification_data_enriched, fun = "enrichGO",
																			OrgDb = org.Hs.eg.db,
																			keyType = "ENTREZID",
																			ont = "BP",
																			readable = TRUE,
																			universe = ID_LUT$ENTREZID)
																			) 

	# If no pathway identified, returns text warning user.
	if (is.null(ego_results_Identification_BP)) {
		return("No pathways identified among enriched hits and candidates.")
	}

	# If pathways identified, produces both plots for viewing.
	if (!is.null(ego_results_Identification_BP))
		{
		ego_results_Identification_BP_table <- ego_results_Identification_BP@compareClusterResult
		ego_results_Identification_BP_table <- ego_results_Identification_BP_table %>% 
			group_by(ID, sample) %>%
			mutate(odds_ratio = calculateFE(GeneRatio, BgRatio))
		ego_results_Identification_BP_table$Description <- factor(ego_results_Identification_BP_table$Description, levels = unique(rev(ego_results_Identification_BP_table$Description)))

		ego_sub <- ego_results_Identification_BP_table %>% 
			group_by(sample) %>%
			slice_head(n = 10)
		
		

	
	if(plotReturnType == "cnet") {
		cnet <- NULL

    try(
			# Makes the cnet plot
		cnet <- clusterProfiler::cnetplot(ego_results_Identification_BP, categorySize = "pvalue") +
		# ggtitle("Cellular compartment") +
		customPlot
    )

    if(!is.null(cnet)){
      cnet
    } else {
      return("Cnet plot failed in production.")
    }
    
	} else {
			# Makes the dot plot
			dot <- ggplot(data = ego_sub, aes(sample, Description)) +
				geom_point(aes(size = odds_ratio, colour = -log10(p.adjust))) +
				theme_bw(base_size = 12) +
				scale_colour_gradientn(colours = c("#377eb8", "#984ea3", "#e41a1c", "#ff7f00", "#ffff33"), ) +
				# ggtitle("Cellular compartment") +
				ylab("") +
				xlab("LipidProbe")
				theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust = 1))
			ggplotly(dot)
		}
	}
}
