# ---------------------------------------------------------
# Created by: Alex Luscombe
# Date: 2022
# Description: R code to rejoin split police tweet dfs augmented with predicted class in 04_predict_from_fit.R. Stratified random sample also generated and saved
# to /data for EDA purposes.
# ---------------------------------------------------------

pacman::p_load(readr, dplyr, stringr)

file_paths <- list.files("data/predictions/", pattern = "_pred.csv$", full.names = TRUE)

list_of_dfs <- lapply(file_paths, read_csv)

df <- bind_rows(list_of_dfs)

# save full df as csv
write_csv(df, "data/police_tweets_subset_preds.csv")

# save stratified random sample
df |> 
  mutate(year = str_extract(created_at_t, "\\d{4}")) |> 
  group_by(year, username_p, .pred_class) |> # strata = year, username, class
  sample_frac(size = .25) |>  # take 25%
  write_csv("data/police_tweets_subset_preds_sample.csv")
