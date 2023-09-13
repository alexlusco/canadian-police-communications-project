# ---------------------------------------------------------
# Created by: Alex Luscombe
# Date: 2022
# Description: R code to subset variables from full API outputs of tweets and replies
# ---------------------------------------------------------

# load packages
pacman::p_load(readr, dplyr, tidyr)

# create df with needed vars
police_tweet_df <- read_rds("data/police_tweets.rds")

# keep only english language tweets
police_tweet_df <- filter(police_tweet_df, lang_t == "en")

# select needed vars
police_tweet_df <- police_tweet_df %>%
  select(entities_t, public_metrics_t, created_at_t, text_t, id_t, lang_t, possibly_sensitive_t, name_p, username_p, description_p, verified_p, location_p, created_at_p, conversation_id_t, public_metrics_p, in_reply_to_user_id_t) %>%
  as_tibble()

# unpack public_metrics_t and entities_t vars
police_tweet_df <- police_tweet_df %>% 
  unpack(public_metrics_t) %>%
  unpack(entities_t) %>%
  unpack(public_metrics_p)

# add p tag to distinguish unpacked public_metrics_p cols
police_tweet_df <- police_tweet_df %>%
  rename(followers_count_p = followers_count,
         following_count_p = following_count,
         tweet_count_p = tweet_count,
         listed_count_p = listed_count)

# rm more unwanted vars
police_tweet_df <- police_tweet_df %>%
  select(-annotations, -urls, -mentions, -cashtags, -hashtags) # dropping hashtags here, would need to retain if unnnesting using below code

# unnest hashtags var (throws error - commenting out for now, could extract hashtags manually from text_t)
#police_tweet_df_hashtags <- police_tweet_df %>%
#  unnest(hashtags)

#police_tweet_df_hashtags <- police_tweet_df_hashtags %>%
#  select(tag, id_t)

# rejoin hashtags df with original
#police_tweet_df <- police_tweet_df %>%
#  left_join(police_tweet_df_hashtags, by = "id_t") %>%
#  select(-hashtags)

# create URLs to tweets
police_tweet_df <- police_tweet_df %>%
  mutate(url_t = paste0("https://twitter.com/", username_p, "/status/", id_t, sep = ""))

# save as feather
write_rds(police_tweet_df, "data/police_tweets_subset.rds")
#feather::write_feather(police_tweet_df, "data/can_police_tweets_subset.feather")

rm(police_tweet_df)

###################################

police_replies_df <- read_rds("data/police_tweet_replies_nov17_2022.rds")

colnames(police_replies_df) <- paste(colnames(police_replies_df), "t", sep = "_")

# keep only english language tweets
police_replies_df <- filter(police_replies_df, lang_t == "en")

police_replies_df <- police_replies_df %>%
  unpack(entities_t) %>%
  unpack(public_metrics_t) %>%
  unpack(geo_t) %>%
  unpack(attachments_t) %>%
  unpack(withheld_t) %>%
  unpack(coordinates)

police_replies_df <- police_replies_df %>%
  select(-mentions, -annotations, -urls, -cashtags, -source_t, -place_id, -coordinates, -type, -media_keys, -poll_ids, -country_codes, -copyright)

police_replies_df <- police_replies_df %>%
  unnest(referenced_tweets_t)

police_replies_df <- police_replies_df %>%
  rename(hashtags_t = hashtags) %>%
  rename(type_t = type) %>%
  rename(reply_to_id_t = id) %>%
  rename(retweet_count_t = retweet_count) %>%
  rename(reply_count_t = reply_count) %>%
  rename(like_count_t = like_count) %>%
  rename(quote_count_t = quote_count)

write_rds(police_replies_df, "data/can_police_replies_subset.rds")

rm(police_replies_df)
