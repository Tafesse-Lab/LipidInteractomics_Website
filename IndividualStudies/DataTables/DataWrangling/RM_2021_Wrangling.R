####################
# Data wrangling script for RM_2021

####################

# loading packages from source styles script
library(here)

## Opening the source file for the ggplot custom theme
source(here::here("Resources/ggplot_styles.R"))

dataRaw <- read_csv(here("IndividualStudies/DataTables/DataWrangling/RM_2021_limmaResults.csv")) |>
  glimpse()

data <- dataRaw |>
  filter(sample %in% c("UV")) |>
  filter(comparison.label %in% c("cytosole vs cytosole_minusUV", "membrane vs membrane_minusUV")) |>
  mutate(
    Fraction = case_when(
      comparison.label == "cytosole vs cytosole_minusUV" ~ "Cytosol (+UV vs -UV)",
      comparison.label == "membrane vs membrane_minusUV" ~ "Membrane (+UV vs -UV)"
    ),
    gene_name = Gene,
    protein_id = Protein.ID,
    LipidProbe = "PI(3,4,5)P3"
  ) |>
  dplyr::select(gene_name, protein_id, Protein.Description, LipidProbe, Fraction, hit_annotation_method, logFC, pvalue, AveExpr, fdr, hit_annotation) |>
  glimpse()

unique(data$hit_annotation)

data |>
  filter(hit_annotation %in% c("enriched hit", "enriched candidate")) |>
  glimpse()

write_csv(data, "IndividualStudies/DataTables/RM_Angewandte_2021_download.csv")
