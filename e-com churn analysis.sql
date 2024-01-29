--The main steps for this project are:

-- Data Cleaning and Preparation
-- Exploratory Data Analysis
-- Building the Ideal Churn Profile
-- Data Insights
-- Customer Retention Strategies
-- Data Visualisation

SELECT TOP (1000)*
  FROM [e-ommercce data ].[dbo].[telecom_customer_churn]


-- Data Cleaning and Preparation

select Customer_ID, count(Customer_ID) from [e-ommercce data ].[dbo].[telecom_customer_churn] group by Customer_ID having count(Customer_ID) > 1
-- No duplicates

-- Exploratory Analysis

-- Q1. How much revenue was lost to churned customers?
with a as(
SELECT Customer_Status, round(sum(Total_Revenue),2) as Total_Revenue, COUNT(Customer_ID) cnt_Customer_ID
  FROM [e-ommercce data ].[dbo].[telecom_customer_churn] group by Customer_Status)

  
select round(Total_Revenue * 100.0/(select sum(Total_Revenue) from a),2) as total_percent
  from a where Customer_Status = 'churned'

-- Maven experienced a loss of 1869 customers, constituting 17% of the total revenue.
-- This substantial figure prompts further investigation into the reasons behind their departure, a topic we will delve into later in this article.

-- Q2. What’s the typical tenure for churned customers?
with b as(
select 

case when Tenure_in_Months <= 6 then '6 Months'
when Tenure_in_Months <= 12 then '1 year'
when Tenure_in_Months <= 24 then '2 years'
else '> 2 year'
end as [Tenure], Customer_Status from [e-ommercce data ].[dbo].[telecom_customer_churn] where Customer_Status = 'Churned'),
c as (

select Tenure, COUNT(Customer_Status) as cnt
 from b group by Tenure)

select Tenure, cnt, round(cnt * 100.0 /sum(cnt) over(),2) as percentage from c 


-- In order to determine the average duration of customer engagement with Maven before departure, I employed the CASE statement in SQL. 
-- This statement generated a derived column (Tenure) categorizing customers who exited the company within 12 months or less as '12 months,' and so on.

--The analysis revealed that approximately 42% of customers who churned spent 6 months or less at Maven before leaving.

--The observation that nearly half of the departing customers had a relatively brief tenure suggests potential opportunities for Maven to enhance customer retention,
--particularly among newer customers.


-- Q3. Which cities had the highest churn rates?
with d as(
SELECT
    City,
    COUNT(Customer_ID) AS Churned
FROM [e-ommercce data ].[dbo].[telecom_customer_churn]
where Customer_Status = 'Churned'
GROUP BY
    City), e as

(select	City, count(Customer_ID) as total_customers from [e-ommercce data ].[dbo].[telecom_customer_churn] group by City)

select d.City, d.churned, round(churned *100.0/e.total_customers,2) as churn_rate

from d left join e on d.city = e.city where churned > 20 order by churn_rate desc


-- Churn rate measures the percentage of customers who stop using the services of a company over a certain period of time.
-- For the purpose of this analysis, I only considered cities with more than 30 customers in total, 
-- because some cities had very few customers and my conclusion would have been biased towards them.
-- San Diego had the highest churn rate at 65%, which means that over half of their customers have left the company.

