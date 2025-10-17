# User Adoption Prediction Report



## Synopsis

Identify factors that predict whether a user becomes "adopted", defined as logging in on 3 separate days within a 7-day window. My findings show that three factors play the biggest role in user's login behavior. While `being in a mailing list` and `enablement for marketing drip` positively affect user's login frequency, having receieved an `invitation` to join has an adverse effect.



## Features

The data was aggregated into time frames of 7 days (1 week). The list of adopted versus non-adopted users was then extracted and assigned a binary code of 1 and 0, respectively. The information about invitations was used to also create a binary classification of whether the user was invited or not, encoded with 1 and 0, respectively. The inconsequential features, e.g. user name, were removed before modeling. 


## Models

Two logistic regression models were trained on 1) all available features, and 2) reduced feature set, determined by looking at coefficients, listed below: 

| Feature                              | Coefficient | Interpretation                                                     | Kept in Model 2|
|:-------------------------------------|:------------|:-------------------------------------------------------------------|:---------------|
| `invited`                            | **–0.85**   | Strong **negative** impact on adoption likelihood                  | Yes|
| `opted_in_to_mailing_list`           | +0.64       | Users who opted in are **more likely** to adopt                    | Yes|
| `creation_source_SIGNUP`             | –0.39       | Self-signups are **less likely** to adopt                          | Yes|
| `creation_source_ORG_INVITE`         | –0.35       | Surprisingly, org-invited users are **less likely** (in your data) | Yes |
| `creation_source_SIGNUP_GOOGLE_AUTH` | –0.34       | Google-auth users slightly less likely to adopt                    | Yes |
| `enabled_for_marketing_drip`         | +0.30       | Being in the drip campaign **slightly increases** adoption odds    | Yes | 
| `creation_source_PERSONAL_PROJECTS`  | –0.02       | No meaningful effect                                               | No|


### Model Comparison and Selection

| Metric          | Class | Model 1      | Model 2      | Better Model          |
|-----------------|-------|--------------|--------------|----------------------|
| **Precision**   | 0     | 0.87         | 0.87         | Tie                  |
|                 | 1     | 0.95         | 0.96         | Model 2              |
| **Recall**      | 0     | 1.00         | 1.00         | Tie                  |
|                 | 1     | 0.21         | 0.20         | Model 1              |
| **F1-Score**    | 0     | 0.93         | 0.93         | Tie                  |
|                 | 1     | 0.35         | 0.34         | Model 1              |
| **Accuracy**    | -     | 0.87         | 0.87         | Tie                  |


Having the business interests in mind, since preciting adopters is more important, we prioritize **recall** over **precision**, assuming missing adopters is costly. The confusion metrix for the two models supports this decision, with model being able to predict TP better than Model 2 (77 vs. 74).  

![cm](cm.png)

