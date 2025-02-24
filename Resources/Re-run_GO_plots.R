#######################################
#' The purpose of this R script is to re-run the GO plotting functions and re-render all of the plots displayed on the IndividualStudies and LipidProbe pages.
	#' Uncomment some or all of the sections below if any changes are made.
	#' Add new sections for new datasets using the frameworks below.
#######################################

## intitialize libraries
library(here)
library(dplyr)
library(tidyr)
library(readr)
library(crosstalk)

## Opening the source file for the ggplot custom theme
source(paste0(here(), "/Resources/ggplot_styles.R"))

## Sphingosine
# Sph_data <- readr::read_csv(paste0(here(), "/LipidProbe/DataSets/Sph_Huh7_SF_2024.csv")) |>
# 	filter(LipidProbe == "Sph")

# CC_enrichment_plots(Sph_data, "dot", "/LipidProbe/GO_plots/Sph_SF_2024_CC-DOTplot")
# CC_enrichment_plots(Sph_data, "cnet", "/LipidProbe/GO_plots/Sph_SF_2024_CC-CNETplot")

# MF_enrichment_plots(Sph_data, "dot", "/LipidProbe/GO_plots/Sph_SF_2024_MF-DOTplot")
# MF_enrichment_plots(Sph_data, "cnet", "/LipidProbe/GO_plots/Sph_SF_2024_MF-CNETplot")

# BP_enrichment_plots(Sph_data, "dot", "/LipidProbe/GO_plots/Sph_SF_2024_BP-DOTplot")
# BP_enrichment_plots(Sph_data, "cnet", "/LipidProbe/GO_plots/Sph_SF_2024_BP-CNETplot")


## Sphinganine

# Spa_data <- readr::read_csv(paste0(here(), "/LipidProbe/DataSets/Spa_Huh7_SF_2024.csv")) |>
# 	filter(LipidProbe == "Spa")

# CC_enrichment_plots(Spa_data, "dot", "/LipidProbe/GO_plots/Spa_SF_2024_CC-DOTplot")
# CC_enrichment_plots(Spa_data, "cnet", "/LipidProbe/GO_plots/Spa_SF_2024_CC-CNETplot")

# MF_enrichment_plots(Spa_data, "dot", "/LipidProbe/GO_plots/Spa_SF_2024_MF-DOTplot")
# MF_enrichment_plots(Spa_data, "cnet", "/LipidProbe/GO_plots/Spa_SF_2024_MF-CNETplot")

# BP_enrichment_plots(Spa_data, "dot", "/LipidProbe/GO_plots/Spa_SF_2024_BP-DOTplot")
# BP_enrichment_plots(Spa_data, "cnet", "/LipidProbe/GO_plots/Spa_SF_2024_BP-CNETplot")


## SF_2024_A

# SF_2024_data <- readr::read_csv(paste0(here(), "/IndividualStudies/DataTables/SF_ACS-Chem-Bio_2024_download.csv"))

# CC_enrichment_plots(SF_2024_data, "dot", "/IndividualStudies/GO_plots/Sph-Spa_SF_2024_CC-DOTplot")
# CC_enrichment_plots(SF_2024_data, "cnet", "/IndividualStudies/GO_plots/Sph-Spa_SF_2024_CC-CNETplot")

# MF_enrichment_plots(SF_2024_data, "dot", "/IndividualStudies/GO_plots/Sph-Spa_SF_2024_MF-DOTplot")
# MF_enrichment_plots(SF_2024_data, "cnet", "/IndividualStudies/GO_plots/Sph-Spa_SF_2024_MF-CNETplot")

# BP_enrichment_plots(SF_2024_data, "dot", "/IndividualStudies/GO_plots/Sph-Spa_SF_2024_BP-DOTplot")
# BP_enrichment_plots(SF_2024_data, "cnet", "/IndividualStudies/GO_plots/Sph-Spa_SF_2024_BP-CNETplot")


## 1-10 FA

# SF_2024_1_10FA_data <- readr::read_csv(paste0(here(), "/LipidProbe/DataSets/1-10_FA_Huh7_SF_2024.csv")) |>
# 	filter(LipidProbe == "1-10 FA")

# CC_enrichment_plots(SF_2024_1_10FA_data, "dot", "/LipidProbe/GO_plots/1-10FA_SF_2024_CC-DOTplot")
# CC_enrichment_plots(SF_2024_1_10FA_data, "cnet", "/LipidProbe/GO_plots/1-10FA_SF_2024_CC-CNETplot")

# MF_enrichment_plots(SF_2024_1_10FA_data, "dot", "/LipidProbe/GO_plots/1-10FA_SF_2024_MF-DOTplot")
# MF_enrichment_plots(SF_2024_1_10FA_data, "cnet", "/LipidProbe/GO_plots/1-10FA_SF_2024_MF-CNETplot")

# BP_enrichment_plots(SF_2024_1_10FA_data, "dot", "/LipidProbe/GO_plots/1-10FA_SF_2024_BP-DOTplot")
# BP_enrichment_plots(SF_2024_1_10FA_data, "cnet", "/LipidProbe/GO_plots/1-10FA_SF_2024_BP-CNETplot")

## 8-3 FA

# SF_2024_8_3FA_data <- readr::read_csv(paste0(here(), "/LipidProbe/DataSets/8-3_FA_Huh7_SF_2024.csv")) |>
# 	filter(LipidProbe == "8-3 FA")

