##1. In which city and branch has more income without Tax?
select branch,city, round(sum(cogs),2) as total_price
from project.supermarket_sales
group by 1, 2
order by 3 desc;

##2. Who purchased more (men or women) and what is the percent of that without Tax?
with cte1 as 
(
  select gender, round(sum(cogs),2) as total_price
  from project.supermarket_sales
  group by 1
),
cte2 as
(
  select round(sum(cogs),2) as total_income
  from project.supermarket_sales
)
select *,
round((cte1.total_price/cte2.total_income)*100,2) as percentage_of_profit from cte1,cte2;

##3. What is the profit of normal and member customer_type without Tax?
select Customer_type, round(sum(cogs),2) as total_price
from project.supermarket_sales
group  by 1;

##4. What is the profit of normal and member customer_type of different gender without Tax?
select Customer_type,gender, round(sum(cogs),2) as total_price
from project.supermarket_sales
group  by 1,2
order by 1,3 desc;

##5. Which product_line is more profit for us without Tax?
select Product_line, round(sum(cogs),2) as total_price
from project.supermarket_sales
group by 1
order by 2 desc;

##6. What is the percent of sold product_Line without Tax?
with cte1 as 
(
  select Product_line, round(sum(cogs),2) as total_price
  from project.supermarket_sales
  group by 1
),
cte2 as
(
  select round(sum(cogs),2) as total_income
  from project.supermarket_sales
)
select cte1.product_Line, cte1.total_price,
round((cte1.total_price/cte2.total_income)*100,2) as percentage 
from cte1, cte2
order by 3 desc;

##7. Comparison of with and without tax ?
select branch,city, round(sum(Total),2) as With_tax_total_price,
round(sum(cogs),2) as no_tax_total_price
from project.supermarket_sales
group by 1, 2
order by 3 desc;

##8. What is the profit % in tax?
with cte1 as 
(
  select branch,city, round(sum(Total),2) as With_tax_total_price,
  round(sum(cogs),2) as no_tax_total_price, 
  round((sum(Total)-sum(cogs)),2) as profit_in_tax
  from project.supermarket_sales
  group by 1, 2
)
select * , 
round((cte1.profit_in_tax/(select sum(cte1.profit_in_tax) from cte1))*100,2) as profit_percent_in_tax
from cte1;

##9. Which month sales are high?
select extract(year from date) as year, extract(month from date) as month,
round(sum(cogs),2) as total_sales
from project.supermarket_sales
group by 1,2
order by 3 desc;

##10. Which date income is high?
select date,round(sum(cogs),2) as total_sales
from project.supermarket_sales
group by 1
order by 2 desc,1;

##11.During what time of the day, do the customers mostly place their orders? ( Morning, Afternoon or Night)
#10-13 hrs : Mornings
#13-17 hrs : Afternoon
#17-21 hrs : Night
select branch,city, 
case
    when time between '10' and '13'
    then 'Mornings'
    when time between '13' and '17'
    then 'Afternoon'
    else 'Night'
end as time_of_the_day,
count(*) as orders_count
from project.supermarket_sales
group by 1,2,3
order by 1,4 desc;

##12. Payment_type
select Payment,count(*) as no_of_customers
from project.supermarket_sales
group by 1
order by 2 desc;

##13. How many of them promote and detracte their shopping in supermarket ?
select 
case 
    when Rating >= 9
    then 'Promoters'
    when Rating < 7
    then 'Detractors'
    else 'No Comments'
end as Level,
count(*) as number_of_customers
from project.supermarket_sales
group by 1;

##14. Month on month orders in each state ?
select extract(year from date) as year, extract(month from date) as month,
city, count(*) as total_purchases
from project.supermarket_sales
group by 1,2,3
order by 1,2,4 desc;

##15. Increase in cost per month and percent of profit and loss ?
select t1.month, t1.price, t1.increase_by_month, 
ifnull(round((t1.increase_by_month/lag(t1.price) over(order by t1.month))*100,2),0) as Profit_or_Loss_percent from
(
    select t.month, t.price ,ifnull(round((t.price-(lag(t.price) over(order by t.month))),0),0) as increase_by_month from
    (
        select extract(month from date) as month,
        sum(cogs) as price from project.supermarket_sales 
        group by 1
    )t
)t1
order by 1;

##16. High sales in product_line
select Product_line, sum(quantity) as no_of_items_sold 
from project.supermarket_sales
group by 1
order by 2 desc;

##17. High sales in product_line for each branch
select Product_line, branch ,sum(quantity) as no_of_items_sold 
from project.supermarket_sales
group by 1,2
order by 1,3 desc;

##18. How much income is processed  by credit card, cash, Ewallet in each month per branch?
select branch, extract(month from date) as month, Payment, round(sum(Total),2) as income
from project.supermarket_sales
group by 1,2,3
order by 1,2,4 desc;

##19. What is the start date and end date of market?
select min(date) as start_date, max(date) as end_date 
from project.supermarket_sales;

##20. What is the start date, time and end date, time of market?
select date, min(time) as first_order, max(time) as last_order
from project.supermarket_sales
group by 1
order by 1;

##21. What is the start date, time and end date, time of market for each branch?
select branch, date, min(time) as first_order, max(time) as last_order
from project.supermarket_sales
group by 1,2
order by 2,1;

##22. On which date which shops are closed?
with cte1 as 
(
  select branch, date,
  row_number() over() as rn
  from project.supermarket_sales
  group by 1,2
 
),
cte2 as
(
  select cte1.date from cte1
  group by 1
  having count(cte1.rn)<=2
),
cte3 as
(
  select distinct branch, cte2.date from project.supermarket_sales, cte2
)
select cte3.branch, cte3.date from cte3 
where cte3.branch not in (select cte1.branch from cte1
where cte3.date=cte1.date)
order by 2;
