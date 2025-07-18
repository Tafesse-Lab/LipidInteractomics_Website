library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(readr)
library(shiny)
library(duckplyr)

# Load plotting function source

# source("/Users/gaelenguzman/LipidInteractomics_Website_local/LipidInteractomics_Website/ShinyApps/CompareLipidProbes/PlottingFunction.R")

# # File path for testing
# df <- read_csv("/Users/gaelenguzman/LipidInteractomics_Website_local/LipidInteractomics_Website/ShinyApps/CompareLipidProbes/combinedProbeDatasets_TMT.csv") |>
#     mutate(probeOptions = paste0(LipidProbe, " - ", CellLine))



# File path for deploying to Shinyapps.io
source("PlottingFunction.R")
df <- read_csv("combinedProbeDatasets_TMT.csv") |>
   mutate(probeOptions = paste0(LipidProbe, " - ", CellLine))


probeOptions <- unique(df$probeOptions)



########################################################
# UI
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

########################################################
# Server
server <- function(input, output, session) {
	
	# Creating filtered datasets for the probes selected
	xData <- reactive({
		xData <- df |>
			filter(probeOptions == input$probe1) 
		return(xData)
	})

	yData <- reactive({
		yData <- df |>
			filter(probeOptions == input$probe2) 
		return(yData)
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

shinyApp(ui, server)

