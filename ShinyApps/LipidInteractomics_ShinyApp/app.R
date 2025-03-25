library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(readr)
library(shiny)
library(here)

# File path for testing
#df <- read_csv(paste0(here(), "/ShinyApps/LipidInteractomics_ShinyApp/combinedProbeDatasets_TMT.csv"))

# File path for deploying to Shinyapps.io
df <- read_csv("combinedProbeDatasets_TMT.csv")

probeOptions <- unique(df$LipidProbe)

# Shiny App
ui <- fluidPage(
  titlePanel("Interactive LogFC Comparison"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("probe1", "Select First LipidProbe:", choices = probeOptions, selected = probeOptions[1]),
      selectInput("probe2", "Select Second LipidProbe:", choices = probeOptions, selected = probeOptions[2])
    ),
    mainPanel(
      plotlyOutput("logFCPlot"),

    )
  )
)

server <- function(input, output, session) {
	
	# Creating filtered datasets for the probes selected
	xData <- reactive({
		xData <- df |>
			filter(LipidProbe == input$probe1) 
		return(xData)
	})

	yData <- reactive({
		yData <- df |>
			filter(LipidProbe == input$probe2) 
		return(yData)
	})

	zData <- reactive({
		zData <- df |>
			filter(LipidProbe == input$probe3) 
		return(zData)
	})

	# The output call for making the plot - includes some data wrangling to make sure the selected probes are handled properly. A
	## Also makes the linear regression line to add to the plot.
  output$logFCPlot <- renderPlotly({

		# Isolating the probes selected by the user
		probe1Name <- input$probe1
		probe2Name <- input$probe2

		# Create a new dataframe for plotting
		xData <- xData()
		yData <- yData()
    
		# handles the NAs by placing them on the appropriate axes.
		plot_data <- full_join(xData,yData,by="gene_name") |>
			mutate(logFC.x=if_else(is.na(logFC.x),0,logFC.x))|>
			mutate(logFC.y=if_else(is.na(logFC.y),0,logFC.y)) |>
			mutate(hit_annotation.x=if_else(is.na(hit_annotation.x),"no hit",hit_annotation.x)) |>
			mutate(hit_annotation.y=if_else(is.na(hit_annotation.y),"no hit",hit_annotation.y)) |>
			mutate(combined_hit_annotation = case_when(hit_annotation.x == "enriched hit" & hit_annotation.y == "enriched hit" ~ "enriched on both axes",
                                                   hit_annotation.x != "enriched hit" & hit_annotation.y == "enriched hit" ~ "enriched y-axis only",
                                                   hit_annotation.x == "enriched hit" & hit_annotation.y != "enriched hit" ~ "enriched x-axis only",
                                                   .default = "enriched on neither axis")) |>
        mutate_if(is.numeric, ~replace(., is.na(.), 0)) |>
        mutate_if(is.character, ~replace(., is.na(.), "no id")) |>
				arrange(combined_hit_annotation)

		plot_data$combined_hit_annotation <- factor(pull(plot_data, combined_hit_annotation),
                                                     levels = c("enriched on both axes",
                                                                "enriched x-axis only",
                                                                "enriched y-axis only",
                                                                "enriched on neither axis"),
                                                     ordered = TRUE) 

		ProbeVSProbePlotter(plot_data, probe1Name, probe2Name)
    
  })

	output$logFCPlot3dDemo <- renderPlotly({

		# Isolating the probes selected by the user
		probe1Name <- input$probe1
		probe2Name <- input$probe2
		probe3Name <- input$probe3

		# Create a new dataframe for plotting
		xData <- xData()
		yData <- yData()
		zData <- zData()
    
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


		# Corrected opacity mapping (now properly ordered)
		plot_data$opacity <- case_when(
			plot_data$combined_hit_annotation == "enriched on all axes" ~ 0.25,
			plot_data$combined_hit_annotation %in% c("enriched on x- and y- axes", "enriched on x- and z- axes", "enriched on y- and z- axes") ~ 0.5,
			plot_data$combined_hit_annotation %in% c("enriched x-axis only", "enriched y-axis only", "enriched z-axis only") ~ 0.75,
			plot_data$combined_hit_annotation == "enriched on no axes" ~ 1.0,
			TRUE ~ 0.75 # Default case
		)
		# Define color mapping similar to ggplot
		color_mapping <- c(
			"enriched on all axes" = "orange",
			"enriched on x- and y- axes" = "purple",
			"enriched on x- and z- axes" = "blue",
			"enriched on y- and z- axes" = "green",
			"enriched x-axis only" = "red",
			"enriched y-axis only" = "cyan",
			"enriched z-axis only" = "magenta",
			"enriched on no axes" = "gray75"
		)

		# Create 3D scatter plot
		plot_ly(
			data = plot_data,
			x = ~logFC.x, y = ~logFC.y, z = ~logFC.z,
			color = ~combined_hit_annotation,
			colors = color_mapping,
			type = "scatter3d", mode = "markers",
			marker = list(
				size = 5
			),
			opacity = ~opacity,
			text = ~paste("Gene:", gene_name, "<br>",
										probe1Name, "logFC:", round(logFC.x, 2), "<br>",
										probe2Name, "logFC", round(logFC.y, 2), "<br>",
										probe3Name, "logFC:", round(logFC.z, 2)),
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
  })
}


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


shinyApp(ui, server)

