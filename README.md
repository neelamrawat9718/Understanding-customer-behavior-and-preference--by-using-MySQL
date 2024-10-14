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
```sql











```sql
 /*What was the first item from the menu purchased by each customer?*/
with first_item as (
select customer_id,order_date,product_id,row_number() over
(partition by customer_id order by order_date) as row_num from sales
group by customer_id,order_date,product_id)
select first_item.customer_id,first_item.order_date,menu.product_name from first_item
left join
menu on first_item.product_id = menu.product_id
where row_num =1;
```
```sql
/* What is the most purchased item on the menu and how many times was it purchased by all customers*/
select m.product_name, count(m.product_name) as purchase_times from 
sales s 
join menu m 
on s.product_id=m.product_id
group by m.product_name
order by purchase_times desc;
```

```sql








Conclusion :At Danny's Diner, I used SQL to understand customer behavior better. I looked at questions like how much customers spend, how often they visit, their favorite dishes, and the effect of the loyalty program. By analyzing this information, Danny made smart choices to improve customer satisfaction and run the business more efficiently.
