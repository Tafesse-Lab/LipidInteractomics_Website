
## intitialize libraries
library(dplyr)
library(tidyr)
library(plotly)
library(ggplot2)
library(grid)
library(readr)
library(rmarkdown)
library(emojifont)
library(gt)
library(crosstalk)
library(DT)
library(stringr)
library(pheatmap)
library(here)
library(heatmaply)
library(ggvenn)
library(scales)
library(shiny)

## Opening the source file for the ggplot custom theme
source(paste0(here(), "/Resources/ggplot_styles.R"))

DH_2017_data <- read.csv(paste0(here(),"/IndividualStudies/DataTables/DH_PNAS_2017_download.csv")) |>
  mutate(gene_name = str_extract(Description, "GN=([^\\s]+)") |> str_remove("GN=")) |>
  mutate(Species = str_extract(Description, "OS=([^=]+?)\\sGN=") |> str_remove("OS=") |> str_remove("GN=")) |>
  filter(Species == "Homo sapiens ") |>
  mutate(PSM_Sph = (PSM_Sph1 + PSM_Sph2) / 2,
         PSM_FA = (PSM_FA1 + PSM_FA2) / 2,
         PSM_DAG = (PSM_DAG1 + PSM_DAG2) /2) |>
  select(gene_name, PSM_Sph, PSM_FA, PSM_DAG) |>
  arrange(gene_name) |>
  group_by(gene_name) |>
  summarise(PSM_DAG = mean(PSM_DAG),
            PSM_FA = mean(PSM_FA),
            PSM_Sph = mean(PSM_Sph))

	
# Ensure the data is in the correct format
DH_2017_data_AddingRownames <- as.data.frame(DH_2017_data)
rownames(DH_2017_data_AddingRownames) <- DH_2017_data_AddingRownames[,1]
DH_2017_data_AddingRownames[,1] <- NULL

Sph_proteins <- DH_2017_data_AddingRownames |>
  filter(PSM_Sph > 0) |>
  select(PSM_Sph)

FA_proteins <- DH_2017_data_AddingRownames |>
  filter(PSM_FA > 0) |>
  select(PSM_FA)

DAG_proteins <- DH_2017_data_AddingRownames |>
  filter(PSM_DAG > 0) |>
  select(PSM_DAG)


combined_venn_proteins <- list("Sph proteins" = rownames(Sph_proteins), "FA proteins" = rownames(FA_proteins), "DAG proteins" = rownames(DAG_proteins))



# Compute the regions (using set operations):
Sphonly <- setdiff(rownames(Sph_proteins), union(rownames(FA_proteins), rownames(DAG_proteins)))
DAGonly <- setdiff(rownames(DAG_proteins), union(rownames(FA_proteins), rownames(Sph_proteins)))
FAonly <- setdiff(rownames(FA_proteins), union(rownames(DAG_proteins), rownames(Sph_proteins)))
SphDAG <- setdiff(intersect(rownames(DAG_proteins), rownames(Sph_proteins)), rownames(FA_proteins))
SphFA <- setdiff(intersect(rownames(FA_proteins), rownames(Sph_proteins)), rownames(DAG_proteins))
DAGFA <- setdiff(intersect(rownames(FA_proteins), rownames(DAG_proteins)), rownames(Sph_proteins))
SphDAGFA <- intersect(intersect(rownames(FA_proteins), rownames(DAG_proteins)), rownames(Sph_proteins))

# Create a data frame for the regions with approximate positions.
regions <- data.frame(
  region = c("Only Sph", "Only DAG", "Only FA", "Sph & DAG only", "Sph & FA only", "DAG & FA only", "Sph & DAG & FA"),
  x = c(-1, 1, 0, 0, -0.5, 0.5, 0),
  y = c(1, 1, -1, 1, 0, 0, 0),
  count = c(length(Sphonly), length(DAGonly), length(FAonly),
            length(SphDAG), length(SphFA), length(DAGFA), length(SphDAGFA))
)

