# A centralized spot to save a custom theme across the whole site

library(ggplot2)
library(ggrepel)
library(emojifont)
library(dplyr)
library(tidyr)

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
                                    "enriched candidate" = 24,
                                    "no hit" = 22), 
                        name = "Trend") +
        scale_color_manual(values = c("enriched hit" = "black",
                                    "enriched candidate" = "black",
                                    "no hit" = "black"), 
                        name = "Trend") +
        scale_fill_manual(values = c("enriched hit" = "orange",
                                    "enriched candidate" = "purple",
                                    "no hit" = "black"), 
                        name = "Trend") +
        scale_alpha_manual(values = c("enriched hit" = 0.8,
                                    "enriched candidate" = 0.5,
                                    "no hit" = 0.25), 
                        name = "Trend") +
        scale_size_manual(values = c("enriched hit" = 4,
                                    "enriched candidate" = 2,
                                    "no hit" = 0.75), 
                        name = "Trend") +
        facet_wrap(~LipidProbe) +
        ylab("Log2 fold-change") +
        xlab("Ranked-order gene") +
        theme_minimal() +
        theme(panel.border = element_rect(color = "#cfcfcf", fill = NA)) +
        theme(legend.title = element_text(size = 12, face = "bold")) +
        theme(axis.title = element_text(size = 12, face = "bold")) +
        theme(legend.text = element_text(size = 12))

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
        scale_x_continuous(limits=c(-1.1 * max(abs(AT_2025_Long$logFC)), 1.1* max(abs(AT_2025_Long$logFC)))) +
        scale_y_continuous(limits=c(0, max(-log10(AT_2025_Long$pvalue)))) +
        scale_shape_manual(values = c("enriched hit" = 21,
                                      "enriched candidate" = 24,
                                      "no hit" = 22), 
                           name = "Trend") +
        scale_color_manual(values = c("enriched hit" = "black",
                                     "enriched candidate" = "black",
                                     "no hit" = "black"), 
                           name = "Trend") +
        scale_fill_manual(values = c("enriched hit" = "orange",
                                    "enriched candidate" = "purple",
                                    "no hit" = "black"), 
                        name = "Trend") +
        scale_alpha_manual(values = c("enriched hit" = 0.8,
                                    "enriched candidate" = 0.5,
                                    "no hit" = 0.25), 
                        name = "Trend") +
        scale_size_manual(values = c("enriched hit" = 4,
                                    "enriched candidate" = 2,
                                    "no hit" = 0.75), 
                        name = "Trend") +
        facet_wrap(~LipidProbe) +
        xlab("Log2 fold-change") +
        ylab("-log10(p-value)") +
        theme_minimal() +
        theme(panel.border = element_rect(color = "#cfcfcf", fill = NA))+
        theme(strip.text = element_text(size = 12, face = "bold")) +
        theme(legend.title = element_text(size = 12, face = "bold")) +
        theme(axis.title = element_text(size = 12, face = "bold")) +
        theme(legend.text = element_text(size = 12))

    
    m <- list(l=50, r = 50, b= 100, pad = 10)

    VolcanoPlotly <- ggplotly(VolcanoPlots,
                            tooltip = c("text", dynamicTicks = TRUE),
                            hovermode = "closest",
                            autosize = T,
                            margin = m) |>
                    layout(showlegend = FALSE)

    return(VolcanoPlotly)
}
