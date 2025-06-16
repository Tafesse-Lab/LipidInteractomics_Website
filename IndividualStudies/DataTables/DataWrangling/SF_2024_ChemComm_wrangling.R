####################
# Data wrangling script for SK_2024

####################

# loading packages from source styles script
library(here)

## Opening the source file for the ggplot custom theme
source(here::here("Resources/ggplot_styles.R"))


############################################################

data <- read_csv(here("IndividualStudies/DataTables/DataWrangling/SF_ACS-ChemComm_2024_Limma_results_V3.csv")) |>
  glimpse()

unique(data$comparison)


data <- data |>
  select(gene_name, protein_id, logFC, pvalue, AveExpr, hit_annotation, sample, comparison, fdr) |>
  filter(sample == "Huh7") |>
  filter(comparison == "FA_8_3_UV - FA_8_3_noUV" | comparison == "FA_1_10_UV - FA_1_10_noUV") |>
  mutate(LipidProbe = case_when(comparison == "FA_8_3_UV - FA_8_3_noUV" ~ "8-3 FA",
                                comparison == "FA_1_10_UV - FA_1_10_noUV" ~ "1-10 FA")) |>
  select(-comparison, -sample) |>
  select(gene_name, protein_id, LipidProbe, hit_annotation, logFC, pvalue, AveExpr, fdr) |>
  glimpse() 

write_csv(data, here("IndividualStudies/DataTables/SF_ChemComm_2024_download.csv"))
