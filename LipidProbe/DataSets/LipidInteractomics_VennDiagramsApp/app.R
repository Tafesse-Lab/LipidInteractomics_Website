library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(readr)
library(shiny)
library(amVennDiagram5)
library(ggVennDiagram)
library(VennDiagram)
library(ggvenn)

Venn_df <- read_csv("/Users/gaelenguzman/LipidInteractomics_Website_local/LipidInteractomics_Website/LipidProbe/DataSets/LipidInteractomics_VennDiagramsApp/combinedProbeDatasets_VennDiagram.csv")

probeOptions <- unique(Venn_df$LipidProbe)

# Shiny App
ui <- fluidPage(
  titlePanel("Interactive Venn Diagrams"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("probe1", "Select First Lipid Probe:", choices = probeOptions, selected = probeOptions[1]),
      selectInput("probe2", "Select Second Lipid Probe:", choices = probeOptions, selected = probeOptions[2]),
			fluidRow(actionButton(inputId = "PlotVenn", label = "Plot Venn Diagram")
			)
    ),
    mainPanel(
      plotOutput("VennDiagram")
    )
  )
)


server <- function(input, output, session) {
	Probe1Data <- reactive({
		Probe1Data <- Venn_df |>
			filter(LipidProbe == input$probe1)
		
		return(Probe1Data)
	})


	Probe2Data <- reactive({
		Probe2Data <- Venn_df |>
			filter(LipidProbe == input$probe2)
		
		return(Probe2Data)
	})	

	observeEvent(input$PlotVenn, {
		Probe1Data <- Probe1Data()
		Probe2Data <- Probe2Data()

		data <- list(Probe1 = Probe1Data$gene_name, 
						 Probe2 = Probe2Data$gene_name)

		renderPlot({
			vennTest<- ggvenn(data,
				fill_color = c("#0073C2FF", "#EFC000FF"),
				stroke_size = 0.5,
				set_name_size = 2)

			vennTest + coord_cartesian(clip="off")
			#ggplotly(vennTest)
		})
	})

}


shinyApp(ui, server)
