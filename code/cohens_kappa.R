# ---------------------------------------------------------
# Created by: Alex Luscombe
# Date: 2022
# GitHub: alexlusco
# Repository: https://github.com/alexlusco/canadian-police-twitter
# ---------------------------------------------------------
# Description: Annotate random sample of 100 tweets from training
# sample and calculate cohen's kappa (interrater reliability)
# ---------------------------------------------------------
# Notes:
# - Feel free to explore, modify, and use this script.
# - If you find it helpful, a star to the repository would be appreciated!
# ---------------------------------------------------------

pacman::p_load(googlesheets4, dplyr, irr, tidyr, tibble)

# Create function to annotate sample of N = 100 to calculate cohens
sheet_url <- "" # removed for public sharing
df <- read_sheet(sheet_url, sheet = "cohens_annotated")
df <- df %>% pivot_wider(names_from = annotator, values_from = imagework)
df <- df %>% mutate_all(as.character)
df <- df %>% select(AL, DK)
df %>% select(AL, DK) %>% kappa2() # 200 subjects, 2 raters, kappa = 0.965 (unweighted)
df %>% select(AL, DK) %>% agree() # 200 subjects, raters = 2, %-agree = 99 (tolerance = 0)


