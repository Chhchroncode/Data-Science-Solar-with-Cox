# How long does a solar farm wait for planning consent
- Survival analysis with data set of 2311 from REPD, submitted from 2010 to 2026
# Key Findings
- Most decision takes longer than the statutory period:
- About 19% applications have a decision within 13 weeks,and 28% within 16 weeks, which is usually the statutory time for planning application to be granted.Showing delays in the planning system.
- Note that authorities have mechanisms to 'stop the clock', total decision time exceeding statutory period does not directly imply violation of government guidance.

- National projects start slowly, then catch up:
- By 12 months, 14% of national applications had been granted with 55% local application granted
- By 24 months, 84% of the national projects has be granted comparing to 66% of local projects.
- National scale projects are rarely refused (5%) and never withdrawn

- Larger projects and granted more slowly:
- Accounting for other factors like planning route and country. Capacity MW is a strong variable for consenting time
- Doubling the capacity is linked to 36% lower grant rate at the first decision, and at the latest deicison 30% lower(based on log MW (natural log))
- It is the strongest variable relating to consent time in this project

# Figures
- Outputs/Figures:
- km_first_decision.png and km_latest_decision.png (time to first and latest outcome)
- cif_route_plot.png (outcomes by route)

# Please see scope in READ_ME.md

# Method
- kmplot: 2 plots,First decision and final decision overtime
- Cumulative incidances: probability of three outcomes(grant, refusion and withdrawal)(coded as 0,1,2,3,0 as no decision yet)Gray'stest compares local and national routes
- Cause- specific  cox model for grant:refused, withdrawn and pending applications leave the risk set at their own time.
- Variables in final model: log capacity (natural log, HR scale converted), route (local, national), country
- Standard errors clustered by planning authority
- two models: first decision and final outcome
- checking proportional hazard with shoenfeld residuals and sensitivity analysis excluding suspected inactive records

- Cox model results

| | First decision HR (95% CI) | Final outcome HR (95% CI) |
|- - - |- - - |- - - |
| Capacity (per doubling) | 0.64 (0.61–0.68) | 0.70 (0.67–0.73) |
| National vs Local route | 1.50 (0.97–2.30) | 1.37 (0.91–2.06) |
| Scotland vs England | 1.09 (0.66–1.82) | 1.17 (0.68–2.00) |
| Wales vs England | 0.79 (0.58–1.07) | 0.90 (0.68–1.19) |

- Only capacity has p value lower than.05. Concordance of the two models are 0,68 ad 0,66, moderately good fit for data.
- Route and country do not have a clear effect on consenting time, CI includes 1
- Counting appeals weaken the capacity effect slightly
- Proportional hazard: the assumption did not hold for 'capacity' and 'route', their hazard ratio should be seen as averages over time. 'Country' met the assumption
- Adding and removing suspected inactive records does not greatly change model and hazard ratio

# Limitations and Next Step
- Capacity and route violate proportional hazard assumption (see above)
- THere are few deicions makers for national route, most are PINS or Scottish and Welsh gov, the route variable rests of few clusteres
- REPD data quality may be low, especially in identifying colocation with batteries, likely underestimating
- Stale pending records may not be truly active projects
- Could consider using separate models for refusal and withdrawal, time- varying effects to take account of variable with non- proportional hazard. Consider using multi state models for appeals

#Key Implications
- For developers
- A local application has about 50% chance to be granted within a year
- A national application is rarely refused and is very likely to be granted within two years
- Appeal system has a strong effect of changing one third of the initial refusal to other decisions
- Take this into account for timeline planning within project management, as well as prepare in advance for schemes and processes such as grid connection and cfd with expected consent time within 1 and 2 years
- For policy makers
- Most decisions fall outside the statutory period, reflecting delays in the planning pipeline system.
- Consider increasing and ringfencing human and financial resource for planning department