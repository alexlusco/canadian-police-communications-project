# ---------------------------------------------------------
# Created by: Alex Luscombe
# Date: 2022
# Repository: https://github.com/alexlusco/canadian-police-twitter
# ---------------------------------------------------------
# Description: R code to predict whether or not tweet is instance of desired class based on pre-trained logistic regression model. Note that this code can 
# be run only after running logistic_regression.R, as fit object required in R environment
# ---------------------------------------------------------

pacman::p_load(dplyr, readr)

police_tweet_df <- read_rds("data/police_tweets_subset.rds")

#police_tweet_df <- police_tweet_df %>% distinct(id_t, .keep_all = TRUE)

split_dataframe <- function(df, indices) {
  # calculate the end rows based on the indices
  ends <- c(indices[-1] - 1, nrow(df))
  
  # split the data frame based on the indices
  list_of_dfs <- mapply(function(start, end) {
    df[start:end, , drop = FALSE]
  }, indices, ends, SIMPLIFY = FALSE)
  
  # name each dataframe based on the indices
  names(list_of_dfs) <- mapply(function(start) {
    paste0("df_", start)
  }, indices)
  
  return(list_of_dfs)
}

indices <- c(1, 250001, 500001, 750001, 1000001, 1250001, 1500001)

police_tweet_df <- split_dataframe(police_tweet_df, indices)

for (i in seq_along(police_tweet_df)) {
  
  cat("Augmenting", i, "with pred class\n")
  
  # get the dataframe from the list
  df <- police_tweet_df[[i]]
  
  # apply the mutate function to predict
  df_pred <- df %>%
    mutate(predict(fit, df))
  
  cat("Saving", i)
  
  # create a unique filename based on the list names
  file_name <- paste0("data/predictions/police_tweets_", names(police_tweet_df)[i], "_pred.csv")
  
  # save the data frame with predictions as a .csv file
  write_csv(df_pred, file_name)
  
}





