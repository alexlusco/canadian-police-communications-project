# ---------------------------------------------------------
# Created by: Alex Luscombe
# Date: 2022
# Repository: https://github.com/alexlusco/canadian-police-twitter
# ---------------------------------------------------------
# Description: Extract all tweets and replies from list of 186 Canadian police usernames from Twitter v2 endpoints using academic Twitter API
# ---------------------------------------------------------

pacman::p_load(academictwitteR, tibble, readr, dplyr)

#set_bearer()
#get_bearer()

twitter_handles <- read_csv("data/police_twitter_handles.csv") %>% janitor::clean_names()
twitter_handles <- twitter_handles %>% select(username)

# This function pulls twitter data and saves copies of data to folder as JSON

for (t in unlist(twitter_handles)){
  
  police_tweets <-
    get_all_tweets(
      users = unlist(twitter_handles), #swap out accordingly
      start_tweets = "2006-03-21T00:00:00Z", #date that first tweet was sent
      end_tweets = "2021-12-31T00:00:00Z", #last day of 2021
      bind_tweets = TRUE,
      file = "canadian_police_tweets", 
      data_path = "data/academictwitterR_tweets", #folder to save data files to
      n = Inf #set to infinite to pull every tweet
    )
  
}

# update collection 1 (appears to have failed)
police_tweets <-
  update_collection(
    data_path = "data/academictwitterR_tweets_nov15_2022",
    end_tweets = "2022-11-15T00:00:00Z"
    )

twitter_handles <- read_csv("data/police_twitter_handles.csv") %>% janitor::clean_names()
twitter_handles <- twitter_handles %>% select(username)

# update collection 2

twitter_handles_171_188 <- twitter_handles %>% slice(171:188)

for (t in unlist(twitter_handles_171_188)){
  
  police_tweets <-
    get_all_tweets(
      users = unlist(twitter_handles_171_188), #swap out accordingly
      start_tweets = "2021-12-31T00:00:00Z", #date that first tweet was sent
      end_tweets = "2022-11-16T00:00:00Z", #last day of 2021
      bind_tweets = TRUE,
      file = "canadian_police_tweets", 
      data_path = "data/academictwitterR_tweets_nov16_2022", #folder to save data files to
      n = Inf #set to infinite to pull every tweet
    )
  
}

# bind tweets
police_tweets <- bind_tweets(data_path = "data/academictwitterR_tweets_nov16_2022")

# Get user profile information using `author_id`Zoo
author_ids <- police_tweets %>% as_tibble() %>% distinct(author_id)
user_profiles <- get_user_profile(unlist(author_ids), bearer_token = get_bearer()) %>% as_tibble()

# to distinguish columns at tweet level and profile level
colnames(user_profiles) <- paste(colnames(user_profiles), "p", sep = "_")
colnames(police_tweets) <- paste(colnames(police_tweets), "t", sep = "_")

# Bind with police_tweets df
df <- police_tweets %>%
  left_join(user_profiles, by = c("author_id_t" = "id_p"))

# Save as RDS
saveRDS(df, "data/police_tweets.rds")

################################
## Get replies to tweets
################################
police_tweets <- bind_tweets(data_path = "data/academictwitterR_tweets_nov16_2022")
police_tweets2 <- bind_tweets(data_path = "data/academictwitterR_tweets")

for(c in unlist(conv_ids)){
  
  get_all_tweets(
    conversation_id = c,
    start_tweets = "2006-03-21T00:00:00Z", #date that first tweet was sent
    end_tweets = "2021-12-31T00:00:00Z", #last day of 2021
    bind_tweets = TRUE,
    #file = "canadian_police_tweets", 
    data_path = "data/academictwitteR_replies", #folder to save data files to
    n = Inf #set to infinite to pull every tweet
  )
  
}

################################
## Get replies to tweets from sample
################################
#conv_ids <- read_csv("data/replied_tweets_Nge25_conversation_ids.csv", col_types = "c")

#police_tweets3 <- bind_rows(police_tweets, police_tweets2)

police_tweets3 <- read_rds("data/police_tweets_nov16_2022.rds")

conv_ids <- police_tweets3 %>% select(public_metrics, conversation_id) %>% distinct(conversation_id, .keep_all = TRUE)

conv_ids_sampled <- conv_ids %>% tidyr::unnest(public_metrics) %>% filter((reply_count + quote_count) > 10) %>% select(conversation_id)

for(c in unlist(conv_ids_sampled)){
  
  get_all_tweets(
    conversation_id = c,
    start_tweets = "2006-03-21T00:00:00Z", #date that first tweet was sent
    end_tweets = "2022-11-16T00:00:00Z", #last day of 2021
    bind_tweets = TRUE,
    #file = "canadian_police_tweets", 
    data_path = "/Volumes/ajl_external/twitter_replies_nov17_2022", #folder to save data files to
    n = Inf #set to infinite to pull every tweet
  )
  
}

# bind tweets
replies_to_police_tweets <- bind_tweets(data_path = "/Volumes/ajl_external/twitter_replies_nov17_2022")

replies_to_police_tweets <- replies_to_police_tweets %>% as_tibble()

write_rds(replies_to_police_tweets, "/Volumes/ajl_external/twitter_replies_nov17_2022/police_tweet_replies_nov17_2022.rds")

################################
## Get replies to all tweets
################################
conv_ids <- read_rds("data/police_tweets.rds")

conv_ids <- conv_ids %>%
  filter(reply_count >= 5) %>%
  select(conversation_id_t) %>%
  distinct(conversation_id_t)

#files <- list.files("/Volumes/ajl_external/police_tweet_replies", pattern = "[0-9]+.json$")

#convs_collected <- files %>%
#  as_tibble() %>%
#  mutate(value = stringr::str_extract(value, "[0-9]+"))

convs_collected <- read_rds("/Volumes/ajl_external/police_tweet_replies_v2/police_tweet_replies_all.rds")

convs_collected <- convs_collected %>%
  select(conversation_id) %>%
  distinct(conversation_id) %>%
  filter(conversation_id != "1296118586218512389")
  #rename(value = conversation_id) %>%

conv_ids <- conv_ids %>%
  anti_join(replies_to_police_tweets, by = c("conversation_id_t" = "conversation_id"))

#conv_ids <- conv_ids %>%
#  rename(value = conversation_id_t) %>%
#  anti_join(convs_collected)

for(c in unlist(conv_ids)){
  
  get_all_tweets(
    conversation_id = c,
    start_tweets = "2006-03-21T00:00:00Z", #date that first tweet was sent
    end_tweets = "2021-12-31T00:00:00Z", #last day of 2021
    bind_tweets = TRUE,
    #file = "canadian_police_tweets", 
    data_path = "/Volumes/ajl_external/police_tweet_replies_v2", #folder to save data files to
    n = Inf #set to infinite to pull every tweet
  )
  
}

# bind tweets
replies_to_police_tweets <- bind_tweets(data_path = "/Volumes/ajl_external/police_tweet_replies_v2")

replies_to_police_tweets <- replies_to_police_tweets %>% as_tibble()

write_rds(replies_to_police_tweets, "/Volumes/ajl_external/police_tweet_replies_v2/police_tweet_replies_all.rds")

replies_to_police_tweets %>% select(conversation_id) %>% print()
