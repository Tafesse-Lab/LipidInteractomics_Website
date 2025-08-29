####################
# Data wrangling script for WY_2021

####################

# loading packages from source styles script
library(here)

## Opening the source file for the ggplot custom theme
source(here::here("Resources/ggplot_styles.R"))

############################################################

# 1 - Coercing data handoff into standard format

RawData <- read_csv(here::here(
  "LipidInteractomics_Website/IndividualStudies/DataTables/DataWrangling/WY_2021_ACSChemBio_RawData2.csv"
))

filtered_data <- RawData |>
  filter(
    if_all(starts_with("Control_"), ~ !is.na(.) & . != 0) &
      if_all(starts_with("Sample_"), ~ !is.na(.) & . != 0)
  ) |>
  arrange(-Control_1)

# Convert wide format to long format
long_data <- filtered_data |>
  pivot_longer(
    cols = c(-gene_name, -Accession),
    names_to = c("Condition", "Replicate"),
    names_sep = "_",
    values_to = "Abundance"
  ) |>
  mutate(Condition = ifelse(Condition == "Control", "Control", "Sample"))

# Count the number of observations per gene per condition
complete_genes <- long_data |>
  filter(if_all(starts_with("Abundance"), ~ !is.na(.))) |> # Keep only genes with full data in both groups
  group_by(gene_name, Condition) |>
  summarise(count = n(), .groups = "drop") |>
  pivot_wider(names_from = Condition, values_from = count, values_fill = 0) |>
  filter(Control == 3 & Sample == 3) |>
  pull(gene_name)

# Filter the original dataset to include only these complete genes
filtered_data <- long_data |>
  filter(gene_name %in% complete_genes)

# Run t-test for each gene
t_test_results <- filtered_data |>
  group_by(gene_name, Accession) |>
  summarise(
    pvalue = t.test(
      Abundance[Condition == "Sample"],
      Abundance[Condition == "Control"],
      var.equal = TRUE
    )$p.value,
    logFC = log2(
      mean(Abundance[Condition == "Sample"]) /
        mean(Abundance[Condition == "Control"])
    )
  ) |>
  mutate(
    adj_p_value = p.adjust(pvalue, method = "BH"),
    LipidProbe = "PDAA",
    hit_annotation = case_when(
      .default = "no hit",
      logFC > log2(1.5) & pvalue < 0.05 ~ "enriched hit"
    )
  ) # Adjust p-values for multiple testing

averaged_data <- filtered_data |>
  group_by(gene_name) |>
  summarise(AveExpr = log10(mean(Abundance)))

data <- t_test_results |>
  left_join(averaged_data)

write_csv(
  data,
  here("LipidInteractomics_Website/IndividualStudies/DataTables/WY_2021_ACSChemBio_Download.csv")
)

############################################################

# 2 - Adding to compare lipid probes page

data <- readr::read_csv(here::here(
  "IndividualStudies/DataTables/WY_2021_ACSChemBio_Download.csv"
)) |>
  dplyr::select(LipidProbe, gene_name, logFC, pvalue, hit_annotation) |>
  mutate(CellLine = "HeLa") |>
  glimpse()

CombinedProbeData <- read_csv(here(
  "ShinyApps/LipidInteractomics_ShinyApp/combinedProbeDatasets_TMT.csv"
)) |>
  # dplyr::select(-`...1`) |>
  glimpse() |>
  rbind(data)

CombinedProbeData |> filter(LipidProbe == "PDAA")

write_csv(
  CombinedProbeData,
  here("ShinyApps/LipidInteractomics_ShinyApp/combinedProbeDatasets_TMT.csv")
)