# Create a list mapping each region to its gene set.
region_genes <- list(
  "Only Sph"       = Sphonly,
  "Only DAG"       = DAGonly,
  "Only FA"       = FAonly,
  "Sph & DAG only"   = SphDAG,
  "Sph & FA only"   = SphFA,
  "DAG & FA only"   = DAGFA,
  "Sph & DAG & FA"    = SphDAGFA
)

ui <- fluidPage(
  titlePanel("Interactive Venn Diagram Dashboard"),
  fluidRow(
    column(6,
           # Plotly output for the Venn diagram
           plotlyOutput("vennPlot")
    ),
    column(6,
           # Data table for gene details
           DTOutput("geneTable")
    )
  )
)

server <- function(input, output, session) {

  output$vennPlot <- renderPlotly({
    
      ggvenn <- ggvenn(combined_venn_proteins,
                      show_percentage = FALSE,
                      show_elements = FALSE,
                      fill_color = c("orange", "purple", "blue")) +
        labs(title = "Venn Diagram of Gene Sets") +
        theme_minimal()

      p <- ggplotly(ggven, source = "venn")
      p <- event_register(p, "plotly_click")
      p

  })
  
  # Create a reactive value to store the selected region.
  selectedRegion <- reactiveVal(NULL)
  
  # # When a point in the Venn diagram is clicked, update selectedRegion.
  # observeEvent(event_data("plotly_click", source = "venn"), {
  #   clickData <- event_data("plotly_click", source = "venn")
  #   if (!is.null(clickData)) {
  #     # Use the text field (e.g., "Only A (3)") to extract the region name.
  #     regionClicked <- clickData$text
  #     # Remove the count part (everything from the first space).
  #     regionName <- sub(" \\(.*", "", regionClicked)
  #     selectedRegion(regionName)
  #   }
  # })

  # Listen for clicks.
  observeEvent(event_data("plotly_click", source = "venn"), {
    clickData <- event_data("plotly_click", source = "venn")
    print(clickData)  # Inspect clickData in the console.
    if(!is.null(clickData)) {
      # Use the x and y coordinates from the click event.
      reg <- get_region_label(clickData$x, clickData$y)
      if(!is.na(reg)) {
        selectedRegion(reg)
      } else {
        selectedRegion(NULL)
      }
    } else {
      selectedRegion(NULL)
    }
  })
  
  # Render the gene table.
  output$geneTable <- renderDT({
    req(selectedRegion())
    genes <- region_mapping[[selectedRegion()]]
    if(length(genes) == 0) {
      dat <- data.frame(Message = "No genes in this region")
    } else {
      dat <- data.frame(Gene = genes)
    }
    datatable(dat, options = list(pageLength = 5))
  })
}

shinyApp(ui, server)



get_region_label <- function(x, y) {
  # These boundaries are just examples and will need to be adjusted
  # based on your ggvenn layout. You can print out a few click events
  # to determine approximate boundaries.
  
  # For instance, suppose:
  # - "Sph only" is roughly where x < -0.6 and y > 0.5
  # - "FA only" is roughly where x > 0.6 and y > 0.5
  # - "DAG only" is roughly where y < -0.5
  # - "Sph & FA" is roughly around (x near 0, y near 0.5)
  # - "Sph & DAG" is roughly where x < -0.3 and y < 0
  # - "FA & DAG" is roughly where x > 0.3 and y < 0
  # - "Sph, FA & DAG" is roughly around the center (x near 0, y near 0)
  
  if(x < -0.6 && y > 0.5) {
    return("Sph only")
  } else if(x > 0.6 && y > 0.5) {
    return("FA only")
  } else if(y < -0.5) {
    return("DAG only")
  } else if(abs(x) < 0.3 && abs(y) < 0.3) {
    return("Sph, FA & DAG")
  } else if(x < 0 && y > 0 && y < 0.5) {
    return("Sph & FA")
  } else if(x < 0 && y < 0 && y > -0.5) {
    return("Sph & DAG")
  } else if(x > 0 && y < 0 && y > -0.5) {
    return("FA & DAG")
  } else {
    return(NA)
  }
}