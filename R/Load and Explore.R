library(tidyverse)
library(here)
library(survival)
library(ggsurvfit)
library(ggplot2)
library(gtsummary)
library(tidycmprsk)

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

solar <- solar |>
  mutate(outcome_first = factor(outcome_first, levels = outcome_levels),
         outcome_final = factor(outcome_final, levels = outcome_levels),
stopifnot(!anyNA(solar$outcome_first), !anyNA(solar$outcome_final)))

table(solar$outcome_first)
table(solar$outcome_final)

#Descriptive of outcomes
solar|>
  select(outcome_first,country,capacity_mw,route_scale)|>
  tbl_summary(by=outcome_first)|>
  add_overall()

#DATA EXPLORATION
#Kaplan Meier Plot using first decision
km_first<-survfit2(Surv(time_first_days,event_first)~1,data=solar)
plot(km_first)
#Using week as unit for time, and grouping all events together
#First decision
km_first_week<-survfit2(Surv(time_first_days/7,event_first>0)~1,data=solar)
plot(km_first_week)

km_first_week_plot<-ggsurvfit(km_first_week,type='risk')+
  add_confidence_interval()+
  add_risktable()+
  labs(x='Weeks since application submitted',
       y='share of projects has received first decision')
km_first_week_plot
ggsave(here("Outputs", "Figures", "km_first_decision.png"), km_first_week_plot, width = 5, height = 5)


#Latest Decision
km_latest_week<-survfit2(Surv(time_final_days/7,event_final>0)~1,data=solar)
plot(km_latest_week)

km_latest_week_plot<-ggsurvfit(km_latest_week,type='risk')+
  add_confidence_interval()+
  add_risktable()+
  labs(x='Weeks since application submitted',
       y='share of projects has received latest decision')
km_latest_week_plot
ggsave(here("Outputs", "Figures", "km_latest_decision.png"), km_latest_week_plot, width = 5, height = 5)

#cif of all outcomes, by scale of consenting routes
solar$time_first_months <- solar$time_first_days / 30.4375
cif_route<-cuminc(Surv(time_first_months,outcome_first)~route_scale,data=solar)
cif_route

cif_route_plot<-ggcuminc(cif_route,outcome=c('Planning Permission Granted',
                                             'Planning Permission Refused',
                                             'Planning Application Withdrawn'))+
  add_confidence_interval()+
  labs(x='Months since application submitted',y='Cumulative Incidence')+
  guides(color = guide_legend(nrow = 3),
         linetype = guide_legend(nrow = 2))+
  theme(legend.box = "vertical",
        legend.text = element_text(size = 9))
cif_route_plot
ggsave(here("Outputs", "Figures", "cif_route_plot.png"), cif_route_plot, width = 5, height = 5)

#Comparing cif of first and final decisions
solar$time_final_months <- solar$time_final_days / 30.4375

outcomes_all <- c("Planning Permission Granted", "Planning Permission Refused",
                  "Planning Application Withdrawn")
cif_first<-cuminc(Surv(time_first_months,outcome_first)~1,data=solar)
cif_final<-cuminc(Surv(time_final_months,outcome_final)~1,data=solar)
tbl_cuminc(cif_first,time=c(12,24),outcomes = outcomes_all)
tbl_cuminc(cif_final,time=c(12,24),outcomes = outcomes_all)

#MODELLING
#Cox proportional hazards model
#Using consent granted as the target outcome (Event code=1)
#withdrawn and refused are not seen as outcome, but projects leave the model at their own time to show competing risks
#Use log capacity due to skewed capacity MW of projects
#Avoiding using multiple location related variables in the same model
#Due to frequent sharing of officers and change of reponsible areas, lpa are not exclusive to each other, treat as clusters

#First model, with first decision
#Trial 1
cox_first1<-coxph(Surv(time_first_days,event_first==1)~log_capacity_mw+storage_colocated+decision_route,data=solar,cluster=lpa)
summary(cox_first1)
#Concordance good
#Wide CI and especially low p-value for storage, noted that there are only 17 projects that are TRUE, drop storage variable
#Wide CI and especially low p-value for scotland session 26, noted low number of projects in some decision routes, use country and route_scale instead
#Trial 2
cox_first2<-coxph(Surv(time_first_days,event_first==1)~log_capacity_mw+route_scale+country,data=solar,cluster=lpa)
summary(cox_first2)

#Second model, with latest decision
#Trial 1
cox_final1<-coxph(Surv(time_final_days,event_final==1)~log_capacity_mw+storage_colocated+decision_route,data=solar,cluster=lpa)
summary(cox_final1)

cox_final2<-coxph(Surv(time_first_days,event_final==1)~log_capacity_mw+route_scale+country,data=solar,cluster=lpa)
summary(cox_final2)

glimpse(solar)
#Proportional hazard assumption check
#Scheonfeld residual
ph_first <- cox.zph(cox_first2)
ph_first
plot(ph_first)

ph_final <- cox.zph(cox_final2)
ph_final
plot(ph_final)

#Checcking inactive project sesnitivity of the models

cox_first2_active<-coxph(Surv(time_first_days,event_first==1)~log_capacity_mw+route_scale+country,data=filter(solar,!inactive_flag),cluster=lpa)
summary(cox_first2_active)

cox_final2_active<-coxph(Surv(time_first_days,event_final==1)~log_capacity_mw+route_scale+country,data=filter(solar,!inactive_flag),cluster=lpa)
summary(cox_final2_active)

#No large difference in p value, and HR after dropping inactive projects
tbl_merge(list(tbl_regression(cox_first2, exponentiate = TRUE),
               tbl_regression(cox_first2_active, exponentiate = TRUE)),
          tab_spanner = c("**All applications**", "**Inactive excluded**"))
tbl_merge(list(tbl_regression(cox_final2, exponentiate = TRUE),
               tbl_regression(cox_final2_active, exponentiate = TRUE)),
          tab_spanner = c("**All applications**", "**Inactive excluded**"))
