############
# INTRO    #
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
install.packages("forecast")





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
library(forcats)


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
# 2. Analysis of top repositories #
###################################

##########################################################
# 2.1 Most popular languages in the top 100 repositories #
##########################################################

# sorting the dataframe desc based on star value. By doing this we get the most liked repositories
s_df <- i_df %>%
  arrange(desc(i_df$Stars))

# only take the first 100 values 
s_df <- s_df %>%
  slice(1:100)


#drop column which don't contain a language value
s_df <- s_df %>% drop_na(Language)


# Create a bar plot of most Popular GitHub Repositories by Language
ggplot(s_df, aes(x = Language)) +
  geom_bar(fill = "red") +
  labs(title = "Most Popular GitHub Repositories by Language",
       x = "Language",
       y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


###########################################
# 3.2 Repositories most downloaded (fork) #
###########################################

colors <- cut(f_df$Forks,
                     breaks = c(0, 25000, 50000, 75000, Inf),
                     labels = c("blue", "orange", "green", "red"))



# sorting the dataframe desc based on fork value. By doing this we get the most liked repositories
f_df <- i_df %>%
  arrange(desc(i_df$Forks))

f_df <- s_df %>%
  slice(1:20)

# Reorder following the value of another column:
f_df %>%
  mutate(Name = fct_reorder(Name, Forks)) %>%
  ggplot( aes(x=Name, y=Forks, fill= colors)) +
  geom_bar(stat="identity", alpha=.6, width=.4) +
  scale_fill_manual(
    values = c("blue" = "blue", "orange" = "orange", "green" = "#33FF33", "red" = "red"),
    labels = c("0-25,000", "25,001-50,000", "50,001-75,000", "Above 75,000")
  ) +
  labs(title = "Most Popular GitHub Repositories by Forks",
       x = "Repository name",
       y = "Forks") +
  coord_flip() +
  xlab("") +
  theme_bw()




################################################
# 3.3 Amount of repositories created each year #
################################################

#convert created at column to date type
i_df$`Created At` <- as.Date(i_df$`Created At`)
#extracting the year from date time
i_df$'Year' <- format(i_df$`Created At`,"%Y")




# Create a bar plot of most Popular GitHub Repositories by Language
ggplot(i_df, aes(x = Year)) +
  geom_bar(fill = "red") +
  labs(title = "Amount of repositories created each year",
       x = "Year",
       y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Remove the temporary file
unlink(temp_file)





##########################################
# 3.4 Relationship between star and fork #
##########################################



# Create a scatter plot with a regression line
ggplot(i_df, aes(x = Stars, y = Forks)) +
  geom_point(color = "blue") +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  labs(x = "Stars", y = "Forks") +
  theme_minimal() +
  ggtitle("Scatter Plot with Regression Line")




#########################
# 3.5 Most popular tags #
#########################

# Convert the 'Topics' string to a list
t_df <- i_df %>% 
  mutate(Topics = strsplit(Topics, ", ")) %>%
  unnest(Topics)

# Count the occurrences of each tag
tag_counts <- t_df %>%
  group_by(Topics) %>%
  summarize(count = n()) %>%
  arrange(desc(count)) %>%
  top_n(10)


# Create a bar chart
ggplot(tag_counts, aes(x = fct_reorder(Topics, count), y = count)) +
  geom_bar(stat = "identity", fill = "blue") +
  labs(x = "Topics", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("Most Popular Topic Tags")

####################################################
# 3.XX Web scraping extra if the other shizzle works #
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


