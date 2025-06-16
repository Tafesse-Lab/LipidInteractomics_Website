####################
# Data wrangling script for SK_2024

####################

# loading packages from source styles script
library(here)

## Opening the source file for the ggplot custom theme
source(here::here("Resources/ggplot_styles.R"))


############################################################

# 1 - Need to extract gene names from accession numbers

library(biomaRt)

# Try connecting to a mirror
ensembl <- useEnsembl(biomart = "ensembl", 
                      dataset = "hsapiens_gene_ensembl",
                      mirror = "useast")  # or "uswest", "asia"

# Function to get gene symbol or fallback gene title
get_gene_symbol <- function(accession) {
  tryCatch({
    search <- entrez_search(db = "protein", term = accession)
    if (length(search$ids) == 0) return(NA)

    gb_record <- entrez_fetch(db = "protein", id = search$ids[[1]], rettype = "gb", retmode = "text")
    match <- regmatches(gb_record, regexpr("/gene=\"[^\"]+\"", gb_record))

    gene <- if (length(match) > 0) {
      sub("/gene=\"|\"", "", match)
    } else {
      summary <- entrez_summary(db = "protein", id = search$ids[[1]])
      summary$title
    }

    return(gene)
  }, error = function(e) {
    message("Error with accession ", accession, ": ", e$message)
    return(NA)
  })
}

# Vector of accession numbers
accessions <- pull(rawData, Accession)

# Path to CSV results file
csv_file <- here("IndividualStudies/DataTables/gene_symbol_results.csv")

# Load previously saved results if the file exists
if (file.exists(csv_file)) {
  results <- read.csv(csv_file, stringsAsFactors = FALSE)
  processed <- results$accession
} else {
  results <- data.frame(accession = character(), gene_symbol = character(), stringsAsFactors = FALSE)
  processed <- character()
}

# Iterate through accessions, skipping ones already done
for (acc in accessions) {
  if (acc %in% processed) next  # skip if already processed

  gene <- get_gene_symbol(acc)
  results <- rbind(results, data.frame(accession = acc, gene_symbol = gene, stringsAsFactors = FALSE))

  # Save progress after every accession
  write.csv(results, csv_file, row.names = FALSE)

  message("Processed: ", acc)
}

#####################################################

# 2 - Begin wrangling with new gene names

#     - Add gene names to raw data
#     - Rename columns to match standard format (LogFC, pvalue, etc)
#     - Apply significance thresholds according to publication - label in standardized way
#     - Save wrangled data to new .csv

gene_names <- read_csv(here("IndividualStudies/DataTables/gene_symbol_results.csv")) |>
  mutate(
    gene_name = case_when(
      gene_symbol == "unnamed protein product [Homo sapiens]" ~ accession,
      gene_symbol == "unknown [Homo sapiens]" ~ accession,
      TRUE ~ str_remove(gene_symbol, "\"$")
    ) 
  ) |>
  mutate(Accession = accession) |>
  dplyr::select(-gene_symbol, -accession) |>
  glimpse()

rawData <- readr::read_csv(here("IndividualStudies/DataTables/SK_2024_fullDataset_originalHandoff.csv")) |>
  dplyr::select(Accession, Description, `Abundance Ratio (log2): (Penta) / (Control)`, `Abundance Ratio Adj. P-Value: (Penta) / (Control)`, `Abundances (Grouped): Control`, `Abundances (Grouped): Penta`) |>
  rename(logFC = `Abundance Ratio (log2): (Penta) / (Control)`,
          pvalue = `Abundance Ratio Adj. P-Value: (Penta) / (Control)`,
         Control_abundance = `Abundances (Grouped): Control`,
         Penta_abundance = `Abundances (Grouped): Penta`) |>
  mutate(AveExpr = log2((Control_abundance + Penta_abundance)/2)) |>
  left_join(gene_names, by = "Accession") |>
  dplyr::select(gene_name, Accession, Description, logFC, pvalue, AveExpr, Control_abundance, Penta_abundance) |>
  mutate(hit_annotation = case_when(.default = "no hit",
                                    logFC >= 2 & pvalue <= 0.05 ~ "enriched hit",
                                    logFC >= 1 & pvalue < 0.05 ~ "enriched candidate")) |>
  mutate(LipidProbe = "bf-GPI") |>
  glimpse()

write_csv(rawData, here("IndividualStudies/DataTables/SK_2024_ChemEuro.csv"))


# 3 - Adding to compare lipid probes page

data <- readr::read_csv(here::here("IndividualStudies/DataTables/SK_2024_ChemEuro.csv")) |>
  dplyr::select(LipidProbe, gene_name, logFC, pvalue, hit_annotation) |>
  glimpse()

CombinedProbeData <- read_csv(here("ShinyApps/LipidInteractomics_ShinyApp/combinedProbeDatasets_TMT.csv")) |>
  dplyr::select(-`...1`) |>
  glimpse() |>
  rbind(data)

write_csv(CombinedProbeData, here("ShinyApps/LipidInteractomics_ShinyApp/combinedProbeDatasets_TMT.csv"))  


