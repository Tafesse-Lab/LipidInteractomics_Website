## Needed a script space to add in a column for the cell line used for the lipid probe selected

# Library initialization
library(here)
library(dplyr)
library(tidyr)
library(readr)

BigDataset <- read_csv(here("ShinyApps/LipidInteractomics_ShinyApp/combinedProbeDatasets_TMT.csv")) |> 
  mutate(CellLine = case_when(LipidProbe == "PA" | LipidProbe == "PE" | LipidProbe == "BF-NAPE" | LipidProbe == "PDAA" | LipidProbe == "bf-GPI" ~ "HeLa",
                              LipidProbe == "Spa" | LipidProbe == "Sph" | LipidProbe == "8-3 FA" | LipidProbe == "1-10 FA" ~ "Huh7")) |>
  glimpse()
 

unique(BigDataset$LipidProbe)


write_csv(BigDataset, here("ShinyApps/LipidInteractomics_ShinyApp/combinedProbeDatasets_TMT.csv"))
