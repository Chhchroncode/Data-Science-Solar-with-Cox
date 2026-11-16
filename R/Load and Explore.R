library(tidyverse)
library(here)
library(survival)

solar <- read_csv(here("Data", "Cleaned", "cleaned_solar_data.csv"),
                 col_types = cols(ref_id = col_character(),
                                  submitted_date = col_date(), first_decision_date = col_date(),
                                  end_date = col_date(),
                                  time_first_days = col_integer(), time_final_days = col_integer(),
                                  event_first = col_integer(), event_final = col_integer(),
                                  storage_colocated = col_character(), reapplying = col_character(),
                                  inactive_flag = col_character(),
                                  .default = col_guess())) |>
  mutate(across(c(storage_colocated, reapplying, inactive_flag), \(x) x == "True"))
solar
glimpse(solar)
nrow(solar)
count(solar,event_first)
count(solar,event_final)
table(solar$outcome_first, solar$outcome_final)

#Reformatting columns
#Boolean
solar$storage_colocated <- as.logical(solar$storage_colocated)
solar$reapplying        <- as.logical(solar$reapplying)
solar$inactive_flag     <- as.logical(solar$inactive_flag)

unique(solar$storage_colocated)
unique(solar$reapplying)
unique(solar$inactive_flag)


#Categories
cat_cols<-c('region','country','lpa','capacity_band','decision_route','route_scale')
for (cols in cat_cols) {
  print(solar|>count(.data[[cols]]))
}

max(solar$lpa)

solar<-solar|>
  mutate(
    country=fct_relevel(country,'England'),
    decision_route=fct_relevel(decision_route,'English_TCPA'),
    capacity_band  = factor(capacity_band,levels = c("5-9.99 MW", "9.99-49.99 MW", "49.99-99.99 MW", ">99.99 MW")),
    route_scale=fct_relevel(route_scale,'Local'))

levels(solar$country)
levels(solar$decision_route)
levels(solar$capacity_band)
levels(solar$route_scale)

#Outcome coding
outcome_levels <- c("Pending", "Planning Permission Granted",
                    "Planning Permission Refused", "Planning Application Withdrawn")
