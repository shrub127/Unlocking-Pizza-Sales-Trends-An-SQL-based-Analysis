
-- Retrieve the total number of orders placed.
select count(distinct order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(price * quantity), 2) AS total_revenue
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    name, price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.
SELECT 
    size, COUNT(quantity) AS total_quantity
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY 1
ORDER BY total_quantity DESC
limit 1;

-- List the top 5 most ordered pizza types along with their quantities. 
SELECT 
    name, sum(quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY name
ORDER BY total_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    category, SUM(quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY 1
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour_of_the_day,
    COUNT(order_id) AS order_count
FROM
    orders
GROUP BY 1;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(category) AS category_count
FROM
    pizza_types
GROUP BY 1;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    round(AVG(no_ordered),0) as avg_pizza_ordered_per_day
FROM
    (SELECT 
        DATE(order_date) AS order_date, SUM(quantity) AS no_ordered
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY order_date) AS order_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    name, SUM(price * quantity) AS revenue
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    category,
    ROUND(SUM(price * quantity) / (SELECT 
                    ROUND(SUM(price * quantity), 2) AS total_sales
                FROM
                    pizzas p
                        JOIN
                    order_details od ON p.pizza_id = od.pizza_id) * 100,
            2) AS revenue
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 1;

-- Analyze the cumulative revenue generated over time.
select order_date,revenue,sum(revenue)over(order by order_date) as cumu_revenue from
(select date(order_date) as order_date,sum(price*quantity) as revenue from orders o 
join order_details od 
on od.order_id=o.order_id
join pizzas p
on p.pizza_id=od.pizza_id
group by 1) as t1;   

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name,revenue,rnk from 
(select category,name,revenue,rank()over(partition by category order by revenue desc) as rnk from 
(select category,name, sum(price*quantity) as revenue from pizza_types pt
join pizzas p 
on pt.pizza_type_id=p.pizza_type_id
join order_details od
on od.pizza_id=p.pizza_id
group by 1,2) as t1) as t2
where rnk<=3;

































