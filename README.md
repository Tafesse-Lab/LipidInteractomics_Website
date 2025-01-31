---
title: "README"
author: "Gaelen Guzman"
date: 2025/01/09
format: 
  html:
    embed-resources: true
standalone: true
---

(You can also see these instructions at <https://lipidinteractomicsrepository.netlify.app/maintenanceinstructions.html>{target="_blank"})

## Site Organization

I've done my best to make the site organization logical, but really only the next person to try to update this site can be the judge on whether I succeeded in that... 

Under the "IndividualStudies" folder are the .qmd files that define the preparation of each corresponding .html page. The data going into these .qmd files is stored under the "DataTables" subfolder. Under the "LipidProbe" folder are the .qmd files that define the pages on each individual probe. Much of the information is copied between the two sets of pages, so be careful when making changes to one, as corresponding changes should be made elsewhere!

The _quarto.yml page is described further below, but here it should be mentioned that it will need to be modified to add pages to the site, as it defines the linking structure throughout the whole site.

## Maintenance

### Basic overview

This site was built using Quarto. This is a form of R Markdown that is highly documented, and one can learn how to modify this site here: <https://quarto.org/docs/websites>{target="_blank"}. 

The overarching formatting of the site is controlled within the _quarto.yml file. Here one can update the site theme from the array of [Bootswatch](https://bootswatch.com/){target="_blank"} themes, or if you're feeling ambitious you can design your own theme.

When making updates to the site, one first edits/makes a file, then you use the Bash command "quarto render". This will update the site directory within the _site folder. There are a lot of ways to do the editing, but it's nicest to use the IDE Visual Studio Code because there's a terminal in-window and you can see nice previews of what the site will look like without leaving the program. 

### GitHub repository

After changes are made to the .qmd files and then rendered, the changes can then be pushed to the GitHub repository: <git@github.com:gaelenDG/LipidInteractomics_Website.git>. Netlify will pull the changes and automatically deploy the updated site! See site owners for Netlify login information and .git access.

Cloning the GitHub repository should be sufficient for gaining access to all of the files in this website - though collaborators will need to be added manually by Gaelen, the repository administrator. More details will go here once a more formal pull request workflow is in place!

### Quarto formatting

I have found that Quarto is highly documented and it's pretty easy to figure out how to format or change the way things look (if all else fails, ask ChatGPT and you usually get a pretty good answer). 

As a reference to help get you started, I very much appreciated [this blog post](https://blog.posertinlab.com/posts/2023-06-09-writing-a-dissertation-in-quarto/){target="_blank"} by Richard Posert about using Quarto.

I honestly get the most confused when it comes to formatting the _quarto.yml file because there aren't many fully-fleshed examples out there for all the options. This is where I've (embarrassingly) leaned on ChatGPT for help -- it's not always right, but it's usually close enough that you can make it work properly anyways.

If you want to add a page, you need to make a new .qmd file in the proper subfolder and render it as an .html file (conveniently, the Preview button in VS Code does that for you, but you can use whatever IDE you want). Then you need to add two lines to the .yml file so that the page is properly linked on the sidebar or navbar (first the href to denote the file path to the .html file, then the text to display on the page) -- if you don't add these, the page will remain unlinked and you'll need to know the whole URL to find it (like this maintenance page).

If your data looks at all like [Alix's](https://lipidinteractomicsrepository.netlify.app/individualstudies/at_2025){target="_blank"} or [Scotty's](https://lipidinteractomicsrepository.netlify.app/individualstudies/sf_2024){target="_blank"}, the ggplot functions I built in the ggplot_styles.R file will apply. Call the RankedOrderPlotStandard(), VolcanoPlotStandardized(), and MAStandard() functions to produce these plots with the same standardized formatting. On that note, you can alter the ggplot_styles.R file to change the standardized formatting. 

There are a ton of things you can do within html divs, but I haven't dipped my toes in those yet - use these to finely adjust how elements of each page look.

In order to make sure the author information is identical on all appropriate pages, I made an "include" folder with each study included thus far. This enables you to call the same study information on each probe/study page without worrying that they're somehow different.
