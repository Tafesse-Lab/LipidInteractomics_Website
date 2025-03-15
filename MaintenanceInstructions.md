---
title: "Maintenance Instructions"
author: "Gaelen Guzman"
date: 2025/01/09
---

## Site Organization

I've done my best to make the site organization logical, but really only the next person to try to update this site can be the judge on whether I succeeded in that... 

Under the "IndividualStudies" folder are the .qmd files that define the preparation of each corresponding .html page. The data going into these .qmd files is stored under the "DataTables" subfolder. Under the "LipidProbe" folder are the .qmd files that define the pages on each individual probe. Much of the information is copied between the two sets of pages, so be careful when making changes to one, as corresponding changes should be made elsewhere!

The _quarto.yml page is described further below, but here it should be mentioned that it will need to be modified to add pages to the site, as it defines the linking structure throughout the whole site.

## Maintenance

### Basic overview

This site was built using Quarto. This is a form of R Markdown that is highly documented, and one can learn how to modify this site here: <https://quarto.org/docs/websites>{target="_blank"}. The site is hosted on Netlify, and the repository is on GitHub. The data is stored in .csv files. The site is built using the Bootstrap framework, and the ggplot2 and plotly packages are used to make the plots.

The overarching formatting of the site is controlled within the _quarto.yml file. Here one can update the site theme from the array of [Bootswatch](https://bootswatch.com/){target="_blank"} themes, or if you're feeling ambitious you can design your own theme.

When making updates to the site, one first edits/makes a file, then you use the Bash command "quarto render --to html". This will update the site directory within the _site folder. There are a lot of ways to do the editing, but it's nicest to use the IDE Visual Studio Code because there's a terminal in-window and you can see nice previews of what the site will look like without leaving the program.

### GitHub repository

After changes are made to the .qmd files and then rendered, the changes can then be pushed to the GitHub repository: <git@github.com:gaelenDG/LipidInteractomics_Website.git>. Netlify will pull the changes and automatically deploy the updated site! See site owners for Netlify login information and .git access.

Cloning the GitHub repository should be sufficient for gaining access to all of the files in this website - though collaborators will need to be added manually by Gaelen, the repository administrator. More details will go here once a more formal pull request workflow is in place!

### Quarto formatting

I have found that Quarto is highly documented and it's pretty easy to figure out how to format or change the way things look (if all else fails, ask ChatGPT and you usually get a pretty ok answer).

As a reference to help get you started, I very much appreciated [this blog post](https://blog.posertinlab.com/posts/2023-06-09-writing-a-dissertation-in-quarto/){target="_blank"} by Richard Posert about using Quarto.

I honestly get the most confused when it comes to formatting the _quarto.yml file because there aren't many fully-fleshed examples out there for all the options. This is where I've (embarrassingly) leaned on ChatGPT for help -- it's not always right, but it's usually close enough that you can make it work properly anyways.

If you want to add a page, you need to make a new .qmd file in the proper subfolder and render it as an .html file (conveniently, the Preview button in VS Code does that for you, but you can use whatever IDE you want). Then you need to add two lines to the _quarto.yml file so that the page is properly linked on the sidebar or navbar (first the href to denote the file path to the desired .qmd file, then the text to display on the page) -- if you don't add these, the page will remain unlinked and you'll need to know the whole URL to find it (like this maintenance page).

If your data looks at all like [Alix's](https://lipidinteractomicsrepository.netlify.app/individualstudies/at_2025){target="_blank"} or [Scotty's](https://lipidinteractomicsrepository.netlify.app/individualstudies/sf_2024){target="_blank"}, the ggplot functions I built in the ggplot_styles.R file will apply. Call the RankedOrderPlotStandard(), VolcanoPlotStandardized(), and MAStandard() functions to produce these plots with the same standardized formatting. On that note, you can alter the ggplot_styles.R file to change the standardized formatting across all the pages.

There are a ton of things you can do within html divs, but I haven't dipped my toes in those yet - use these to finely adjust how elements of each page look.

In order to make sure the author information is identical on all appropriate pages, I made an "include" folder with each study included thus far. This enables you to call the same study information on each probe/study page without worrying that they're somehow different.

### Shiny app

The Shiny app embedded in the iframe in the [Probe vs Probe Comparisons](LipidProbe/EnrichedHitsComparison.qmd) markdown is defined within "/ShinyApps/LipidInteractomics_ShinyApp". In order to add new studies to this, you will need to update the .csv file saved in Chunk #1 of "LipidProbe/EnrichedHitsComparison.qmd". Save the .csv, make sure it updates in the Shiny App directory, and re-deploy the Shiny App to [shinyapps.io](shinyapps.io). Gaelen will have to manage the permissions to make this possible for other users -- stay tuned for updates here.

## Step-by-step instructions for adding a new study

(Assumes that you're adding a new study which utilized TMT and Frank's FragPipe data analysis pipeline. Anything else will have to be somewhat custom made -- as a starting point, just follow these steps as best you can, then adjust from there.)

1) Duplicate the template file under the /StudyInformation_includes folder, populate each section with the appropriate details about the study being added. This "include" file will be linked to the actual data pages and allows for a single point to edit the details across all the pages.

2) Duplicate the template file under the /IndividualStudies folder, edit "include" link to point to the new file made in Step 1.
	* Copy full dataset to the /IndividualStudies/DataTables folder with an appropriate name.
	* Edit the setup/data wrangling R chunk to open and prepare the data -- make sure the read_csv() call points to the location of the dataset being added. If needed, adjust the order of lipid probes depicted under the factor(pull()) function call -- change the values of the levels vector to reflect the probes (the default is simply alphabetical)
	* Don't yet adjust the Gene Ontology sections - we'll return to this in Step 5.


3) If new study utilizes new lipid probes, make as many duplicates as appropriate of the template file under the /LipidProbe folder (i.e., if there are two lipid probes analyzed in the study at hand.)
	* Prepare individual copies of the dataset filtered for each lipid probe, place them in the /LipidProbe/Datasets folder (I know that the /Datasets folder doesn't match the /DataTable folder, I'll work on fixing that someday).
	* Make sure the cell type referenced is accurate, link to the appropriate "include" to add the correct study details.
	* Edit the setup/data wrangling R chunk to open and prepare the data.
	* Adjust the plotting function calls.
	* Again, we'll do the Gene Ontology section in step 5.

