# Data Science Solar with Cox
- Time to planning consent for GB solar farms
- Scope: =>5MW ground mount solar farms in Great Britain
- Question: How long do ground mounted solar farms wait for planning consent and what factor is linked to faster grants
- Data Source: Renewable Energy Planning Database(REPD) from DESNZ, all data from Open Government License,cut- off date: 4 Aug 2026

- Detailed result:REPORT.md
- Please see detailed decision making for data cleaning in notes of Python script

# Methodology
- Kaplan- Meier plot for description
- Cumulative incidence with Gray's test
- Cause- specific cox model(permission granted as outcome), final model uses log capacity, planning route, and country, standard error clustered by planning authority.
- Two models fitted for first decision and final outcome(final outcome includes appeal)
- Checks Sheonfeld residuals, and analyse sensitiving by trying to exclude the suspected inactive records

# Key findings
- Only about 28% of applications had a decision within the first 16 weeks, 72% of application receive their first decision within the first 50 weeks.
- National route projects are slower at first but more likely to be granted by 24 months(84% for national, 66% comparing to local route)
- At the 24th months, 20% of applications are refused in the first decision, but only 13% remained as refused once appeal is counted, meaning one third of the refusal does not end up as refusal due to appeal

# Key files in Repo
- Data/Raw: Raw Data as csv
- Data/Cleaned/cleaned_solar_data.csv: Cleaned data as csv
- Python/Python_data_cleaning.ipynb:Cleaning: applying exclusion criteria,outcome coding,date coding
- R/Load and Cox model.R:Kaplan- Meier,cif, Cox model (consented as outcome)
- Outputs/Figures:KM plots,cif plots(National and Local decisions)
- REPORT.md: findings

# Reproduce
- Python: `conda env create - f environment.yml`, then run the notebook top to bottom. 
- R: open the `.Rproj` file, run `renv::restore()`, then run the R script.

