## Information

Site author: Gaelen Guzman
Date: 2025/01/09

## Overview



## Organization

## Maintenance

See site owners for login information and .git access. This site automatically deploys updates to the github repository, so any changes will go live immediately upon push to main.

### Basic overview

This site was built using Quarto. This is a form of R Markdown that is highly documented, and one can learn how to modify this site here: <https://quarto.org/docs/websites>. 

The overarching formatting of the site is controlled within the _quarto.yml file. Here one can update the site theme from the array of [Bootswatch](https://bootswatch.com/){target="_blank"} themes, or if you're feeling ambitious you can design your own theme.

When making updates to the site, one first edits/makes a file, then you use the Bash command "quarto render". This will update the site directory within the _site folder. There are a lot of ways to do the editing, but it's nicest to use the IDE Visual Studio Code because there's a terminal in-window and you can see nice previews of what the site will look like. 