4) If the new study repeats an analysis of a lipid probe in a new cell type, add the dataset to a new section to the appropriate LipidProbe .qmd file
	* For example, the Sphingosine probe was used in both Huh7 cells and HeLa -- use this file as a reference to adjust an existing page.

5) To prepare the gene ontology plots for the new study, first make the appropriate plot files using the script under the /Resources/Re-run_GO_plots.R file.
	* See the instructions in the doc string at the top of the file.
	* Currently, the sections in the file are organized so that each study and each lipid probe within the study are together in big blocks.
	* Add a new block for the new data, use read_csv() to open each respective dataframe and apply the three CC, MF, and BP plotting functions to each part of the new data.
	* The plotting functions will save new files to the designated folders -- make sure the filenames are unique and easily recognizable (e.g. "**1-10FA_SF_2024_**CC-DOTplot.html"), you'll need them shortly
	* Now go back to the .qmd files under /LipidProbe and /IndividualStudies and make sure the Gene Ontology references point to the correct new files - pay attention to the CC, MF, BP types!

6) Update "Search by protein" page
	* Add new data to the /SearchByProtein/combinedProbeDatasets_TMT.csv file with rbind().
	* Add study DOI and short name to the case_when() call.

7) Update Shiny App on "Probe vs Probe Comparisons" page
	* This will require access to the ShinyApps.io account.
	* Copy the new version of the combinedProbeDatasets_TMT.csv file to the /ShinyApps/LipidInteractomics_ShinyApp folder.
	* Make sure the app still works with the new dataset, if it does, redeploy!

6) Finally, we need to update the _quarto.yml file so that the new .qmd files are organized under the correct lipid class
	* e.g. if the new probe is a sphingolipid, make sure to place its link there
	* If the new probes are a distinct class, make a new category of probe (use the existing categories as a template)