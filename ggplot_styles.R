# A centralized spot to save a custom theme across the whole site

library(ggplot2)
library(ggrepel)
library(emojifont)
library(dplyr)
library(tidyr)

# A universal Volcano plot theme

VolcanoPlot <- function(data, enrichmentColumn, pvalueColumn, fillFactor, shapeFactor) {
	
	ggplot(data, aes(x = {{ enrichmentColumn }}, y = {{ pvalueColumn }}, color = "black", fill = {{fillFactor }}, shape = {{ shapeFactor }})) +
		geom_point() +
		labs( x = "Log2 fold-change",
			  y = "p-value")
}