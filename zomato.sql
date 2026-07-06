SELECT * FROM orders;
select * from customers;
select * from partners;
select * from promos;
select * from restaurants;

# KPI's
select sum(order_amount) from orders; -- 8176327.61
select avg(order_amount) from orders; -- 1649.7836
select avg(delivery_time_min) from orders; -- 50.61
select avg(delivery_rating) from orders; -- 2.98
select avg(discount) from promos; -- 85

# order amount according to membership
select c.membership , sum(o.order_amount)
from orders o join customers c on o.customer_id = c.customer_id
group by c.membership;

# avg order amount with respect to membership
select c.membership , avg(o.order_amount)
from orders o join customers c on o.customer_id = c.customer_id
group by c.membership;

# order amount according to restaurants
select r.Restaurant_ID , sum(o.order_amount) as sales
from orders o join restaurants r on o.Restaurant_ID = r.Restaurant_ID
group by r.restaurant_id order by sales desc;

# order amount according to cuisine & city
select r.cuisine , r.city , sum(o.order_amount) as sales ,
rank() over(partition by city order by sum(order_amount) desc) as rnk
from orders o join restaurants r on o.Restaurant_ID = r.Restaurant_ID
group by r.cuisine , r.city ;

# net total of each orders
select o.order_id , o.order_amount ,p.discount , (o.order_amount - p.discount) as net_total
from orders o join promos p on o.Promo_ID = p.Promo_id order by net_total desc;

# net revenue -- 7755427.61
select sum(o.order_amount - p.discount) as net_revenue
from orders o join promos p on o.Promo_ID = p.Promo_id ;

# total discount given to customers -- 420900
select sum(p.discount) as net_discount
from orders o join promos p on o.Promo_ID = p.Promo_id ;

# avg of discount and order amount having gold and silver membership
select c.membership , round(avg(o.order_amount),2) as avg_amt , round(avg(p.discount),2) as avg_dsct
from orders o join customers c on 
o.customer_id = c.customer_id
join promos p on o.promo_id = p.promo_id 
where c.membership in ('gold' , 'silver')
group by membership;

# average difference in % between gold and silver according to sales
SELECT
ROUND(
(
    MAX(CASE WHEN t.Membership='gold' THEN Avg_Order END) -
    MAX(CASE WHEN t.Membership='silver' THEN Avg_Order END)
)
/
MAX(CASE WHEN Membership='silver' THEN Avg_Order END)
*100,2
) AS Order_Value_Increase_Percentage
FROM
(
    SELECT
        c.Membership,
        AVG(o.Order_Amount) AS Avg_Order
    FROM orders o
    JOIN customers c
        ON o.Customer_ID = c.Customer_ID
    WHERE c.Membership IN ('gold','silver')
    GROUP BY c.Membership
) t;

# average difference in % between gold and silver according to discount
SELECT
ROUND(
(
    MAX(CASE WHEN t.Membership='gold' THEN Avg_Dsct END) -
    MAX(CASE WHEN t.Membership='silver' THEN Avg_Dsct END)
)
/
MAX(CASE WHEN Membership='silver' THEN Avg_Dsct END)
*100,2
) AS Discount_Increase_Percentage
FROM
(
    SELECT
        c.Membership,
        AVG(p.discount) AS Avg_Dsct
    FROM orders o join customers c on 
         o.customer_id = c.customer_id
         join promos p on o.promo_id = p.promo_id 
    WHERE c.Membership IN ('gold','silver')
    GROUP BY c.Membership
) t;