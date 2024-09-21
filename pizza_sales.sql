-- Retrieve the total number of order placed.

SELECT COUNT(order_id) AS Total_orders FROM orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Total_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;
      

-- Identify the highest priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT 
    quantity, COUNT(order_details_id) AS Orders_count
FROM
    orders_details
GROUP BY quantity;    



SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;


-- List the top 5 most ordered pizza types
-- along with their quantites.

SELECT 
      pizza_types.name,
      SUM(orders_details.quantity) AS quantity
FROM pizza_types 
      JOIN pizzas
		ON pizza_types.pizza_type_id = pizzas.pizza_type_id
	  JOIN orders_details
		ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC LIMIT 5;


-- INTERMEDIATE
-- Join the necessary tables to find the total quantity
-- of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hours of the day.

SELECT 
    HOUR(order_time), COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);


-- Join relevant tables to find the 
-- category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average 
-- number of pizzas ordered per day

SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;



-- Calculate the percentage contribution of each
-- pizza type to total revenue

SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(orders_details.quantity * pizzas.price),
                                2) AS Total_sales
                FROM
                    orders_details
                        JOIN
                    pizzas ON pizzas.pizza_id = orders_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;



-- Analyze the cumulative revenue generated over time

SELECT order_date,
	   SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM
     (SELECT orders.order_date,
	         SUM(orders_details.quantity * pizzas.price) AS revenue
FROM orders_details JOIN
                pizzas ON orders_details.pizza_id = pizzas.pizza_id
                    JOIN 
				orders ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date) AS sales;

-- Determine the top 3 most ordered pizzas types 
-- based on revenue for each pizza category

SELECT name, 
       revenue 
FROM
	(SELECT category, 
			name, 
            revenue,
            RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
FROM
    (SELECT pizza_types.category, 
            pizza_types.name, 
            SUM((orders_details.quantity) * pizzas.price) AS revenue
FROM pizza_types JOIN 
			 pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
                 JOIN 
			 orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS a) AS b
      WHERE rn<3;