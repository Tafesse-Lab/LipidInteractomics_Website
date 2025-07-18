library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(readr)
library(shiny)
library(here)
library(duckplyr)

## The plotting function

ProbeVSProbePlotter <- function(data, probe1Name, probe2Name) {

	## Prepares the linear regression overlaid on the plot

	lmData <- data |>
        filter(hit_annotation.x != "no id" & hit_annotation.y != "no id")
      
	lm_xvsy <- lm(formula = lmData$logFC.y ~ lmData$logFC.x)
	#print(summary(lm_xvsy))
	
	pStars <- if(summary(lm_xvsy)$coef[2, 4] < 0.0001){
		"****"
	}else{
		if(summary(lm_xvsy)$coef[2, 4] < 0.001){ 
			"***"
		}else{
			if(summary(lm_xvsy)$coef[2, 4] < 0.01){
				"**"
			}else{
				if(summary(lm_xvsy)$coef[2, 4] < 0.05){
					"*"
				}else(
					"ns"
				)
			}
		}
	}
      
      
	lmLabel <- ifelse(lm_xvsy$coef[[1]] > 0, paste0("\ny =", signif(lm_xvsy$coef[[2]], 3), "x + ", signif(lm_xvsy$coef[[1]], 3), "\n",
																									"Adj R^2 = ", signif(summary(lm_xvsy)$adj.r.squared, 5), "; ",
																									"p: ", pStars),
										paste0("\ny =", signif(lm_xvsy$coef[[2]], 3), "x - ", abs(signif(lm_xvsy$coef[[1]], 3)), "\n",
														"Adj R^2 = ", signif(summary(lm_xvsy)$adj.r.squared, 5)))
	

	limits <- max(abs(max(data$logFC.x, na.rm = TRUE)),
							abs(max(data$logFC.y, na.rm = TRUE)))

	ggplotter <- data |>
			ggplot(aes(x = logFC.x,
								 y = logFC.y,
								 color = factor(combined_hit_annotation),
								 fill = factor(combined_hit_annotation),
								 shape = factor(combined_hit_annotation),
								 size = factor(combined_hit_annotation),
								 alpha = factor(combined_hit_annotation))) +
			geom_point(aes(text = paste0("Gene name: ", gene_name))) +
			geom_hline(yintercept = 0, linetype = 2) +
			geom_vline(xintercept = 0, linetype = 2) +
			geom_abline(slope = signif(lm_xvsy$coef[[2]]), intercept = signif(lm_xvsy$coef[[1]]), color = "red", linetype = 2) +
			scale_x_continuous(limits= c(-1.1*limits, 1.1*limits)) +
			scale_y_continuous(limits= c(-1.1*limits, 1.1*limits)) +
			scale_shape_manual(values = c("enriched on neither axis" = 22, 
																		"enriched x-axis only" = 24,
																		"enriched y-axis only" = 24,
																		"enriched on both axes" = 21),
													name = "Statistical Annotation") +
			scale_fill_manual(values=c("enriched on neither axis" = "grey50", 
																	"enriched x-axis only" = "purple",
																	"enriched y-axis only" = "green",
																	"enriched on both axes" = "orange"),
												name = "Statistical Annotation") +
			scale_color_manual(values = c("enriched on neither axis" = "black", 
																		"enriched x-axis only" = "black",
																		"enriched y-axis only" = "black",
																		"enriched on both axes" = "black"),
													name = "Statistical Annotation") +
			scale_size_manual(values = c("enriched on neither axis" = 2, 
																		"enriched x-axis only" = 4,
																		"enriched y-axis only" = 4,
																		"enriched on both axes" = 4),
												name = "Statistical Annotation") +
			scale_alpha_manual(values = c("enriched on neither axis" = 0.25, 
																		"enriched x-axis only" = 0.75,
																		"enriched y-axis only" = 0.75,
																		"enriched on both axes" = 1),
													name = "Statistical Annotation") +								
			xlab(paste0("Log2 fold-change ", probe1Name)) +
			ylab(paste0("Log2 fold-change ", probe2Name)) +
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

	ggplotly <- plotly::ggplotly(ggplotter,
													tooltip = c("text", dynamicTicks = TRUE),
													hovermode = "closest",
													autosize = T,
													margin = m) |>
									layout(showlegend = FALSE) |>
									add_annotations(x = 0.05,
																	y = 0.95,
																	xref = "paper",
																	yref = "paper",
																	text = lmLabel,
																	showarrow = FALSE,
																	font = list(color = "red",
																							size = 12)
																)

	return(ggplotly)
}