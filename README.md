# MGT 6203 Group Project Final Report - Summer 2023

## Team 6: Predicting Customer Satisfaction in the Airline Industry

**Members:** 
- Joshua Farina (joshuapfarina)
- Henri Salomon (henri_salomon)
- Raajitha Middi (Raajitha_Middi)
- Ryan Chandler (zujin87)
- Alejandro Martinez (amzeta)

## Introduction/Background/Motivation

## Objective/ Problem statement

We intend to use airline passenger satisfaction survey data to determine which factors drive customer satisfaction (or dissatisfaction) so that we can provide actionable recommendations on how money should be invested or re-allocated to keep passengers satisfied. Customer satisfaction is a key factor in attracting and retaining business. Identifying factors that have the strongest effect on customer satisfaction will provide key insights for airlines to enhance their services, improve the customer experience, and optimize business operations.

## Business Justification/ Impact

The airline industry has undergone significant changes with the emergence of hybrid business models, blurring the line between full-service and low-cost carriers, and facing financial difficulties stemming from mismanagement or external factors like fluctuating oil prices. To thrive in this competitive landscape, enhancing air passenger satisfaction is crucial for companies as it can positively impact both revenues and costs:
- Firstly, airlines can strive for operational efficiency while addressing individualized customer needs to elevate satisfaction levels and minimize unnecessary expenditures, offering better "value for money."
- Secondly, boosting customer satisfaction leads to reduced customer churn and improved loyalty. Estimates suggest that a mere 5% increase in customer retention can boost profits by 25%-95% (Reichheld and Sasser). Analyzing key factors that influence customer satisfaction enables airlines to identify specific areas for improvement that can reduce customer churn and ultimately lead to higher profitability.
- Lastly, enhancing customer experience contributes to building a strong brand image and reputation in marketing. When passengers have positive experiences, they are more inclined to share them through word of mouth and social media, thereby attracting new passengers and further bolstering the airline's success.

## Research questions

Our primary research question (RQ) was: What are the most important factors in ensuring that an airline passenger is satisfied? Other supporting research questions were:
- Does grouping variables by category (demographics, in-flight service quality, timeliness, and delays) provide additional insight?
- Can we predict airline passenger satisfaction based on a limited set of factors?
- Do characteristics that would imply a higher level of service (business class) result in higher levels of satisfaction?
- Are there any noteworthy interactions that would affect the probability of a satisfied customer?

## Hypotheses

Our first hypothesis was that certain factors would have a significant impact on passenger satisfaction while others may not. The following factors had been predicted as the most significant: flight distance, inflight wifi service, departure/arrival time convenience, food and drink, seat comfort, inflight entertainment, on-board service, legroom service, inflight service, departure delays in minutes, and arrival delays in minutes. Additionally, we hypothesized that the relevance of these factors will vary depending on the class, type of travel, demographic factors (e.g., age, gender), and flight distance.

## Methodology/ Approach

Our methodology encompassed the following steps. First, we split the data set into training, validation, and testing sets (60/20/20). After performing data cleaning operations, we conducted Exploratory Data Analysis (EDA) to gain insights into the data set's characteristics.

Secondly, we narrowed down the focus of our modeling to: i) Logistic Regression, ii) Decision tree, iii) Random Forest, and iv) Support Vector Machines (SVM). For logistic regression, we systematically tested variables individually, assessed their distributions, and considered transformations if needed. In the case of decision trees, we constructed a hierarchical structure that enables effective prediction and interpretation. Random forests were utilized to evaluate feature importance, while SVM underwent cross-validation for accuracy assessment.

Thirdly, throughout the analysis, we interpreted the results of each model, examined the significance of variables and drew conclusions regarding their impact on passenger satisfaction. We compared the performance of different models based on evaluation metrics, such as accuracy and Receiver Operating Characteristic (ROC) curve and computing the Area Under the Curve (AUC). Additionally, we considered insights gained from EDA and statistical tests to support our conclusions.

Finally, upon selecting the most suitable model, we interpreted its predictions and drew conclusions regarding the factors contributing to passenger satisfaction. We considered the overall model performance and the importance of different features in influencing satisfaction levels. By following this methodology (detailed in Appendix 4), we aimed to gain a comprehensive understanding of the data set, select the most appropriate model, interpret its results, and draw meaningful conclusions about the factors affecting air passenger satisfaction.

## Literature review

In our research project, we reviewed several relevant research papers. Pereira et al. (2023) used a text mining tool to analyze written reviews and identified the critical features influencing passenger satisfaction. They found that staff behavior, employee attitude towards dissatisfied customers, booking and cancellation policies, baggage handling, seat quality, boarding, check-in, customer service, and food and drink were important factors. Their study concluded that the COVID-19 pandemic increased the importance of cleanliness and refunds, which is not applicable to our pre-pandemic data set.

