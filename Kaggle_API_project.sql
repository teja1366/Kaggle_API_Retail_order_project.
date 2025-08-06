




--create table df_orders(
--		[order_id] int primary key
--		,[order_date] date 
--		,[ship_mode]   varchar(20)
--		,[segment] varchar(20)
--		,[country] varchar(20)
--		,[city] varchar(20)
--		,[state] varchar(20)
--		,[postal_code] varchar(20)
--		,[region] varchar(20)
--		,[category] varchar(20)
--		,[sub_category] varchar(20)
--		,[product_id] varchar(20)
--		,[quantity]  int
--		,[discount] decimal (7,2)
--		,[sale_price] decimal (7,2)
--		,[profit] decimal (7,2));
--



select * from df_orders; 



--FIND TOP 10 HIGHEST REVENUE GENERATING PRODUCTS

Select top 10
	product_id,sum(sale_price) as sales 
from 
	df_orders 
group by 
    product_id
order by 
    sum(sale_price) desc;



-- FIND top 5 highest selling products in each region


with cte as(
Select region,
	product_id,sum(sale_price) as sales 
from 
	df_orders 
group by 
   region, product_id)
 select * from (
 select * 
 ,row_number()  over (partition by region order by sales desc) as rn
 from cte) A
 where rn<6




 -- FIND MONTH OVER MONTH GROWTH COMPARISON FOR 2022 AND 2023 SALES EG : JAN 2022 VS JAN 2023 AND FINIDNG THE PERCENTAGE GROWTH.


with cte as (
 Select 
	distinct year(order_date) as order_year ,month(order_date) as order_month,sum(sale_price) as sales
 from 
	df_orders
group by year(order_date) ,month(order_date)
),
cte2 as( 
    select
	order_month--,order_year
	,sum(case when order_year =2022 then sales else 0  end) as sales_2022
	,sum(case when order_year =2023 then sales else 0 end) as sales_2023

from cte
group by order_month
)
SELECT 
    order_month,
    sales_2022,
    sales_2023,
   CAST(ROUND(((sales_2023 - sales_2022) / NULLIF(sales_2022, 0)) * 100, 2) AS DECIMAL(10,2)) AS percentage_sales
FROM cte2
ORDER BY order_month;






--FOR EACH CATEGORY WHICH MONTH HAD HIGHEST SALES

with cte as(
select  category,
		format(order_date,'yyyyMM') as order_year_month,
		sum(sale_price) as sales
from 
	df_orders
group by 
	category,format(order_date,'yyyyMM')
--order by category,format(order_date,'yyyyMM')
)
select * from(
select *,
row_number() over(Partition by category order by sales desc ) as rn
from cte) a
where rn =1


--WHICH SUB CATEGORY HAD HIGHEST GROWTH BY PROFIT IN 2023 COMPARE TTO 2022


with cte as (
 Select
    sub_category,
	 year(order_date) as order_year,
	sum(sale_price) as sales
 from 
	df_orders
group by sub_category, year(order_date) 
)
,cte2 as(
    select
	sub_category
	,sum(case when order_year =2022 then sales else 0  end) as sales_2022
	,sum(case when order_year =2023 then sales else 0 end) as sales_2023

from cte
group by sub_category
)
select top 1 *
	,(sales_2023-sales_2022)*100/sales_2022
from
	cte2
order by 
	(sales_2023-sales_2022)*100/sales_2022 desc

