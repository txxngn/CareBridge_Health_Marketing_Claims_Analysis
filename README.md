# CareBridge Health – Marketing Performance & Claims Analysis


# Project Overview
CareBridge Health is a fictional U.S.-based medical insurance provider serving customers across multiple states. In 2019, the company launched a series of marketing campaigns focused on health awareness, affordability, preventative care, and customer engagement.

Customers can enroll in four plan types — Bronze, Silver, Gold, and Platinum — each offering different coverage and claim structures.

CareBridge Health recently hired a data analytics team to evaluate the effectiveness of these marketing campaigns and their relationship to customer signups and subsequent insurance claims. The company’s primary business objectives are:

1. Increase customer signups
2. Improve brand awareness
3. Optimize marketing budget allocation
4. Understand downstream impact on insurance claims

As a data analyst supporting CareBridge Health, this project delivers an interactive Tableau dashboard that enables the marketing and claims teams to self-serve insights and monitor campaign performance over time.

# Business Objective
The goal of this analysis is to evaluate marketing campaign performance and surface actionable recommendations for future budget allocation based on:
- Click-through performance
- Signup conversion rates
- Cost efficiency
- Customer claim behavior

# Business Objective
The dataset consists of three relational tables:
- **Campaigns**: campaign category, campaign type, cost, impressions, clicks
- **Customers**: customer ID, state, plan type, signup date, campaign attribution
- **Claims**: claim ID, claim date, claim category, claim amount, covered amount
Entity Relationship Diagram (ERD):
<img width="700" height="555" alt="image" src="https://github.com/user-attachments/assets/d49a3cf9-14e1-457a-8a78-c8cca3e38c85" />


# North Star Metrics
To evaluate campaign performance, the following key metrics were used:
- **Click Through Rate (CTR)**
- **Cost per Click (CPC)**
- **Signup Rate**
- **Cost per Signup**
- **Total Claim Amount**
- **Average Claim Amount**
- **Claim Count**

Overall performance across all campaigns:
- CTR: **9.39%**
- CPC: **$0.07**
- Signup Rate: **0.18%**
- Cost per Signup: **$3.70**
- Total Claims: **16,289 signups**
- Average Claim Amount: **$267**

## Key Insights
### Marketing Insights
- Health For All and Benefit Updates campaigns achieved CTRs nearly **3x higher** than the overall average.
- Golden Years Security recorded the lowest CTR (~1%) and the highest CPC ($0.68), indicating inefficient spend.
- Family Coverage Plan campaigns generated high impressions but nearly zero clicks, suggesting potential campaign or data quality issues.

### Signup Insights
- Health For All campaigns achieved the strongest signup rate (≈2%) and over **3,500 signups**, driven primarily by Health Awareness campaign types.
- #HealthyLiving generated the highest number of signups but maintained a relatively low signup rate (~0.3%), indicating high volume but weaker conversion efficiency.
- COVID-based campaigns showed abnormally high cost per signup, exceeding $1,000 per customer.

### Claims Insights
- Claim counts and claim amounts peaked in mid-2022 and have trended downward since early 2023.
- Compare Health Coverage generated the highest total claim amount ($3.9M) and the highest average claim amount (~$410), approximately 50% higher than the dataset average.
- Silver plan customers and customers from New Jersey accounted for the majority of total claims volume.

## Recommendations
- **Golden Years Security**: Consider discontinuing or redesigning this campaign due to low CTR and high cost per signup.
- **Health For All**: Increase investment, particularly in Health Awareness campaign types that demonstrate strong conversion performance.
- **Compare Health Coverage**: Collaborate with actuarial teams to assess whether this campaign attracts higher-risk customer profiles.
- **Family Coverage Plan**: Investigate missing or ineffective click activity.
- **COVID Campaigns**: Remove or restructure campaigns with abnormally high customer acquisition costs.

## Dashboard
The dashboard can be found in Tableau Public [here](https://public.tableau.com/app/profile/thai.nguyen4738/viz/carebridge_health_marketing_claims/carebridge_dashboard). This dashboard enables users to filter by plan, campaign type, and state, and focuses on trends and values in marketing metrics, signup metrics, and claim metrics.
The dashboard allows filtering by:
- Campaign category
- Campaign type
- Customer plan
- State
and visualizes:
- Marketing metrics
- Signup metrics
- Claim metrics
- Time-series trends
<img width="1410" height="1165" alt="image" src="https://github.com/user-attachments/assets/325ba8c7-2fbf-45a8-b52d-b038d7885743" />
  


## Presentation Sample
The presentation created for the marketing team walks through the insights and recommendations above and can be found [here](https://docs.google.com/presentation/d/1OsyEj8gVzfqCQnnH4MJGwAkyM7lLE_Zu/edit?usp=sharing&ouid=103634556289743709939&rtpof=true&sd=true). Some extracts are presented below for easy viewing.

<img width="973" height="655" alt="image" src="https://github.com/user-attachments/assets/98bc5fa0-58fa-4ed8-9db6-2ebb08186c0f" />
<img width="1293" height="698" alt="image" src="https://github.com/user-attachments/assets/abfb131a-c5b8-480a-9012-662e17379ca0" />
<img width="1158" height="651" alt="image" src="https://github.com/user-attachments/assets/0a58d87b-4f79-4665-8fea-39a934f73960" />
<img width="872" height="568" alt="image" src="https://github.com/user-attachments/assets/7ab26d6c-9762-494c-8d2f-c363c935925a" />


