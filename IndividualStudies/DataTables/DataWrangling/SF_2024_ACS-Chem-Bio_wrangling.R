####################
# Data wrangling script for SK_2024

####################

# loading packages from source styles script
library(here)

## Opening the source file for the ggplot custom theme
source(here::here("Resources/ggplot_styles.R"))


############################################################

data <- read_csv(here("LipidInteractomics_Website/IndividualStudies/DataTables/DataWrangling/SF_ACS-ChemBio_2024_Limma_results_V3.csv")) |>
  glimpse()


data <- data |>
  select(gene_name, protein_id, logFC, pvalue, AveExpr, hit_annotation, sample, comparison, fdr) |>
  filter(sample == "Huh7") |>
  filter(comparison == "Spa_UV - Spa_noUV" | comparison == "Sph_UV - Sph_noUV") |>
  mutate(LipidProbe = case_when(comparison == "Spa_UV - Spa_noUV" ~ "Spa",
                                comparison == "Sph_UV - Sph_noUV" ~ "Sph")) |>
  select(-comparison, -sample) |>
  select(gene_name, protein_id, LipidProbe, hit_annotation, logFC, pvalue, AveExpr, fdr) |>
  glimpse() 

# write_csv(data, here("LipidInteractomics_Website/IndividualStudies/DataTables/SF_ACS-Chem-Bio_2024_download.csv"))

Sph_data <- data |>
  filter(LipidProbe == "Sph")

write_csv(Sph_data, here("LipidInteractomics_Website/LipidProbe/DataSets/Sph_Huh7_SF_2024.csv"))

Spa_data <- data |>
  filter(LipidProbe == "Spa")

write_csv(Spa_data, here("LipidInteractomics_Website/LipidProbe/DataSets/Spa_Huh7_SF_2024.csv"))
