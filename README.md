## Information

Site author: Gaelen Guzman
Date: 2025/01/09

## Overview



## Organization

I've done my best to make the site organization logical, but TBD if I succeeded in that... 

Under the "IndividualStudies" folder are the .qmd files that define the preparation of each corresponding .html page. The data going into these .qmd files is stored under the "DataTables" subfolder.

The _quarto.yml page is described further below, but here it should be mentioned that it will need to be modified to add pages to the site, as it defines the linking structure throughout the whole site.

## Maintenance

### Basic overview

This site was built using Quarto. This is a form of R Markdown that is highly documented, and one can learn how to modify this site here: <https://quarto.org/docs/websites>{target="_blank"}. 

The overarching formatting of the site is controlled within the _quarto.yml file. Here one can update the site theme from the array of [Bootswatch](https://bootswatch.com/){target="_blank"} themes, or if you're feeling ambitious you can design your own theme.

When making updates to the site, one first edits/makes a file, then you use the Bash command "quarto render". This will update the site directory within the _site folder. There are a lot of ways to do the editing, but it's nicest to use the IDE Visual Studio Code because there's a terminal in-window and you can see nice previews of what the site will look like without leaving the program. 

Any changes can then be pushed to the github repository; Netlify will pull the changes and automatically deploy the updated site! See site owners for Netlify login information and .git access. It will be TBD how GitHub ownership is transferred after Gaelen leaves.

