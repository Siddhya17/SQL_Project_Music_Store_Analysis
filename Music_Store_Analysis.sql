--1. Who is the senior most employee based on job title?

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1;

--2. Which countries have the most Invoices?

SELECT billing_country, COUNT(invoice_id) AS Most_Invoices
FROM invoice
GROUP BY billing_country
ORDER BY Most_Invoices DESC;

--3. What are top 3 values of total invoice?

SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3;

--4. Which city has the best customers?

SELECT billing_city, SUM(total) AS Invoice_Total
FROM invoice
GROUP BY billing_city
ORDER BY Invoice_Total DESC
LIMIT 1;

--5. Who is the best customer?

SELECT i.customer_id, c.first_name, c.last_name, SUM(i.total) AS Total_Spending
FROM invoice AS i
JOIN customer AS c
ON i.customer_id = c.customer_id
GROUP BY i.customer_id, c.first_name, c.last_name
ORDER BY Total_Spending DESC
LIMIT 1;

--6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A

SELECT DISTINCT c.email, c.first_name, c.last_name, g.name
FROM customer AS c
JOIN invoice AS i ON c.customer_id = i.customer_id
JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
JOIN track AS t ON t.track_id = il.track_id
JOIN genre AS g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;

--7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands

SELECT a.artist_id, a.name, COUNT(a.artist_id) AS No_of_songs
FROM artist AS a
JOIN album AS ab ON a.artist_id = ab.artist_id
JOIN track AS t ON ab.album_id = t.album_id
JOIN genre AS g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id, a.name
ORDER BY No_of_songs DESC
LIMIT 10;

--8. Return all the track names that have a song length longer than the average song length.Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

--9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

SELECT c.first_name, a.name, SUM(il.quantity * il.unit_price) AS Total_spent
FROM customer AS c
JOIN invoice AS i ON i.customer_id = c.customer_id
JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
JOIN track AS t ON t.track_id = il.track_id
JOIN album AS al ON al.album_id = t.album_id
JOIN artist AS a ON a.artist_id = al.artist_id
GROUP BY c.first_name, a.name
ORDER BY Total_spent DESC;

--10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres

WITH CTE AS
(
SELECT COUNT(il.quantity) AS Most_Purchases, g.name, i.billing_country AS Country,
ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY COUNT(il.quantity) DESC) AS RowNo
FROM invoice_line AS il
JOIN track AS t ON il.track_id = t.track_id
JOIN invoice AS i ON i.invoice_id = il.invoice_id
JOIN genre AS g ON g.genre_id = t.genre_id
GROUP BY g.name, i.billing_country
ORDER BY Country
)
SELECT * FROM CTE 
WHERE RowNo = 1;

--11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

WITH CTE AS
(
SELECT c.customer_id, c.first_name, c.last_name, c.country, SUM(i.total) AS Total_Spent,
ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY SUM(i.total) DESC) AS RowNo
FROM customer AS c
JOIN invoice AS i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
)
SELECT * FROM CTE 
WHERE RowNo = 1;
