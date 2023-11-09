-- membuat atable dim_user
create table dim_user (
	user_id int primary key,
	username varchar (50),
	country varchar (50)
	);

insert into dim_user (user_id, username, country)
select
	rw.user_id,
	rw.user_name,
	rw.country
from raw_users rw;
	
select * from dim_user;


-- membuat tabel dim_post
CREATE TABLE dim_post (
	post_id int primary key,
	post_text varchar (100),
	user_id int,
	post_date DATE 
);

insert into dim_post (post_id, post_text, user_id, post_date)
select
	post_id,
	post_text,
	user_id,
	post_date
from raw_posts;

select * from dim_post;

-- membuat tabel dim_date
CREATE TABLE dim_date AS
SELECT DISTINCT DATE_TRUNC('day', post_date) AS date
FROM raw_posts;

select * from dim_date;



-- Membuat tabel fact_post_performance
CREATE TABLE fact_post_performance (
	post_id int,
	date date,
	likes int,
	views int
);

insert into fact_post_performance (post_id, date, likes, views)
select
	p.post_id,
	d.date,
	COUNT(DISTINCT l.user_id) AS likes,
	COUNT(*) AS views
FROM dim_post p
JOIN dim_date d ON DATE_TRUNC('day', p.post_date) = d.date
LEFT JOIN raw_likes l ON p.post_id = l.post_id
GROUP BY p.post_id, d.date;

select * from fact_post_performance;

-- Membuat tabel fact_daily_posts
CREATE TABLE fact_daily_posts(
	user_id int,
	date date,
	daily_posts int
	);

insert into fact_daily_posts (user_id, date, daily_posts)
SELECT
  u.user_id,
  d.date,
  COUNT(DISTINCT p.post_id) AS daily_posts
FROM dim_user u
CROSS JOIN dim_date d
LEFT JOIN dim_post p ON u.user_id = p.user_id
  AND DATE_TRUNC('day', p.post_date) = d.date
GROUP BY u.user_id, d.date;

select * from fact_daily_posts;
