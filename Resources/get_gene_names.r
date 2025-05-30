# ###############
# # This script retrieves gene symbols from RefSeq protein accession numbers using the NCBI Entrez API.
# # It handles outdated accessions by checking for linked updated protein IDs.
# # It also filters out entries without gene symbols and saves the results to a CSV file.
# ###############
# # Load necessary libraries
# library(rentrez)
# library(dplyr)
# library(readr)
# library(here)
# library(tidyr)
# library(tibble)


# # Function to get gene symbol from a RefSeq protein accession number
# get_gene_symbol <- function(accession) {
#     # Search NCBI protein database for the given accession
#     search_result <- entrez_search(db = "protein", term = accession)
    
#     if (length(search_result$ids) > 0) {
#         protein_id <- search_result$ids[1]  # Get first valid protein ID

#         # Check for newer version of the protein accession
#         protein_links <- entrez_link(dbfrom = "protein", id = protein_id, db = "protein")

#         if (!is.null(protein_links$links$protein_protein)) {
#             latest_protein_id <- protein_links$links$protein_protein[1]  # Take the first linked updated protein
#             message(paste("Accession", accession, "is outdated. Updating to", latest_protein_id))
#             return(get_gene_symbol(latest_protein_id))  # Retry with the latest accession
#         }

#         # Use entrez_link to find the linked Gene ID
#         links <- entrez_link(dbfrom = "protein", id = protein_id, db = "gene")

#         if (length(links$links$protein_gene) > 0) {
#             gene_id <- links$links$protein_gene[1]  # Get the linked Gene ID

#             # Retrieve summary information for the gene
#             gene_summary <- entrez_summary(db = "gene", id = gene_id)
            
#             print(gene_summary$name)
#             return(gene_summary$name)  # Extract official gene symbol
#         }
#     } 

#     message(paste("Accession not found or no gene linked:", accession))
#     return(NA)  # Return NA if not found
# }

# get_gene_symbol <- Vectorize(get_gene_symbol)

# get_gene_symbol("BAG37094.1")


# DCC_2025_RawData <- read_csv(here("IndividualStudies/DataTables/DCC_2025_ChemrXiv_FullDataset.csv"))


# DCC_2025_RawData <- DCC_2025_RawData %>%
#   filter(is.na(gene_name)) |>
#   select(gene_ID, gene_name) |>
#   mutate(gene_name = if_else(is.na(gene_name),
#                              get_gene_symbol(gene_ID),
#                              gene_name))


# DCC_2025_RawData_missingNames <- DCC_2025_RawData|> 
#   filter(is.na(gene_name))

# unique(DCC_2025_RawData_missingNames$gene_ID)

# # Example list of RefSeq protein accession numbers
# accession_numbers_test <- c("NP_006112.3", "XP_005257400.1", "XP_006720633.1")

# accession_numbers <- as.vector(RawData$Accession)
# accession_numbers2 <- as.vector(moreMissingAccession$Accession)
# get_gene_symbol(accession_numbers_test[200])

# # Apply function to all accession numbers
# gene_symbols <- sapply(accession_numbers2, get_gene_symbol)
# head(gene_symbols)

# colnames(RawData)

# RawData2 <- RawData |> 
#   mutate(gene_name = gene_symbols[Accession]) |>
#   filter(is.na(gene_name))

# missing_gene_names <- as.vector(RawData2$Accession)


# tosave <- enframe(gene_symbols)

# # write_csv(tosave, paste0(here(), "/IndividualStudies/DataTables/WY_2021_surprisenewgenenames.csv"))
