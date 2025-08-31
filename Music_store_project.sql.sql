-- 1.who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1;


-- 2.Which countries have the most invoices?

select count(*)as c,billing_country 
from invoice
group by billing_country
order by c desc;


-- 3.What are top 3 values of total invoice?
select total as total_invoice from invoice
order by total desc
limit 3;


-- 4.Which countries has the bast customers? we would like to throw a promotional music
     --festival in the city we made the most money. writea query that returns one city that
	 --has the heighest sum of invoice totals.Return both the city name & sum of all invoice total.

select sum(total) as total_invoice,billing_city 
from invoice
group by billing_city
order by total_invoice desc;

-- 5.Who is the best customer?The customer who has spent the most money will be declared the best customer.
     -- write a query that returns the person who has spent the most money..

select customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;


--1.write query to return the email,first_name,last name & genre of all rock music listeners.
    -- return your list ordered alphabetically by email starting with A...

SELECT DISTINCT email,first_name,last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
     SELECT track_id FROM track
	 JOIN genre ON track.genre_id = genre.genre_id
	 WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

--2.Let's invite the artists who have written the most rock music in our dataset. write a query that 
    --return all artist name and total track count of the top 10 rock bands..

SELECT artist.artist_id,artist.name,COUNT(artist.artist_id) as Number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY Number_of_songs DESC
LIMIT 10;

--3.Return all the track names that have a song lengh longer than the average song length.
  --Return the names and millisecounds for each track..order by the song length with the longest songs listed first..

SELECT name,milliseconds
FROM track
WHERE milliseconds > (
      SELECT AVG(milliseconds) AS avg_track_lengh
	  FROM track)
ORDER BY milliseconds DESC;



--1.Find how much amount spent by each customer on artists? write a query to return customer name,artist name and total spent.

WITH best_selling_artist AS(
    SELECT artist.artist_id AS artist_id,artist.name AS artist_name,SUM(invoice_line.unit_price*invoice_line.quantity) AS amount_spent
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id,c.first_name,c.last_name,bsa.artist_name,SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--2.We want to find out the most popular music genre for each country. We determine the most popular genre as the genre with 
   --the highest amount the purchases.write a query that returns each country along with the top genre. For countries where
   --the maximumnumber of purchases is shared return all genres...

WITH popular_genre AS (
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country,genre.name,genre.genre_id,
	    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNO
	FROM invoice_line
	    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNO <= 1

--3.Write a query that determines the customer that has spent the most on music for each country. Wite a query that returns 
   --the country along with the top customer and how much they spent.For countries where the top amount spent is shared,
   --provide all customers who spent this amount..

WITH customer_with_country AS (
              SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
			      ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNO
			  FROM invoice
			  JOIN customer ON customer.customer_id = invoice.customer_id
			  GROUP BY 1,2,3,4
			  ORDER BY 4 ASC,5 DESC)
SELECT * FROM customer_with_country WHERE RowNO <=1


	 