# CC_enrichment_plots(SF_2024_8_3FA_data, "dot", "/LipidProbe/GO_plots/8-3FA_SF_2024_CC-DOTplot")
# CC_enrichment_plots(SF_2024_8_3FA_data, "cnet", "/LipidProbe/GO_plots/8-3FA_SF_2024_CC-CNETplot")

# MF_enrichment_plots(SF_2024_8_3FA_data, "dot", "/LipidProbe/GO_plots/8-3FA_SF_2024_MF-DOTplot")
# MF_enrichment_plots(SF_2024_8_3FA_data, "cnet", "/LipidProbe/GO_plots/8-3FA_SF_2024_MF-CNETplot")

# BP_enrichment_plots(SF_2024_8_3FA_data, "dot", "/LipidProbe/GO_plots/8-3FA_SF_2024_BP-DOTplot")
# BP_enrichment_plots(SF_2024_8_3FA_data, "cnet", "/LipidProbe/GO_plots/8-3FA_SF_2024_BP-CNETplot")

## SF_2024_B

# SF_2024_B_data <- readr::read_csv(paste0(here(), "/IndividualStudies/DataTables/SF_Chem_Comm_2024_download.csv"))

# CC_enrichment_plots(SF_2024_B_data, "dot", "/IndividualStudies/GO_plots/8-3FA-1-10FA_SF_2024_CC-DOTplot")
# CC_enrichment_plots(SF_2024_B_data, "cnet", "/IndividualStudies/GO_plots/8-3FA-1-10FA_SF_2024_CC-CNETplot")

# MF_enrichment_plots(SF_2024_B_data, "dot", "/IndividualStudies/GO_plots/8-3FA-1-10FA_SF_2024_MF-DOTplot")
# MF_enrichment_plots(SF_2024_B_data, "cnet", "/IndividualStudies/GO_plots/8-3FA-1-10FA_SF_2024_MF-CNETplot")

# BP_enrichment_plots(SF_2024_B_data, "dot", "/IndividualStudies/GO_plots/8-3FA-1-10FA_SF_2024_BP-DOTplot")
# BP_enrichment_plots(SF_2024_B_data, "cnet", "/IndividualStudies/GO_plots/8-3FA-1-10FA_SF_2024_BP-CNETplot")


## PE

# PE_AT_2025 <- readr::read_csv(paste0(here(), "/LipidProbe/DataSets/PE_HeLa_AT_2025.csv"))

# CC_enrichment_plots(PE_AT_2025, "dot", "/LipidProbe/GO_plots/PE_AT_2025_CC-DOTplot")
# CC_enrichment_plots(PE_AT_2025, "cnet", "/LipidProbe/GO_plots/PE_AT_2025_CC-CNETplot")

# MF_enrichment_plots(PE_AT_2025, "dot", "/LipidProbe/GO_plots/PE_AT_2025_MF-DOTplot")
# MF_enrichment_plots(PE_AT_2025, "cnet", "/LipidProbe/GO_plots/PE_AT_2025_MF-CNETplot")

# BP_enrichment_plots(PE_AT_2025, "dot", "/LipidProbe/GO_plots/PE_AT_2025_BP-DOTplot")
# BP_enrichment_plots(PE_AT_2025, "cnet", "/LipidProbe/GO_plots/PE_AT_2025_BP-CNETplot")


## PA

# PA_AT_2025 <- readr::read_csv(paste0(here(), "/LipidProbe/DataSets/PA_HeLa_AT_2025.csv")) 

# CC_enrichment_plots(PA_AT_2025, "dot", "/LipidProbe/GO_plots/PA_AT_2025_CC-DOTplot")
# CC_enrichment_plots(PA_AT_2025, "cnet", "/LipidProbe/GO_plots/PA_AT_2025_CC-CNETplot")

# MF_enrichment_plots(PA_AT_2025, "dot", "/LipidProbe/GO_plots/PA_AT_2025_MF-DOTplot")
# MF_enrichment_plots(PA_AT_2025, "cnet", "/LipidProbe/GO_plots/PA_AT_2025_MF-CNETplot")

# BP_enrichment_plots(PA_AT_2025, "dot", "/LipidProbe/GO_plots/PA_AT_2025_BP-DOTplot")
# BP_enrichment_plots(PA_AT_2025, "cnet", "/LipidProbe/GO_plots/PA_AT_2025_BP-CNETplot")


## AT_2025

# AT_2025 <- readr::read_csv(paste0(here(), "/IndividualStudies/DataTables/AT_ChemicalCommunications_2025_download.csv")) 

# CC_enrichment_plots(AT_2025, "dot", "PE-PA_AT_2025_CC-DOTplot")
# CC_enrichment_plots(AT_2025, "cnet", "PE-PA_AT_2025_CC-CNETplot")

# MF_enrichment_plots(AT_2025, "dot", "PE-PA_AT_2025_MF-DOTplot")
# MF_enrichment_plots(AT_2025, "cnet", "PE-PA_AT_2025_MF-CNETplot")

# BP_enrichment_plots(AT_2025, "dot", "PE-PA_AT_2025_BP-DOTplot")
# BP_enrichment_plots(AT_2025, "cnet", "PE-PA_AT_2025_BP-CNETplot")