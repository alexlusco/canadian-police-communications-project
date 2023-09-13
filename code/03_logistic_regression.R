# ---------------------------------------------------------
# Created by: Alex Luscombe
# Date: 2022
# Repository: https://github.com/alexlusco/canadian-police-twitter
# ---------------------------------------------------------
# Description: R code to build, tune, and evaluate machine learning model that predicts whether or not a tweet is desired class based on annotated 
# training data
# ---------------------------------------------------------

pacman::p_load(dplyr, readr, tidytext, tidymodels, discrim, textrecipes, gtools, stringr, ggplot2, textclean)

police_tweet_df <- read_csv("data/training_data.csv")

police_tweet_df <- police_tweet_df %>%
  filter(lang_t == "en") # we have dropped french, but an english translated version with all 6000 is available

police_tweet_df <- police_tweet_df %>%
  filter(imagework != 99) %>%
  select(-annotator)

# filter to distinct tweets only
police_tweet_df <- police_tweet_df %>%
  distinct(text_t, .keep_all = TRUE)

# remove hms from date
police_tweet_df <- police_tweet_df %>%
  mutate(created_at_t = str_extract(created_at_t, "\\d{4}-\\d{2}-\\d{2}")) %>%
  mutate(created_at_t = lubridate::ymd(created_at_t))

# make outcome factor (not sure if necessary)
police_tweet_df <- police_tweet_df %>%
  mutate(username_p = as.factor(username_p))

# remove URLs from data, then remove NAs (tweets that were only URLs)
police_tweet_df <- police_tweet_df %>%
  mutate(text_t = textclean::replace_url(text_t)) %>%
  filter(str_count(text_t, "\\w+") > 5)

# Check distribution of replies (outcome var)
police_tweet_df %>%
  count(imagework) %>%
  ggplot(aes(x = imagework, y = n)) +
  geom_col()

# Build first model
set.seed(1234)

police_tweet_split <- police_tweet_df %>%
  mutate(imagework = as.factor(imagework),
         text_t = str_remove_all(text_t, "'")) %>%
  initial_split()

police_tweet_train <- training(police_tweet_split)
police_tweet_test <- testing(police_tweet_split)

police_tweet_rec <- recipe(imagework ~ text_t, data = police_tweet_split) %>%
  step_tokenize(text_t, token = "words") %>% # there used to be a tweets tokenizer, gone?
  #step_stopwords(text_t, stopword_source = "snowball") %>%
  step_tokenfilter(text_t, max_tokens = 1e3) %>%
  step_tfidf(text_t) %>%
  step_normalize(all_predictors())

police_tweet_prep <- prep(police_tweet_rec)
police_tweet_bake <- bake(police_tweet_prep, new_data = NULL)

#dim(police_tweet_bake)

police_tweet_wf <- workflow() %>%
  add_recipe(police_tweet_rec)

#spec <- svm_linear() %>%
#  set_mode("classification") %>%
#  set_engine("LiblineaR")

spec <- logistic_reg(penalty = 0.01, mixture = 1) %>%
  set_mode("classification") %>%
  set_engine("glmnet")

#spec <- rand_forest(trees = 1000) %>%
#  set_mode("classification") %>%
#  set_engine("ranger")

#spec <- boost_tree() %>%
#  set_mode("classification") %>%
#  set_engine("xgboost")

#spec <- nearest_neighbor() %>%
#  set_mode("classification") %>%
#  set_engine("kknn")

fit <- police_tweet_wf %>%
  add_model(spec) %>%
  fit(data = police_tweet_train)

#term_estimates <- svm_fit %>%
#  pull_workflow_fit() %>%
#  tidy()

police_tweet_folds <- vfold_cv(police_tweet_train)

rs <- fit_resamples(
  police_tweet_wf %>% add_model(spec),
  police_tweet_folds,
  control = control_resamples(save_pred = TRUE),
  metrics = metric_set(roc_auc, pr_auc,
                       accuracy, f_meas)
)

collect_metrics(rs)

####
glm_predictions <- police_tweet_test %>%
  mutate(predict(fit, police_tweet_test))

# accuracy
glm_predictions %>%
  conf_mat(imagework, .pred_class) %>%
  pluck(1) %>%
  as_tibble() %>%
  ggplot(aes(Prediction, Truth, alpha = n)) +
  geom_tile(show.legend = FALSE) +
  geom_text(aes(label = n), colour = "white", alpha = 1, size = 8)

# precision recall
tibble(
  "precision" = 
    precision(glm_predictions, imagework, .pred_class) %>%
    select(.estimate),
  "recall" = 
    recall(glm_predictions, imagework, .pred_class) %>%
    select(.estimate)
) %>%
  unnest() %>%
  knitr::kable()

# f1 score
glm_predictions %>%
  f_meas(imagework, .pred_class) %>%
  select(-.estimator) %>%
  knitr::kable()