Another study by Lucini et al. (2020) used Latent Dirichlet Allocation to analyze customer reviews and found similar factors to be influential, including cabin staff, onboard service, value for money, and seats. They also highlighted the importance of segmentations such as nationality and cabin flown. The practical implications to maximize customer satisfaction by cabin flown are: focus on customer service for first class passengers, comfort for premium economy passengers, and checking luggage and waiting time for economy class travelers).

Lastly, Ouf (2023) conducted an optimized deep learning analysis using the same data set we are using. They found that factors such as online boarding, class, type of travel, and in-flight entertainment were important.

It is worth noting that our data set may have limitations, as critical factors such as cabin crew quality were not considered and there may be biases due to customers not taking the questionnaires seriously. Incorporating approaches like text mining could enhance our understanding of passenger satisfaction by capturing a wider range of factors and reducing noise in the data.

## Overview of data

**Overview of data sets**

Our primary data set is taken from surveys from a US airline and is publicly available on Kaggle (see details in 7. Work cited and reference). It includes user ratings for multiple aspects of air travel, such as food and drink and seat comfort, as well as customer information, such as age and gender. It contains 24 features (see details in Appendix 1) and is made of 2 different files of 103,904 (train.csv) and 25,976 records (test.csv).

We initially intended to use other sources of data in relation to the business problem, but after in-depth analyses, we concluded that i) merging with our primary data set was impossible, or ii) conducting a parallel analysis of customer satisfaction was not feasible for the identified data sets:

- ACSI data set, containing customer satisfaction scores for 4 industries, incl. airline industry
- Flight route data set, containing flight route information and airport code
- External data source: World Happiness Report

## Insights from exploratory data analysis

- **Correlation Analysis**: Our correlation matrix helped identify variables that were strongly correlated with passenger satisfaction. Flight distance and the delay variables (departure and arrival) were negatively correlated, indicating that longer flights and higher delays were associated with lower passenger satisfaction.

- **Data Visualization**: Visualization helped identify patterns and trends in the data set. We discovered that passenger satisfaction was higher for shorter flight distances and early departure/arrival times. Additionally, customers who faced longer departure and arrival delays reported lower satisfaction levels.

- **Distribution of Numeric Variables**: We observed that most of the numeric variables exhibited a relatively normal distribution, with slight skewness for some variables. The departure and arrival delay variables had a positive skewness, indicating that delays were less frequent.

- **Relationships between Categorical Variables and Satisfaction**: We examined relationships between categorical variables and customer satisfaction using bar plots. Business class passengers generally exhibited higher satisfaction levels compared to economy class passengers. Similarly, there were differences in satisfaction levels based on customer type (solo, business, couple, family, etc.).

## Overview of modeling

- **Model Selection**: We evaluated four different models: Logistic Regression, Decision Tree, Random Forest, and SVM. After comparing the models based on AUC on the validation set, Logistic Regression with forward selection achieved the highest AUC and was selected as the best model to predict air passenger satisfaction.

## Discussion & Interpretation of Results

Our analysis revealed several insights and answers to our research questions. Notably, technology-related factors (e.g., online boarding and in-flight wifi service) play a significant role in passenger satisfaction. Business class passengers generally exhibit higher satisfaction levels, and certain factors have varying impacts based on the class, type of travel, and demographics.

## Conclusion and Key Takeaways

The research project's findings provide airlines with valuable insights into enhancing passenger satisfaction and improving overall business performance. Investments in customer-facing technology, especially in-flight wifi service and online boarding, can lead to higher customer satisfaction and loyalty. Understanding the preferences and expectations of different customer segments can also help airlines tailor their services for maximum impact.

## Further Research

Further research could focus on addressing multicollinearity issues observed in the logistic regression model and exploring methods such as feature selection or dimensionality reduction to enhance model interpretability. Analyzing additional data sources, such as airport passenger surveys or online reviews, could provide a more comprehensive understanding of passenger satisfaction and identify factors beyond the scope of our current data set.

## Work Cited and References

- Pereira, J. M., Oliveira, E., & Pacheco, A. G. (2023). Using Text Mining to Analyze Airline Passenger Reviews and Identify Critical Features Influencing Satisfaction. *Journal of Airline Customer Satisfaction*, 12(3), 54-68.

- Lucini, C., Ponti, M., & Artuso, A. (2020). Airline Customer Satisfaction: A Topic Modelling Approach to Identify Key Drivers. *Journal of Airline Management*, 18(4), 213-228.

- Ouf, R., & Abdulgader, A. M. (2023). Optimized Deep Learning Analysis for Predicting Airline Passenger Satisfaction. *International Journal of Artificial Intelligence and Machine Learning*, 8(2), 76-89.

## Appendix

**Appendix 1: Overview of Data Sets**

**Appendix 2: Details of Variables**

**Appendix 3: Model Evaluation Metrics**

**Appendix 4: Detailed Methodology**

**Appendix 5: Code Snippets**

**Appendix 6: Model Interpretation**

**Appendix 7: Detailed EDA Analysis**

**Appendix 8: Supplementary Figures and Tables**
