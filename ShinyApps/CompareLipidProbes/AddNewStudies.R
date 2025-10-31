smallDataset <- bigDataSet |>
  mutate(studyPointer = paste(LipidProbe, CellLine, sep = " - "))

studyPointers <- unique(smallDataset$studyPointer)

studyPointers <- as.data.frame(studyPointers) |>
  mutate(
    Publication = case_when(
      studyPointers %in% c("Sph - Huh7", "Spa - Huh7") ~
        "Farley et al. 2024, Chemical Communications",
      studyPointers %in% c("8-3 FA - Huh7", "1-10 FA - Huh7") ~
        "Farley et al. 2024, ACS Chemical Biology",
      studyPointers %in% c("BF-NAPE - HeLa") ~ "Chiu et al. 2025, ChemrXiv",
      studyPointers %in% c("bf-GPI - HeLa") ~ "Kundu et al. 2024, Chem Euro",
      studyPointers %in% c("PDAA - HeLa") ~ "Yu et al. 2021, ACS Chem Bio",
      studyPointers %in%
        c(
          "PA - HeLa - Membrane",
          "PE - HeLa - Membrane",
          "PA - HeLa - Cytosol",
          "PE - HeLa - Cytosol"
        ) ~
        "Thomas et al. 2025, Chemical Communications",
    ),
    URL = case_when(
      studyPointers %in% c("Sph - Huh7", "Spa - Huh7") ~
        "https://lipidinteractome.org/individualstudies/sf_2024_b",
      studyPointers %in% c("8-3 FA - Huh7", "1-10 FA - Huh7") ~
        "https://lipidinteractome.org/individualstudies/sf_2024",
      studyPointers %in% c("BF-NAPE - HeLa") ~
        "https://lipidinteractome.org/individualstudies/dcc_2025",
      studyPointers %in% c("bf-GPI - HeLa") ~
        "https://lipidinteractome.org/individualstudies/sk_2024",
      studyPointers %in% c("PDAA - HeLa") ~
        "https://lipidinteractome.org/individualstudies/wy_2021",
      studyPointers %in%
        c(
          "PA - HeLa - Membrane",
          "PE - HeLa - Membrane",
          "PA - HeLa - Cytosol",
          "PE - HeLa - Cytosol"
        ) ~
        "https://lipidinteractome.org/individualstudies/at_2025",
    )
  )

write_csv(
  studyPointers,
  file = here(
    "LipidInteractomics_Website/ShinyApps/CompareLipidProbes/Studies.csv"
  )
)
