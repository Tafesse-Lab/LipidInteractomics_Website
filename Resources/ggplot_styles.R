# A centralized spot to save a custom theme across the whole site

library(ggplot2)
library(ggrepel)
library(emojifont)
library(dplyr)
library(tidyr)

# Define a helper function that safely applies abs()
safe_abs <- function(x, default = NA) {
  tryCatch({
    # Ensure that x is numeric before taking abs()
    abs(as.numeric(x))
  }, error = function(e) {
    default
  })
}

safe_log10 <- function(x, default = NA) {
    tryCatch({
        # Ensure that x is numeric before taking log10()
        log10(as.numeric(x))
    }, error = function(e) {
        default
    })
}

# A standardized MA plot function

MAStandard <- function(data) {

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
                                    "p-value: ", pvalue, "\n"))) +
        geom_hline(yintercept = 0, linetype = 2) +
        geom_vline(xintercept = 0, linetype = 2) +
        scale_x_continuous(limits=c(0.9 * min(abs(data$AveExpr)), 1.1* max(abs(data$AveExpr))))+
        scale_y_continuous(limits=c(-1.1 * max(abs(data$logFC)), 1.1* max(abs(data$logFC))))+
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


# A standardized Ranked Order plot theme

RankedOrderPlotStandard <- function(data) {
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

# A standardized Volcano plot theme

VolcanoPlotStandardized <- function(data) {

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
