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

We intend to use airline passenger satisfaction survey data to determine which factors drive customer satisfaction (or dissatisfaction) so that we can provide actionable recommendations on how money should be invested or re-allocated to keep passengers satisfied. Customer satisfaction is a key factor in attracting and retaining business.

## Business Justification/ Impact

The airline industry has undergone significant changes with the emergence of hybrid business models, blurring the line between full-service and low-cost carriers, and facing financial difficulties stemming from mismanagement or external factors like fluctuating oil prices. To thrive in this competitive landscape, enhancing air passenger satisfaction is crucial for companies as it can positively impact both revenues and costs:
- Firstly, airlines can strive for operational efficiency while addressing individualized customer needs to elevate satisfaction levels and minimize unnecessary expenditures, offering better "value for money."
- Secondly, boosting customer satisfaction leads to reduced customer churn and improved loyalty. Estimates suggest that a mere 5% increase in customer retention can boost profits by 25%-95% (Reichheld and Sasser). Analyzing key factors that influence customer satisfaction enables airlines to identify specific areas for improvement that can reduce customer churn and ultimately lead to higher profitability.
- Lastly, enhancing customer experience contributes to building a strong brand image and reputation in marketing. When passengers have positive experiences, they are more inclined to share them through word of mouth and social media, thereby attracting new passengers and further bolstering the airline's success.

## Research questions

Our primary research question (RQ) was: What are the most important factors in ensuring that an airline passenger is satisfied? Other supporting research questions are detailed in the final report.

## Hypotheses

Our first hypothesis was that certain factors would have a significant impact on passenger satisfaction while others may not. The following factors had been predicted as the most significant: flight distance, inflight wifi service, departure/arrival time convenience, food and drink, seat comfort, inflight entertainment, on-board service, legroom service, inflight service, departure delays in minutes, and arrival delays in minutes. Additionally, we hypothesized that the relevance of these factors will vary depending on the class, type of travel, demographic factors (e.g., age, gender), and flight distance.

## Methodology/ Approach

![Approach Visualization](Visualizations/Approach.png)

Our methodology encompassed the following steps. First, we split the data set into training, validation, and testing sets (60/20/20). After performing data cleaning operations, we conducted Exploratory Data Analysis (EDA) to gain insights into the data set's characteristics.

Secondly, we narrowed down the focus of our modeling to: i) Logistic Regression, ii) Decision tree, iii) Random Forest, and iv) Support Vector Machines (SVM). For logistic regression, we systematically tested variables individually, assessed their distributions, and considered transformations if needed. In the case of decision trees, we constructed a hierarchical structure that enables effective prediction and interpretation. Random forests were utilized to evaluate feature importance, while SVM underwent cross-validation for accuracy assessment.

Thirdly, throughout the analysis, we interpreted the results of each model, examined the significance of variables and drew conclusions regarding their impact on passenger satisfaction. We compared the performance of different models based on evaluation metrics, such as accuracy and Receiver Operating Characteristic (ROC) curve and computing the Area Under the Curve (AUC). Additionally, we considered insights gained from EDA and statistical tests to support our conclusions.

Finally, upon selecting the most suitable model, we interpreted its predictions and drew conclusions regarding the factors contributing to passenger satisfaction. We considered the overall model performance and the importance of different features in influencing satisfaction levels. By following this methodology (detailed in Appendix 4), we aimed to gain a comprehensive understanding of the data set, select the most appropriate model, interpret its results, and draw meaningful conclusions about the factors affecting air passenger satisfaction.


## Overview of data

**Overview of data sets**

Datasets are hosted on Google Drive, accessible through this [link](https://drive.google.com/drive/folders/1i76FItono3U5ceE9Qc41XzybLqQZdXys?usp=sharing)

Our primary data set is taken from surveys from a US airline and is publicly available on Kaggle. It includes user ratings for multiple aspects of air travel, such as food and drink and seat comfort, as well as customer information, such as age and gender. It contains 24 features (see details in Appendix 1) and is made of 2 different files of 103,904 (train.csv) and 25,976 records (test.csv).

We initially intended to use other sources of data in relation to the business problem, but after in-depth analyses, we concluded that i) merging with our primary data set was impossible, or ii) conducting a parallel analysis of customer satisfaction was not feasible for the identified data sets:

- ACSI data set, containing customer satisfaction scores for 4 industries, incl. airline industry
- Flight route data set, containing flight route information and airport code
- External data source: World Happiness Report

## Work Cited and References

- Pereira, J. M., Oliveira, E., & Pacheco, A. G. (2023). Using Text Mining to Analyze Airline Passenger Reviews and Identify Critical Features Influencing Satisfaction. *Journal of Airline Customer Satisfaction*, 12(3), 54-68.

- Lucini, C., Ponti, M., & Artuso, A. (2020). Airline Customer Satisfaction: A Topic Modelling Approach to Identify Key Drivers. *Journal of Airline Management*, 18(4), 213-228.

- Ouf, R., & Abdulgader, A. M. (2023). Optimized Deep Learning Analysis for Predicting Airline Passenger Satisfaction. *International Journal of Artificial Intelligence and Machine Learning*, 8(2), 76-89.
