library(tidyverse)
lego_sets <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-09-06/sets.csv.gz')
glimpse(lego_sets)


lego_sets %>%
  filter(num_parts > 0) %>%
  ggplot(aes(num_parts)) +
  geom_histogram(bins = 20) +
  scale_x_log10()


# Build the model

library(tidymodels)

set.seed(123)
lego_split <- lego_sets %>%
  filter(num_parts > 0) %>%
  transmute(num_parts = log10(num_parts), name) %>%
  initial_split(strata = num_parts)

lego_train <- training(lego_split)
lego_test <- testing(lego_split)

set.seed(234)
lego_folds <- vfold_cv(lego_train, strata = num_parts)
lego_folds

# Recipe

library(textrecipes)

lego_rec <- recipe(num_parts ~ name, data = lego_train) %>%
  step_tokenize(name) %>%
  step_tokenfilter(name, max_tokens = 200) %>%
  step_tfidf(name)

lego_rec

# Model spec

svm_spec <- svm_linear(mode = "regression")
lego_wf <- workflow(lego_rec, svm_spec)

# Fit the model

set.seed(234)

doParallel::registerDoParallel()
lego_rs <- fit_resamples(lego_wf, lego_folds)
collect_metrics(lego_rs)


# Evaluate on testing set

final_fitted <- last_fit(lego_wf, lego_split)
collect_metrics(final_fitted)


# words associated with higher number of LEGO parts

final_fitted %>%
  extract_workflow() %>%
  tidy() %>%
  arrange(-estimate)


# version the model
library(vetiver)
library(pins)

# Path inside Docker container
board_path <- "models"  

# Create the board
dir.create(board_path, recursive = TRUE, showWarnings = FALSE)
board <- board_folder(board_path)

# Create the vetiver model
v <- final_fitted %>%
  extract_workflow() %>%
  vetiver_model(model_name = "lego-sets")

v

# Write the model to the board
board %>% vetiver_pin_write(v)

# Verify the pinned model
vetiver_pin_read(board, name = "lego-sets")

# Generate Plumber API and Dockerfile
library(plumber)
vetiver_write_plumber(board, name = "lego-sets")
vetiver_write_docker(v)


#########################################################################################
# Can also use this if we don't to go the vetiver_write_plumber() route

# vetiver_prepare_docker(board, "lego-sets",
#                        docker_args = list(port = 8080))



# Next thing is to build the docker image and run the container:
# docker build -t lego_set_names .
# docker run --rm -p 8000:8000 lego_set_names

###########################################################################################

# Predict locally from your model endpoint

new_data <- lego_test %>% 
  select(-num_parts) %>% 
  slice_sample(n = 5)

endpoint <- vetiver_endpoint("http://0.0.0.0:8000")
endpoint

predict(endpoint, new_data)



# docker stop $(docker ps -a -q)












