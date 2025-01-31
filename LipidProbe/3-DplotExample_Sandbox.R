library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(readr)
library(shiny)

df <- read_csv("LipidProbe/DataSets/LipidInteractomics_ShinyApp/combinedProbeDatasets_TMT.csv")


probeOptions <- unique(df$LipidProbe)



ProbeVSProbePlotter <- function(data, probe1Name, probe2Name, probe3Name) {

	

	limits <- max(abs(max(data$logFC.x, na.rm = TRUE)),
							abs(max(data$logFC.y, na.rm = TRUE)),
							abs(max(data$logFC.z, na.rm = TRUE)))

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


# Isolating the probes selected by the user
probe1Name <- probeOptions[1]
probe2Name <- probeOptions[3]
probe3Name <- probeOptions[5]

# Create a new dataframe for plotting
xData <- df |>
			filter(LipidProbe == probe1Name) 
yData <- df |>
			filter(LipidProbe == probe2Name) 
zData <- df |>
			filter(LipidProbe == probe3Name)

# handles the NAs by placing them on the appropriate axes.
plot_data <- xData |> 
	full_join(yData, by="gene_name") |>
	full_join(zData, by="gene_name") |>
	mutate(logFC.z = logFC,
				 hit_annotation.z = hit_annotation) |>
	mutate(logFC.x = if_else(is.na(logFC.x), 0, logFC.x)) |>
	mutate(logFC.y = if_else(is.na(logFC.y), 0, logFC.y)) |>
	mutate(logFC.z = if_else(is.na(logFC.z), 0, logFC.z)) |>
	mutate(hit_annotation.x=if_else(is.na(hit_annotation.x),"no hit",hit_annotation.x)) |>
	mutate(hit_annotation.y=if_else(is.na(hit_annotation.y),"no hit",hit_annotation.y)) |>
	mutate(hit_annotation.z=if_else(is.na(hit_annotation.z),"no hit",hit_annotation.z)) |>
	mutate(combined_hit_annotation = case_when(hit_annotation.x == "enriched hit" & hit_annotation.y == "enriched hit" ~ "enriched on x- and y- axes",
	
																								hit_annotation.x == "enriched hit" & hit_annotation.y == "enriched hit" & hit_annotation.z != "enriched hit" ~ "enriched on x- and y- axes",
																								hit_annotation.x == "enriched hit" & hit_annotation.y != "enriched hit" & hit_annotation.z == "enriched hit" ~ "enriched on x- and z- axes",
																								hit_annotation.x != "enriched hit" & hit_annotation.y == "enriched hit" & hit_annotation.z == "enriched hit" ~ "enriched on y- and z- axes",
																								hit_annotation.x != "enriched hit" & hit_annotation.y == "enriched hit" & hit_annotation.z != "enriched hit" ~ "enriched y-axis only",
																								hit_annotation.x == "enriched hit" & hit_annotation.y != "enriched hit" & hit_annotation.z != "enriched hit" ~ "enriched x-axis only",
																								hit_annotation.x != "enriched hit" & hit_annotation.y != "enriched hit" & hit_annotation.z == "enriched hit" ~ "enriched z-axis only",
																								hit_annotation.x == "enriched hit" & hit_annotation.y == "enriched hit" & hit_annotation.z == "enriched hit" ~ "enriched on all axes",
																								.default = "enriched on no axes")) |>
		mutate_if(is.numeric, ~replace(., is.na(.), 0)) |>
		mutate_if(is.character, ~replace(., is.na(.), "no id")) |>
		arrange(combined_hit_annotation)

plot_data$combined_hit_annotation <- factor(pull(plot_data, combined_hit_annotation),
																									levels = c("enriched on all axes",
																														"enriched on x- and y- axes",
																														"enriched on x- and z- axes",
																														"enriched on y- and z- axes",
																														"enriched x-axis only",
																														"enriched y-axis only",
																														"enriched z-axis only",
																														"enriched on no axes"),
																									ordered = TRUE) 


unique(plot_data$combined_hit_annotation)


plot_ly(
      plot_data, x = ~logFC.x, y = ~logFC.y, z = ~logFC.z,
      color = ~combined_hit_annotation, 
      colors = c("red", "blue", "green", "purple", "orange", "cyan", "magenta", "gray"),
      type = "scatter3d", mode = "markers",
      marker = list(size = 5, opacity = 0.8),
			text = ~paste("Gene:", gene_name, "<br>", probe1Name, "logFC:", round(logFC.x, 2), "<br>", probe2Name, "logFC", round(logFC.y, 2), "<br>", probe3Name, "logFC:", round(logFC.z, 2)), 
      hoverinfo = "text"
			) %>%
      layout(
        scene = list(
          xaxis = list(title = probe1Name),
          yaxis = list(title = probe2Name),
          zaxis = list(title = probe3Name)
        ),
        legend = list(title = list(text = "Hit Annotation"))
      )

# Scatter plot
fig <- plot_ly(
  data = plot_data,
  x = ~logFC.x, y = ~logFC.y, z = ~logFC.z,
  color = ~combined_hit_annotation, 
  colors = c("red", "blue", "green", "purple", "orange", "cyan", "magenta", "gray"),
  type = "scatter3d", mode = "markers",
  marker = list(size = 5, opacity = 0.8),
  text = ~paste("Gene:", gene_name, "<br>", probe1Name, "logFC:", round(logFC.x, 2), "<br>", probe2Name, "logFC", round(logFC.y, 2), "<br>", probe3Name, "logFC:", round(logFC.z, 2)),  
  hoverinfo = "text"
)
