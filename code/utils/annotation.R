# ---------------------------------------------------------
# Created by: Alex Luscombe
# Date: September 2022
# GitHub: alexlusco
# Repository: https://github.com/alexlusco/canadian-police-twitter
# ---------------------------------------------------------
# Description: Helper function for team-based annotation of tweets
# ---------------------------------------------------------
# Notes:
# - Feel free to explore, modify, and use this script.
# - If you find it helpful, a star to the repository would be appreciated!
# ---------------------------------------------------------

annotatetweets <- function() {
  
  pacman::p_load(googlesheets4, tibble, dplyr, stringr, crayon)
  
  sheet_url <- "REMOVED FOR PUBLIC SHARING"
  
  annotator <- menu(c("AL", "DK")) # AL = 1, DK = 2

  df <- suppressMessages(read_sheet(sheet_url, sheet = "all_data"))

  df <- mutate(df, text_t = str_squish(text_t)) # make match the squished txt in 'annotated' sheet

  df2 <- suppressMessages(read_sheet(sheet_url, sheet = "annotated"))
  
  df2 <- mutate(df2, text_t = as.character(text_t))

  df <- anti_join(df, df2, by = "text_t")

  rows <- sample(nrow(df))

  df <- df[rows, ]

  for (row in 1:nrow(df)){
  
    text <- paste0(df[row, "text_t"])
    url <- paste0(df[row, "url_t"])
  
    cat(crayon::green(text))
    cat(crayon::blue("\n", url))
  
    answer <- menu(c("yes", "no", "unsure"), title = "")
  
    currdata <- tibble(
      text_t = text,
      url_t = url,
      imagework = as.numeric(answer),
      annotator = as.numeric(annotator),
      date_time = Sys.time()
    ) %>%
      mutate(imagework = case_when(
        imagework == 1 ~ 1,
        imagework == 2 ~ 0,
        TRUE ~ 99
      )) %>%
      mutate(annotator = case_when(
        annotator == 1 ~ "AL",
        TRUE ~ "DK"
      ))
  
    suppressMessages(sheet_append(sheet_url, currdata, sheet = "annotated"))
  }
}

