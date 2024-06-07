create database dannys_dinner;
use dannys_dinner;
create table sales(customer_id varchar(1),order_date date,product_id int);
insert into sales (customer_id,order_date,product_id) 
values
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  create table menu(product_id int,product_name varchar(5),price int);
  insert into menu(product_id,product_name,price) 
  values
  (1,"sushi",10),
  (2,"curry",15),
  (3,"ramen",12);
  create table members(customer_id varchar(1),join_date date);
  insert into members(customer_id,join_date)
  values
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
/* What is the total amount each customer spent at the restaurant?*/
  Select sales.customer_id,sum(menu.price) as total_amount from sales
  left join menu 
  on sales.product_id=menu.product_id
  group by sales.customer_id;
  
  /*How many days has each customer visited the restaurant?*/
  select sales.customer_id, 
  count(distinct sales.order_date) as visited_day
  from sales
  group by sales.customer_id;
  
  /*What was the first item from the menu purchased by each customer?*/
with first_item as (
select customer_id,order_date,product_id,row_number() over
(partition by customer_id order by order_date) as row_num from sales
group by customer_id,order_date,product_id)
select first_item.customer_id,first_item.order_date,menu.product_name from first_item
left join
menu on first_item.product_id = menu.product_id
where row_num =1;

/* What is the most purchased item on the menu and how many times was it purchased by all customers*/
select m.product_name, count(m.product_name) as purchase_times from 
sales s 
join menu m 
on s.product_id=m.product_id
group by m.product_name
order by purchase_times desc;

/* Which item was the most popular for each customer*/
select distinct s.customer_id,m.product_name, count(m.product_name) as purchase_times from 
sales s 
join menu m 
on s.product_id=m.product_id
group by s.customer_id,m.product_name
order by purchase_times desc
limit 4;

WITH freq_rank AS (
      SELECT
         distinct customer_id,
         product_id,
         COUNT(*) AS frequency,
         rank() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS fr_rank
      FROM
         sales
      GROUP BY
         customer_id, product_id)
SELECT
   fr.customer_id,
   fr.frequency,
   m.product_name
FROM
   freq_rank fr
LEFT JOIN
   menu m
ON
   fr.product_id = m.product_id
WHERE
   fr_rank = 1;
   
 /*  Which item was purchased first by the customer after they became a member?*/
 with after_membership as (select 
 mem.customer_id,
 s.product_id,s.order_date,
 row_number() over (partition by mem.customer_id order by s.order_date) as row_num
 from members mem
 join sales s on mem.customer_id = s.customer_id
 and s.order_date>=mem.join_date)
 select
 am.customer_id,m.product_name,am.order_date
 from after_membership as am
 join menu m
 on am.product_id = m.product_id
 where row_num=1
 order by customer_id ASC;
 
 /*Which item was purchased just before the customer became a member?*/
 with justbefore_member as(
 select s.customer_id,s.product_id,s.order_date,row_number()
 over(partition by s.customer_id order by s.order_date desc) as row_num
 from sales s
 join members mem on
 s.customer_id=mem.customer_id and s.order_date<mem.join_date)
 select jm.customer_id,m.product_name,jm.order_date from justbefore_member jm
 join menu m
 on jm.product_id = m.product_id
 where row_num=1
 order by jm.customer_id asc;
 
 /*What is the total items and amount spent for each member before they became a member*/
select s.customer_id,s.order_date,
count(s.product_id) as total_items,
sum(m.price) as total_spent
from sales s
join menu m 
on s.product_id = m.product_id
join members mem
on s.customer_id = mem.customer_id
where s.order_date < mem.join_date
group by s.customer_id,s.order_date
order by s.customer_id;

/*If each $1 spent equates to 10 points and sushi has a 2x muliplier- how many points would each customer have? */
select s.customer_id,
sum(case
when m.product_name="sushi" then m.price *20
else m.price *10
end) as total_points
from sales s 
join menu m
on s.product_id = m.product_id
group by s.customer_id;

/*In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi- how many points do customer A and B have at the end of January? */
SELECT 
    s.customer_id,
    SUM(
        CASE 
            WHEN s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY) THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS total_points 
FROM 
    sales s
JOIN 
    menu m ON s.product_id = m.product_id
JOIN 
    members mem ON s.customer_id = mem.customer_id
WHERE 
    s.order_date <= '2021-01-31' AND s.customer_id IN ('A', 'B')
GROUP BY 
    s.customer_id
ORDER BY 
    s.customer_id;









 
 
 
 
 

 
 
 
 
 
 








  


  
  
  
  
 