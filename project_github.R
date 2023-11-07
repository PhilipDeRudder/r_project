############
# INTRO #
############
# Goals:
# - Get,Read, clean and strucuture data to make it suitable for the analysis (NA row delete) DONE
# - Analyze languages used in top 100 projects DONE 3.1
# - Analyze top repositories based on forks 
# - Analyze contribution to a repository
# - Analyse users/owner of the repositories (webscraper)
# - Analyse issues from top repo's? 





############
# Installs #
############
install.packages("httr") # for http requests
install.packages("readxl") # for reading excel files
install.packages("openxlsx") # for reading excel files when readx1 doesn't work
install.packages("dplyr")
install.packages("ggplot2")
install.packages("tidyr")
install.packages("tidyverse")
install.packages("rvest")
install.packages("stringr")





#################
# LIBRARIES     #
#################
library(httr)
library(readxl)
library(openxlsx)
library(dplyr)       # For data manipulation
library(ggplot2)     # For creating visualizations
library(tidyr)       # For data tidying
library(tidyverse)  
library(rvest)
library(magrittr)
library(stringr)

#################
# 1. Read data  #
#################


# Define the URL of the raw Excel file on GitHub
github_excel_url <- "https://github.com/PhilipDeRudder/r_project/raw/main/repositories.xlsx"

# Download the Excel file to a local temporary file
temp_file <- tempfile(fileext = ".xlsx")
download.file(github_excel_url, temp_file, mode = "wb")

# Read the Excel data into a data frame using readxl
i_df <- read_excel(temp_file)



###################################
# 3. Analysis of top repositories #
###################################

############################################
# 3.1 Language most used by top 1000 repos #
############################################

# sorting the dataframe desc based on star value. By doing this we get the most likes repositories
f_df <- i_df %>%
  arrange(desc(i_df$Stars))

# only take the first 100 values 
f_df <- f_df %>%
  slice(1:100)


#drop column which don't contain a language value
f_df <- f_df %>% drop_na(Language)


# Create a bar plot of most Popular GitHub Repositories by Language
ggplot(f_df, aes(x = Language)) +
  geom_bar(fill = "red") +
  labs(title = "Most Popular GitHub Repositories by Language",
       x = "Language",
       y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#########################################
# 3.1 Repository most downloaded (fork) #
#########################################

# Remove the temporary file
unlink(temp_file)






####################################################
# 3.XX Webscraping extra if the other shizzle works #
####################################################

# Define the URL of the GitHub Trending page
url <- "https://github.com/trending"

# Read the webpage and parse the HTML content
webpage <- read_html(url)

# Extract the repository titles and descriptions
repos <- webpage %>%
  html_nodes(".h3 a") %>%
  html_text()


cleaned_repos <- str_trim(repos)

# Print the cleaned top 10 trending repository titles
head(cleaned_repos, 10)




















