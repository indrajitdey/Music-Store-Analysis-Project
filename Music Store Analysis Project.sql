--SQL PROJECT- MUSIC STORE DATA ANALYSIS

--Question Set 1 - Easy

--1. Who is the senior most employee based on job title?
select concat(first_name,' ',last_name) as senior_most_employee from employee
where levels in (select max(levels) from employee);

--2. Which countries have the most Invoices?
select billing_country, count(*) from invoice
group by billing_country
order by count(*) desc;

--3. What are top 3 values of total invoice?
select total from invoice 
order by total desc
limit 3;

/*
4. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals
*/
select billing_city,sum(total) from invoice
group by billing_city
order by sum(total) desc;

/*
5. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money
*/
select c.customer_id, c.first_name,c.last_name,sum(i.total) as total from customer as c join invoice as i
on c.customer_id=i.customer_id
group by c.customer_id
order by total desc
limit 1;



--Question Set 2 – Moderate
/*
1. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A
*/
select distinct c.email,c.first_name,c.last_name,g.name from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on il.track_id=t.track_id
join genre g on g.genre_id=t.genre_id
where g.name='Rock'
order by c.email;

/*
2. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands
*/
select a.artist_id, a.name ,count(a.artist_id) as rock_music from artist a
join album al on a.artist_id=al.artist_id
join track t on al.album_id=t.album_id
join genre g on t.genre_id=g.genre_id
where g.name='Rock'
group by a.artist_id
order by rock_music desc
limit 10;

/*
3. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first
*/

select name,milliseconds from track
where milliseconds>(select avg(milliseconds) from track)
order by milliseconds desc;


--Question Set 3 – Advance
/*
1. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent
*/
with best_artist as(
select a.artist_id,a.name as name,sum(il.unit_price*il.quantity) from artist a 
join album al on a.artist_id=al.artist_id
join track t on al.album_id=t.album_id
join invoice_line il on t.track_id=il.track_id
group by 1
order by 3 desc
limit 1
)
select c.customer_id,c.first_name,c.last_name,ba.name as artist_name,sum(il.unit_price*il.quantity) as total_spend from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on il.track_id=t.track_id
join album al on t.album_id=al.album_id
join best_artist ba on al.artist_id=ba.artist_id
group by 1,2,3,4
order by 5 desc;


/*
2. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres
*/
with cte as (
select g.genre_id,g.name,i.billing_country,sum(il.quantity) as sale,
rank() over(partition by billing_country order by sum(il.quantity) desc)  as rank from genre g
join track t on g.genre_id=t.genre_id
join invoice_line il on t.track_id=il.track_id
join invoice i on il.invoice_id=i.invoice_id
group by 1,2,3
)
select * from cte where rank=1;
/*
3. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount
*/
with cte as (
select c.customer_id,c.first_name,c.last_name,i.billing_country,sum(i.total),
row_number() over(partition by i.billing_country order by sum(i.total) desc) as rank from customer c
join invoice i on c.customer_id=i.customer_id
group by 1,2,3,4
)
select * from cte where rank=1








