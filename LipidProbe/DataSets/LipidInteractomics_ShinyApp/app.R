library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(readr)
library(shiny)
library(amVennDiagram5)

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
      plotlyOutput("logFCPlot")
    )
  )
)

server <- function(input, output, session) {
	
	xData <- reactive({
		xData<- df |>
			filter(LipidProbe == input$probe1) 
		return(xData)
	})

	yData <- reactive({
		yData<- df |>
			filter(LipidProbe == input$probe2) 
		return(yData)
	})

  output$logFCPlot <- renderPlotly({
		probe1Name <- input$probe1
		probe2Name <- input$probe2

		# Create a new dataframe for plotting
		xData <- xData()
		yData <- yData()

		plot_data <- merge(xData, yData, by="gene_name") |>
			mutate(combined_hit_annotation = case_when(hit_annotation.x == "enriched hit" & hit_annotation.y == "enriched hit" ~ "enriched on both axes",
                                                   hit_annotation.x != "enriched hit" & hit_annotation.y == "enriched hit" ~ "enriched y-axis only",
                                                   hit_annotation.x == "enriched hit" & hit_annotation.y != "enriched hit" ~ "enriched x-axis only",
                                                   .default = "enriched on neither axis")) |>
        mutate_if(is.numeric, ~replace(., is.na(.), 0)) |>
        mutate_if(is.character, ~replace(., is.na(.), "no id")) |>
				arrange(combined_hit_annotation) |>
				glimpse()

		print(head(plot_data))

		plot_data$combined_hit_annotation <- factor(pull(plot_data, combined_hit_annotation),
                                                     levels = c("enriched on both axes",
                                                                "enriched x-axis only",
                                                                "enriched y-axis only",
                                                                "enriched on neither axis"),
                                                     ordered = TRUE) 

		ProbeVSProbePlotter(plot_data, probe1Name, probe2Name)
    
  })
}


## The plotting function

ProbeVSProbePlotter <- function(data, probe1Name, probe2Name) {
	

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
									layout(showlegend = FALSE)

	return(ggplotly)
}


shinyApp(ui, server)
