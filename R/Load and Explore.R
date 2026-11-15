library(tidyverse)
library(here)
library(survival)

apps <- read_csv(here("Data", "Cleaned", "cleaned_solar_data.csv"),
                 col_types = cols(ref_id = col_character(),
                                  submitted_date = col_date(), first_decision_date = col_date(),
                                  end_date = col_date(),
                                  time_first_days = col_integer(), time_final_days = col_integer(),
                                  event_first = col_integer(), event_final = col_integer(),
                                  storage_colocated = col_character(), reapplying = col_character(),
                                  inactive_flag = col_character(),
                                  .default = col_guess())) |>
  mutate(across(c(storage_colocated, reapplying, inactive_flag), \(x) x == "True"))
apps
glimpse(apps)
nrow(apps)
count(apps,event_first)
count(apps,event_final)
