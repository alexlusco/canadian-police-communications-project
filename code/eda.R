pacman::p_load(readr, dplyr)

files <- list.files("data", pattern = "\\d{1}.csv", full.names = TRUE)

df <- lapply(files, read_csv)

df <- bind_rows(df)
