use airbnb;
select * from airbnb;

/*Find total number of listings in each country.*/
select country, count(*) as Total_listings
from airbnb
group by country
order by Total_listings desc;
/* So, there is only one country that is United States*/


/*Count how many hosts are verified vs not verified*/
select host_identity_verified, count(*) as Total_hotes
from airbnb
group by host_identity_verified;


/*Find average price per room type.*/

select room_type, avg(price) as Avg_Price
from airbnb
group by room_type;


/*Get top 10 neighbourhoods with highest number of listings.*/

select neighbourhood, count(*) as Total_listings
from airbnb
group by neighbourhood
order by Total_listings desc
limit 10;

/*					Pricing Insights
What is the average price by neighbourhood group?

Find listings where price is higher than average price of that neighbourhood.

Identify top 5 most expensive listings.*/


#What is the average price by neighbourhood group
select neighbourhood_group, avg(price) as Avg_Price
from airbnb
group by neighbourhood_group;

#Find listings where price is higher than average price of that neighbourhood
select * 
from airbnb a
where price > (select avg(price) from airbnb
where neighbourhood = a.neighbourhood
);

#Identify top 5 most expensive listings.
select *
from airbnb
order by price
limit 5;

/*			Availability Analysis

Find listings with availability > 300 days.

Which hosts have the highest availability listings?

Average availability per room type.*/

#Find listings with availability > 300 days.
select * 
from airbnb
where availability_365 > 300;

#Which hosts have the highest availability listings?
select *
from airbnb
order by availability_365
limit 20;


# Average availability per room type
select room_type, avg(availability_365) as Avg_Availability
from airbnb
group by room_type;

/*			Host Performance Analysis

Find top 10 hosts with highest total listings.*/


# Find top 10 hosts with highest total listings
select host_name, host_id, count(*) as Total_listings
from airbnb
group by 1,2
order by Total_listings
limit 10;


# Find the top 5 most expensive listings in NYC (neighbourhood_group = 'Brooklyn') with instant_bookable = 't'.
select name,price, neighbourhood,host_name
from airbnb
where neighbourhood_group = 'Brooklyn' and instant_bookable = 'True'
order by price desc
limit 5 ;

# Calculate average price and review rate by room_type and country_code for listings with >10 reviews.
select room_type,country_code, avg(price) as Avg_Price, avg(review_rate_number) as Avg_Review
from airbnb
where number_of_reviews > 10
group by room_type,country_code
having Avg(price) > 100
order by avg(price) desc;

# Which hosts have the highest total revenue potential (price * availability_365 * minimum_nights) for entire homes?
select host_name, host_id,
sum(price * availability_365 * minimum_nights) as Revenue
from airbnb
where room_type = 'Entire home/apt'
group by host_name, host_id
order by Revenue desc
limit 20;

										# Window Functions
# Rank neighbourhoods by average price within each neighbourhood_group, showing top 3 per group.
select *
from(select 
			neighbourhood_group,
            neighbourhood,
			avg(price) as Avg_Price,
			row_number() over(
				partition by neighbourhood_group
				order by avg(price) desc
			) as Price_Rank
		from airbnb
		group by neighbourhood_group, neighbourhood
) as Rank_Data
having Price_Rank <= 3 ;

# Month‑on‑month price change using LAG
SELECT 
    neighbourhood,
    month,
    Avg_Price,
    LAG(Avg_Price) OVER (
        PARTITION BY neighbourhood
        ORDER BY month
    ) AS Prev_Month_Avg_price
FROM (
    SELECT 
        neighbourhood,
        DATE_FORMAT(last_review, '%Y-%m-01') AS month,
        AVG(price) AS Avg_Price
    FROM airbnb
    WHERE last_review IS NOT NULL
    GROUP BY neighbourhood, DATE_FORMAT(last_review, '%Y-%m-01')
) AS t
ORDER BY neighbourhood, month;

 /*Hosts with unusually high average price in neighbourhood
Question:
For each host id in each neighbourhood, compute the host’s average price and compare it 
with the overall average price in that neighbourhood; return only those hosts whose average 
price is more than 20% above the neighbourhood average.
*/
with host_neigh_stats as (select host_id,neighbourhood,
avg(price) as Host_Avg_Price,
avg(Price) over(
partition by neighbourhood
) as neigh_avg_price
from airbnb
group by host_id, neighbourhood
)




