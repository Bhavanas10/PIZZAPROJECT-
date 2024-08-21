PIZZACASESTUDY PROJECT MYQLWORKBENCH BHAVANA.S 

create database pizzaplace;
show databases;
use  pizzaplace; 
select*from pizzaplace.pizzas;
select*from pizzaplace.orders;
select*from pizzaplace.order_details;
select*from pizzaplace.pizza_types;
  
  /*
  case study project
  */
  /*--import csv files*/
  /*--understand each table (all colums)*/
  select*from order_details; 
  /*--order_details_id  order_id  pizza_id  quantityc*/
  select *from pizzas;
  /*pizza_id   pizza_type_id  size  price*/
  select*from orders;
  /*order_id  date  time */
  select*from pizza_types;
  /*pizza)type_id  name  catagory ingredients */
  
/*
BASIC 
retrive the total number of orders placed.
calculate how many customer we have each day
calculate the total revenue generated from pizza sales
identify the highest-priced pizz
identify the most common size pizzas ordered
list the top 5 most ordered pizza types along with their quantities.

intermidiate:
join the necessary tables to find the total quantity of each pizza catagory ordered
determine the distribution of orders by date
join relevant table to find catagory wise distribution of pizzas
determine the top 3 most ordered pizza types based on the revenue 

advanced 'calculate the persentage contribution of each pizza type to total revenue 
analyse the cumulative generated over time
determine any top 3 most ordered pizza types based on the revenue for each pizza catagory.

*/

select count(1000)
from orders;

select count(1000)
from orders
where order_id=1-1000;

-- Retrieve the total number of orders placed.
select count(distinct order_id) as 'Total Orders' from orders;

-- Calculate the total revenue generated from pizza sales.

-- to see the details
select order_details.pizza_id, order_details.quantity, pizzas.price
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id

--retrive the total number of order placed
select count(distinct order_id)as 'total_orders'
from orders;

---calculate how many customers we have each day
select count(order_id)/count(DISTINCT date)
from orders;

--calculate total revenue granted from pizza sales

---to see the details
select order_details.pizza_id,order_details.quantity,pizzas.price
from order_details
join pizzas on pizzas.pizza_id=order_details.pizza_id

---to get the answer
select cast(sum(order_details.quantity * pizzas.price)as decimal(10,2)) as 'total revenue'
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id

---identify the heighest priced pizza
---using TOP/LIMIT function

select pizza_id ,price
from pizzas
order by price desc
limit 1;
----alternative(using window function)-without using top function
;

-- Identify the most common pizza size ordered.

select pizzas.size, count(distinct order_id) as 'No of Orders', 
sum(quantity) as 'Total Quantity Ordered' 
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
-- join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizzas.size
order by count(distinct order_id) desc;

-- List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name as 'Pizza', sum(quantity) as 'Total Ordered'
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name 
order by sum(quantity) desc
limit 5;


-- Identify the highest-priced pizza.
-- using TOP/Limit functions
select  pizza_types.name as 'Pizza Name', cast(pizzas.price as decimal(10,2)) as 'Price'
from pizzas 
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by price desc
limit 10;


INTERMIDIATE ---

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category, sum(quantity) as 'Total Quantity Ordered'
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category 
order by sum(quantity)  desc;

---orders by date 
	select orders.date as 'Date', sum(order_details.quantity) as 'Total Pizza Ordered that day'
	from order_details
	join orders on order_details.order_id = orders.order_id
	group by orders.date; 
    

-- find the category-wise distribution of pizzas

select category, count(distinct pizza_type_id) as 'No of pizzas'
from pizza_types
group by category
order by 'No of pizzas'
desc ;

-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, sum(order_details.quantity*pizzas.price) as 'Revenue from pizza'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by sum(order_details.quantity*pizzas.price) desc;

--ADVANCED 

-- Calculate the percentage contribution of each pizza type to total revenues


select pizza_types.category, 
concat(cast((sum(order_details.quantity*pizzas.price) /
(select sum(order_details.quantity*pizzas.price) 
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id 
))*100 as decimal(10,2)), '%')
as 'Revenue contribution from pizza'
from order_details; 


-- revenue contribution from each pizza by pizza name
select pizza_types.name, 
concat(cast((sum(order_details.quantity*pizzas.price) /
(select sum(order_details.quantity*pizzas.price) 
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id 
))*100 as decimal(10,2)), '%')
as 'Revenue contribution from pizza'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by 'Revenue contribution from pizza' desc


-- Analyze the cumulative revenue generated over time.
-- use of aggregate window function (to get the cumulative sum)
---
with cte as (
select date as 'Date', cast(sum(quantity*price) as decimal(10,2)) as Revenue
from order_details 
join orders on order_details.order_id = orders.order_id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by date
-- order by [Revenue] desc
)
select Date, Revenue, sum(Revenue) over (order by date) as 'Cumulative Sum'
from cte 
group by date, Revenue

----- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with cte as (
select category, name, cast(sum(quantity*price) as decimal(10,2)) as Revenue
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by category, name
-- order by category, name, Revenue desc
)
, cte1 as (
select category, name, Revenue,
rank() over (partition by category order by Revenue desc) as rnk
from cte 
)
select category, name, Revenue
from cte1 
where rnk in (1,2,3)
order by category, name, Revenue






