# Understanding Customer Behavior and Preference by using MySQL #
![image](https://github.com/user-attachments/assets/74dabdf2-a182-4655-a694-831139b1fa31)

<h1><a name="introduction">Introduction</a></h1>
<p>In early 2021, Danny follows his passion for Japanese food and opens "Danny's Diner," a charming restaurant offering sushi, curry, and ramen. However, lacking data analysis expertise, the restaurant struggles to leverage the basic data collected during its initial months to make informed business decisions. Danny's Diner seeks assistance in using this data effectively to keep the restaurant thriving.</p>

<h1><a name="problemstatement">Problem Statement</a></h1>
<p>Danny aims to utilize customer data to gain valuable insights into their visiting patterns, spending habits, and favorite menu items. By establishing a deeper connection with his customers, he can provide a more personalized experience for his loyal patrons.

He plans to use these insights to make informed decisions about expanding the existing customer loyalty program. Additionally, Danny seeks assistance in generating basic datasets for his team to inspect the data conveniently, without requiring SQL expertise.

Due to privacy concerns, he has shared a sample of his overall customer data, hoping it will be sufficient for you to create fully functional SQL queries to address his questions.

Three key datasets:

- Sales
- Menu
- Members</p>

<h1><a name="entityrelationshipdiagram">Entity Relationship Diagram</a></h1>

![image](https://github.com/user-attachments/assets/40f38db5-bb4e-4caf-a7b9-dbc95073284a)

 ```sql
# Creating a Database
create database dannys_dinner;

# Selecting the Database
use dannys_dinner;

# Creating a Tables
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
```
 **What is the total amount each customer spent at the restaurant?**
```sql
  Select sales.customer_id,sum(menu.price) as total_amount from sales
  left join menu 
  on sales.product_id=menu.product_id
  group by sales.customer_id;
```
![image](https://github.com/user-attachments/assets/c93cf028-777e-4560-b28a-f8e39d68b1bc)

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.


 **How many days has each customer visited the restaurant?**
```sql
  select sales.customer_id, 
  count(distinct sales.order_date) as visited_day
  from sales
  group by sales.customer_id;
```

![image](https://github.com/user-attachments/assets/c8027202-89ec-4b34-9d84-1aec751992c0)

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.


 **What was the first item from the menu purchased by each customer?**
```sql
with first_item as (select customer_id,order_date,product_id,rank() over
(partition by customer_id order by order_date) as row_num from sales
group by customer_id,order_date,product_id)

select first_item.customer_id,first_item.order_date,menu.product_name from first_item
left join
menu on first_item.product_id = menu.product_id
where row_num =1;
```

![image](https://github.com/user-attachments/assets/b1cd125c-1c2a-4afc-86f0-cf1e66432940)

- Customer A placed an order for both curry and sushi simultaneously, making them the first items in the order.
- Customer B's first order is curry.
- Customer C's first order is ramen.

**What is the most purchased item on the menu and how many times was it purchased by all customers**
```sql
select m.product_name, count(m.product_name) as purchase_times from 
sales s 
join menu m 
on s.product_id=m.product_id
group by m.product_name
order by purchase_times desc limit 1;
```
![image](https://github.com/user-attachments/assets/aff0b4d4-ef36-4027-a603-1cf114c1715a)
- Most purchased item on the menu is ramen which is 8 times. Yummy!

**Which item was the most popular for each customer**
```sql
with most_popular as (Select s.customer_id,m.product_name, count(m.product_id) as order_count,
dense_rank() over (partition by s.customer_id order by count(s.customer_id) desc) as rnk 
from menu m inner join sales s
on m.product_id = s.product_id
group by s.customer_id,m.product_name)
Select customer_id,product_name,order_count from most_popular
where rnk = 1;
```
![image](https://github.com/user-attachments/assets/e14a166e-6af3-4590-bc4c-3bb830c7fce7)
- Customer A and C's favourite item is ramen.
- Customer B enjoys all items on the menu. He/she is a true foodie, sounds like me.

**Which item was purchased first by the customer after they became a member?**
```sql
 with joined_as_member as (Select mbr.customer_id,s.product_id, s.order_date,
 row_number() over ( partition by mbr.customer_id order by s.order_date) as row_num 
 from members mbr inner join sales s 
 on mbr.customer_id = s.customer_id
 and s.order_date > mbr.join_date)
 select customer_id,product_name from joined_as_member
 inner join menu on joined_as_member.product_id = menu.product_id
 where row_num = 1
 order by customer_id asc;
 ```
![image](https://github.com/user-attachments/assets/39243cbd-e4cb-4b41-88c1-ced180b389a6)
- Customer A's first order as a member is ramen.
- Customer B's first order as a member is sushi.

**Which item was purchased just before the customer became a member?**
```sql
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
```
![image](https://github.com/user-attachments/assets/0c7b30c3-6cb7-4aa5-878b-5a7f2bf4e525)
- Both customers' last order before becoming members are sushi.

 **What is the total items and amount spent for each member before they became a member**
  ```sql
SELECT S.customer_id,
  COUNT(S.product_id) AS total_item,
  SUM(M.price) AS total_amont
FROM sales S
JOIN menu M ON S.product_id=M.product_id
JOIN members ME ON S.customer_id=ME.customer_id
WHERE S.order_date<ME.join_date
GROUP BY S.customer_id
ORDER BY S.customer_id

![image](https://github.com/user-attachments/assets/f9833b87-25ff-402e-b94d-80fcf9cf7c82)

Before becoming members,

Customer A spent $150 on 12 items.
Customer B spent $240 on 18 items.



