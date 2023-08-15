--first product purchased by each customer

select * from
(select *, rank() over(partition by userid order by created_date) rnk from sales) a where rnk=1;

--Amount spent by each customer

select a.userid, sum(b.price) from sales a inner join product b on a.product_id=b.product_id
group by a.userid;

--Most purchased product and how many times each customer purchased it

select userid, count(product_id) cnt from sales where product_id =
(select top 1 product_id from sales group by product_id order by count(product_id) desc )
group by userid;

--Most popular product for each customer

select * from
(select *,rank() over( partition by userid order by cnt desc) rnk from
(select userid, product_id, count(product_id) cnt from sales group by userid,product_id)a)b
where rnk=1;

--Number of days visited by each customer on zomato

select userid, count( distinct created_date) distinct_days from sales group by userid;


--Item purchased first by the customer after they became a member

select * from
(select c.*,rank() over(partition by userid order by created_date) rnk from
(select a.userid, a.product_id, a.created_date, b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid = b.userid and created_date>gold_signup_date)c)d where rnk=1;

--Total orders and amount spent by each customer before becoming a member

select userid, count(created_date) order_purchased, sum(price) total_amt_spend from
(select c.*,d.price from
(select a.userid, a.product_id, a.created_date, b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid = b.userid and created_date<=gold_signup_date)c inner join product d on c.product_id=d.product_id)e
group by userid;

--For product id 1 10 Rs= 1 zomato point, for product id 2 20 Rs = 1 zomato point and for product id 3 5 Rs = 1 zomato point. 
--Calculate points collected by each customer 

select userid,sum(total_points)*2.5 total_amt_earned from
(select e.*, amt/points total_points from
(select d.*, case when product_id=1 then 10 when product_id=2 then 20 when product_id=3 then 5 else 0 end as points from
(select c.userid,c.product_id,sum(price) amt from
(select a.*, b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id)d)e)f group by userid;

--Which product has given most number of points 

select* from
(select *, rank() over(order by total_amt_earned desc) rnk from
(select product_id,sum(total_points) total_amt_earned from
(select e.*, amt/points total_points from
(select d.*, case when product_id=1 then 10 when product_id=2 then 20 when product_id=3 then 5 else 0 end as points from
(select c.userid,c.product_id,sum(price) amt from
(select a.*, b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id)d)e)f group by product_id)f)g where rnk=1;

--Rank all transaction for each customer

select*, rank() over(partition by userid order by created_date) from sales rnk;

--Ranking all the transactions for members when they become a zomato gold member for every non-member mark it as na

select e.*,case when rnk=0 then 'na' else rnk end as rnkk from
(select c.*, cast((case when gold_signup_date is null then 'na' else rank() over(partition by userid order by gold_signup_date desc) end) as varchar) as rnk from
(select a.userid, a.product_id, a.created_date, b.gold_signup_date from sales a left join 
goldusers_signup b on a.userid = b.userid and created_date>=gold_signup_date)c)e

