####################
# Data wrangling script for AT_2025

####################

# loading packages from source styles script
library(here)
here()
## Opening the source file for the ggplot custom theme
source(here::here("LipidInteractomics_Website/Resources/ggplot_styles.R"))

############################################################

# Membrane dataset first

dataRaw <- readr::read_csv(here(
  "LipidInteractomics_Website/IndividualStudies/DataTables/DataWrangling/AT_ChemComm2025_membrane.csv"
))

MembraneData <- dataRaw |>
  mutate(
    gene_name = Gene,
    protein_id = Protein.ID,
    hit_annotation = case_when(
      hit_annotation == "hit" & logFC < 0 ~ "no hit",
      hit_annotation == "candidate" & logFC < 0 ~ "no hit",
      .default = hit_annotation
    ),
    LipidProbe = case_when(
      comparison.label == "PE_UV vs PE_NoUV" ~ "PE",
      comparison.label == "PA_UV vs PA_NoUV" ~ "PA"
    )
  ) |>
  dplyr::select(
    gene_name,
    protein_id,
    Protein.Description,
    LipidProbe,
    sample,
    logFC,
    AveExpr,
    pvalue,
    hit_annotation,
    -Gene,
    -Protein.ID,
    -comparison.label
  ) |>
  arrange(hit_annotation) |>
  glimpse()

# write_csv(data, here("IndividualStudies/DataTables/AT_ChemicalCommunications_2025_membrane_download.csv"))

PA_data <- MembraneData |>
  filter(LipidProbe == "PA")
write_csv(
  PA_data,
  here(
    "LipidInteractomics_Website/LipidProbe/DataSets/PA_membrane_HeLa_AT_2025.csv"
  )
)

PE_data <- MembraneData |>
  filter(LipidProbe == "PE")
write_csv(
  PE_data,
  here(
    "LipidInteractomics_Website/LipidProbe/DataSets/PE_membrane_HeLa_AT_2025.csv"
  )
)


# Cytosol dataset second
dataRaw <- readr::read_csv(here(
  "LipidInteractomics_Website/IndividualStudies/DataTables/DataWrangling/AT_ChemComm2025_cytosol.csv"
))

CytosolData <- dataRaw |>
  mutate(
    gene_name = Gene,
    protein_id = Protein.ID,
    hit_annotation = case_when(
      hit_annotation == "hit" & logFC < 0 ~ "no hit",
      hit_annotation == "candidate" & logFC < 0 ~ "no hit",
      .default = hit_annotation
    ),
    LipidProbe = case_when(
      comparison.label == "PE_UV vs PE_NoUV" ~ "PE",
      comparison.label == "PA_UV vs PA_NoUV" ~ "PA"
    ),
    sample = case_when(sample == "cytosole" ~ "cytosol", .default = sample)
  ) |>
  dplyr::select(
    gene_name,
    protein_id,
    Protein.Description,
    LipidProbe,
    sample,
    logFC,
    AveExpr,
    pvalue,
    hit_annotation,
    -Gene,
    -Protein.ID,
    -comparison.label
  ) |>
  glimpse()

# write_csv(data, here("IndividualStudies/DataTables/AT_ChemicalCommunications_2025_cytosol_download.csv"))

PA_data <- CytosolData |>
  filter(LipidProbe == "PA")

# write_csv(PA_data, here("LipidInteractomics_Website/LipidProbe/DataSets/PA_cytosol_HeLa_AT_2025.csv"))

PE_data <- CytosolData |>
  filter(LipidProbe == "PE")
# write_csv(PE_data, here("LipidInteractomics_Website/LipidProbe/DataSets/PE_cytosol_HeLa_AT_2025.csv"))

##### Add membrane and cytosol data to the shiny app

bigDataSet <- read_csv(here(
  "LipidInteractomics_Website/ShinyApps/CompareLipidProbes/combinedProbeDatasets_TMT.csv"
)) |>
  filter(!LipidProbe %in% c("PA", "PE"))


MembraneData <- MembraneData |>
  mutate(CellLine = "HeLa - Membrane") |>
  select(LipidProbe, gene_name, logFC, pvalue, hit_annotation, CellLine)

CytosolData <- CytosolData |>
  mutate(CellLine = "HeLa - Cytosol") |>
  select(LipidProbe, gene_name, logFC, pvalue, hit_annotation, CellLine)

bigDataSet <- bigDataSet |>
  rbind(MembraneData) |>
  rbind(CytosolData) |>
  glimpse()

write_csv(
  bigDataSet,
  file = here(
    "LipidInteractomics_Website/ShinyApps/CompareLipidProbes/combinedProbeDatasets_TMT.csv"
  )
)
