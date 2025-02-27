# Lipid Interactome

## Overview

The **Lipid Interactome** is an interactive, centralized resource designed to harmonize, compare, and integrate lipid interactome datasets. It adheres to **FAIR** (Findable, Accessible, Interoperable, and Reusable) data principles, ensuring that lipid–protein interaction data is systematically organized and easily accessible to researchers. By consolidating proteomics data from multifunctional lipid probes, this resource facilitates the systematic study of lipid-binding proteins across different lipid species and cellular models.

## Features

-   **Standardized Data Repository**: Curates and formats lipid interactome proteomics data from multiple studies.
-   **Interactive Visualizations**: Enables exploration of lipid–protein interactions via dynamic graphs and comparative tools.
-   **Cross-Study Comparisons**: Supports direct analysis of lipid interactomes across different experimental datasets.
-   **Data Download**: Provides `.csv` formatted datasets for computational analysis.
-   **Community Contributions**: Allows researchers to submit new datasets for inclusion.

## FAIR Data Principles

### Findable

-   A structured, user-friendly interface for navigating experimental datasets.
-   Clear entry points for study-specific and lipid-specific analyses.
-   Open to contributions from the scientific community.

### Accessible

-   All data is freely available for download.
-   Datasets include comprehensive metadata and documentation.
-   No user registration is required for access.

### Interoperable

-   Data is standardized for compatibility across different analytical platforms.
-   Includes methodological documentation to facilitate comparisons between studies.
-   Supports integration with external lipidomics databases.

### Reusable

-   Detailed dataset descriptions, workflow documentation, and limitations provided.
-   Minimization of technical jargon to ensure accessibility across disciplines.
-   References to key publications for further validation and context.

## Data Visualization and Interaction

The **Lipid Interactome** incorporates interactive data exploration tools to enhance usability and interpretability: - **Study-Specific Data Exploration**: Interactive Volcano, Ranked-Order, and MA plots for detailed analysis. - **Lipid Probe Aggregation**: Cross-study comparison of lipid–protein interactions. - **Shiny Application Integration**: Facilitates real-time data visualization and filtering.

## Repository Structure

```         
_site                                                
	├── 404.html                                         
	├── Background                                       
	│   ├── BackgroundFigures                            
	│   │   └── BaselineProteomics_ExperimentalDesign.png
	│   ├── BaselineProteomics_ExperimentalDesign.png    
	│   ├── DataAnalysisAndStatistics.html               
	│   ├── MultifunctionalLipidProbesOverview.html      
	│   └── ProteomicsUsingMultifunctionalProbes.html                
	├── ContactUs                                        
	│   ├── DataSubmission.html                          
	│   └── about.html                                   
	├── IndividualStudies                                
	│   ├── AT_2025.html                                 
	│   ├── DH_2017.html                                 
	│   ├── RM_2021.html                                 
	│   ├── SF_2024.html                                 
	│   ├── SF_2024_B.html                               
	│   └── StudyOverview.html                           
	├── LipidProbe                                       
	│   ├── 1-10_FattyAcid.html                          
	│   ├── 8-3_FattyAcid.html                           
	│   ├── Diacylglycerol.html                          
	│   ├── EnrichedHitsComparison.html                  
	│   ├── FormattingTemplate.html                      
	│   ├── PhosphatidicAcid.html                        
	│   ├── Phosphatidylethanolamine.html                
	│   ├── PhosphatidylinositolBisphosphate.html        
	│   ├── PhosphatidylinositolTrisphosphate.html       
	│   ├── Sphinganine.html                             
	│   ├── Sphingosine.html                             
	│   └── Structures                                   
	│       ├── 1-10_FattyAcid_Structure.png             
	│       ├── 8-3_FattyAcid_Structure.png              
	│       ├── PIP3_Structure.png                       
	│       ├── PhosphatidicAcid_Structure.png           
	│       ├── PhosphatidylethanolamineStructure.png    
	│       ├── SphinganineStructure.png                 
	│       └── SphingosineStructure.png                 
	├── MaintenanceInstructions.html                     
	├── Resources                                        
	│   └── styles.css                                   
	├── index.html
```

## Installation and Usage

### Prerequisites

-   **R (\>= 4.0)**
-   **Shiny**
-   **Tidyverse**
-   **ggplot2**
-   **plotly**
-   **clusterProfiler**
-   **dplyr**
-   **ggtangle**
-   **org.Hs.eg.db**

### Running the Shiny App Locally

``` r
# Clone the repository
git clone git@github.com:gaelenDG/LipidInteractomics_Website.git
cd LipidInteractomics_Website

# Launch the Shiny app
R -e "shiny::runApp('shiny_app')"
```

## Availability

The **Lipid Interactome** can be accessed at [LipidInteractome.org](https://www.lipidinteractome.org). All datasets are available for download, and no user data is collected for navigation or interaction.

## Data Submission

Researchers are encouraged to contribute their datasets to expand the repository. Submission guidelines and contact details are available on the [Data Submission Page](https://www.lipidinteractome.org/DataSubmission.html).

For inquiries, feedback, or additional questions, please email the site administrators at [Contact.Us\@lipidinteractome.org](mailto:Contact.Us@lipidinteractome.org).

## Keywords

Lipid-protein interactions, proteomics, interactomics, database, multifunctionalized lipids, bioinformatics.