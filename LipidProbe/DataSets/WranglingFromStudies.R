## intitialize libraries
library(here)

## Opening the source file for the ggplot custom theme
source(paste0(here(), "/Resources/ggplot_styles.R"))


### 1-10 FA & 8-3 FA

FullStudyData <- read_csv(here("IndividualStudies/DataTables/SF_ChemComm_2024_download.csv"))

FA1_10 <- FullStudyData |>
  filter(LipidProbe == "1-10 FA")

write_csv(FA1_10, here("LipidProbe/DataSets/1-10_FA_Huh7_SF_2024.csv"))

FA8_3 <- FullStudyData |>
  filter(LipidProbe == "8-3 FA")

write_csv(FA8_3, here("LipidProbe/DataSets/8-3_FA_Huh7_SF_2024.csv"))