-- Q4 What are the general reasons for churn?
select Churn_Category, count(Customer_ID) as cnt, ceiling(sum(Total_Revenue)) as churned_revenue,
ceiling(count(Customer_ID) *100.0/(select count(*) from [e-ommercce data ].[dbo].[telecom_customer_churn] where Customer_Status = 'Churned')) as churn_percentage  
from [e-ommercce data ].[dbo].[telecom_customer_churn]
where Customer_Status = 'Churned'
group by Churn_Category 
 order by churn_percentage desc

 -- A notable 45% of customers who churned mentioned 'Competitor' as their reason for leaving. 
 -- Additionally, it is intriguing to observe that a substantial proportion (17%) departed due to dissatisfaction with the attitude of the support staff.
 -- Notably, Maven incurred a significant financial loss of approximately $1.7 million attributed to customers switching to competitors, rendering it the costliest form of churn.

 --Q5a Specific reasons for churn

 select top 5 Churn_Reason, count(Churn_Reason) as cnt, ceiling(count(Churn_Reason)* 100.0/ (select count(*) from [e-ommercce data ].[dbo].[telecom_customer_churn] where Churn_Reason is not NULL))
 as churn_percent from [e-ommercce data ].[dbo].[telecom_customer_churn] where Churn_Reason is not NUll group by Churn_Reason order by churn_percent desc

 -- 5b. What offers did churned customers have?

 select offer, count(offer) as cnt, ceiling(count(offer) * 100.0/ (select count(*) from  [e-ommercce data ].[dbo].[telecom_customer_churn]  where Customer_Status = 'Churned')) as churn_percent
 from [e-ommercce data ].[dbo].[telecom_customer_churn] where Customer_Status = 'Churned' group by Offer order by cnt desc 
 --56% of churners did not have any promotional offer while 23% had Offer E. Offers are a great way to reward and retain your loyal customers.

 -- 5c. What internet type did churners have?

  select Internet_Type, count(Internet_Type) as cnt, ceiling(count(Internet_Type) * 100.0/ (select count(*) from  [e-ommercce data ].[dbo].[telecom_customer_churn]  where Customer_Status = 'Churned')) as churn_percent
 from [e-ommercce data ].[dbo].[telecom_customer_churn] where Customer_Status = 'Churned' group by Internet_Type order by cnt desc 

 -- 66% of all churned customers used Fiber Optic. While ~70% of customers who left for competitors also used Fiber Optic.
 -- Maven should review the quality and service of their Fiber Optic internet, as this could be the reason customers are leaving to competitors.


 -- 5d. Did churners have premium tech support?

   select Premium_Tech_Support, count(Premium_Tech_Support) as cnt, ceiling(count(Premium_Tech_Support) * 100.0/ (select count(*) from  [e-ommercce data ].[dbo].[telecom_customer_churn]  where Customer_Status = 'Churned')) as churn_percent
 from [e-ommercce data ].[dbo].[telecom_customer_churn] where Customer_Status = 'Churned' group by Premium_Tech_Support order by cnt desc 

 --78% of churned customers did not have premium tech support. It’s possible that this service could have improved their after-sales experience and reduced churn.

 -- 5e. What contract were churners on?

 select Contract, count(Contract) as cnt, ceiling(count(Contract) * 100.0/ (select count(*) from  [e-ommercce data ].[dbo].[telecom_customer_churn]  where Customer_Status = 'Churned')) as churn_percent
 from [e-ommercce data ].[dbo].[telecom_customer_churn] where Customer_Status = 'Churned' group by Contract order by cnt desc 

 -- Customers on a month-to-month contract are more likely to churn, as they have greater flexibility to cancel or switch providers without incurring any penalty.

 -- Q6. Are high value customers at risk of churning?

-- I defined high value customers based on these factors and grouped them into 3 risk levels (High, Medium, Low):
--Tenure: This is a measure of loyalty, so I only considered customers that have been with the company for at least 9 months.
--Monthly Charge: If the customer’s total monthly charge is in the top 50th percentile.
--Referrals: customers who refer other customers to the business.
--High-value customers with 3–4 churn indicators are High Risk, while Medium Risk customers have 2 and Low Risk customers have only 1.
 
 with f as (
 select *, percent_rank() over( order by Monthly_Charge desc) as prcnt  from  [e-ommercce data ].[dbo].[telecom_customer_churn] ),
 g as(
 select customer_id, sum(case when Tenure_in_Months >= 9 then 1 else 0 end) +
  sum(case when Number_of_Referrals >= 1 then 1 else 0 end) +
   sum(case when prcnt <= 50 then 1 else 0 end) 
    as no_of_conditions from f group by Customer_ID),
	h as(
	select case when no_of_conditions = 3 then 'High_risk'
	when no_of_conditions = 2 then 'Medium_risk'
	else 'low_risk' end as 'risk_type'
	from g)

	select risk_type, count(risk_type) as cnt, ceiling(count(risk_type) * 100.0/ (select count(*) from h)) as prcnt from h  group by risk_type

	-- High-value customers are churning at a rate of 41% which is a matter of concern.





