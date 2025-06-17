####################
# Data wrangling script for DCC_2025

####################

# loading packages from source styles script
library(here)

## Opening the source file for the ggplot custom theme
source(here::here("Resources/ggplot_styles.R"))

############################################################


# 1 -  Coercing original data handoff into standardized format for my plotting functions

#   - averaging logFC and pvalues for the ids of each protein by replicate, counting the number of reps for each protein
#   - adding statistical annotation based on the publication's cutoffs
#   - maintained the original statistical output from the publication
data <- readr::read_csv(here("IndividualStudies/DataTables/DataWrangling/DCC_2025_ChemrXiv_FullDataset.csv")) |>
  glimpse() |>
  group_by(gene_name) |>
  filter(ratio_MvsL != "") |>
  summarise(gene_ID = dplyr::first(gene_ID),
            logFC = mean(log2(ratio_MvsL)),
            pvalue = mean(pvalue),
            numReplicates = n(),
            AveExpr = log10(mean(L_abundance) + mean(M_abundance))/2) |>
  arrange(-logFC) |>
  mutate(LipidProbe = "BF-NAPE",
         hit_annotation = case_when(.default = "no hit",
                                    logFC >= 0.5849625 & pvalue <= 0.05 & numReplicates == 2 ~ "enriched candidate",
                                    logFC >= 0.5849625 & pvalue <= 0.05 & numReplicates == 3 ~ "enriched hit")) |>
  glimpse()


# Median normalizing the logFC values for each protein id'd
median_logFC <- median(data$logFC)

data$logFC <- data$logFC - median_logFC

write_csv(data, here("IndividualStudies/DataTables/DCC_2025_ChemrXiv_Download.csv"))


# 2 - Adding to compare lipid probes page

data <- readr::read_csv(here::here("IndividualStudies/DataTables/DCC_2025_ChemrXiv_Download.csv")) |>
  dplyr::select(LipidProbe, gene_name, logFC, pvalue, hit_annotation) |>
  mutate(CellLine = "HeLa") |>
  glimpse()

CombinedProbeData <- read_csv(here("ShinyApps/LipidInteractomics_ShinyApp/combinedProbeDatasets_TMT.csv")) |>
  # dplyr::select(-`...1`) |>
  glimpse() |>
  rbind(data)

write_csv(CombinedProbeData, here("ShinyApps/LipidInteractomics_ShinyApp/combinedProbeDatasets_TMT.csv"))  

