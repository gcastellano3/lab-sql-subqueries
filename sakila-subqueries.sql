-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

SELECT
	COUNT(*) AS copies
FROM sakila.inventory i
WHERE i.film_id = (
    SELECT f.film_id
    FROM sakila.film f
    WHERE f.title = 'Hunchback Impossible'
	);

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT 
    f.title,
    f.length
FROM sakila.film f
WHERE f.length > (
    SELECT AVG(f.length)
    FROM sakila.film f
);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT first_name, last_name
FROM sakila.actor
WHERE actor_id IN (
    SELECT actor_id
    FROM sakila.film_actor
    WHERE film_id = (
        SELECT film_id
        FROM sakila.film
        WHERE title = 'Alone Trip'
    )
);
	
-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.

SELECT
	f.title
FROM sakila.film f
JOIN sakila.film_category fc ON f.film_id = fc.film_id
JOIN sakila.category c ON c.category_id = fc.category_id
WHERE c.name = 'Family';

SELECT title
FROM sakila.film
WHERE film_id IN (
    SELECT film_id
    FROM sakila.film_category
    WHERE category_id = (
        SELECT category_id
        FROM sakila.category
        WHERE name = 'Family'
    )
);

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.

SELECT
	cu.first_name,
	cu.last_name,
	cu.email
FROM sakila.customer cu
JOIN sakila.address a ON cu.address_id = a.address_id
JOIN sakila.city ci ON a.city_id = ci.city_id
JOIN sakila.country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

SELECT
	first_name,
	last_name,
	email
FROM sakila.customer
WHERE address_id IN (
    SELECT address_id
    FROM sakila.address
    WHERE city_id IN (
        SELECT city_id
        FROM sakila.city
        WHERE country_id = (
            SELECT country_id
            FROM sakila.country
            WHERE country = 'Canada'
        )
    )
);

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films.
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

SELECT f.title
FROM sakila.film f
WHERE f.film_id IN (
    SELECT fa.film_id
    FROM sakila.film_actor fa
    WHERE fa.actor_id = (
        SELECT a.actor_id
        FROM sakila.actor a
        JOIN sakila.film_actor fa ON a.actor_id = fa.actor_id
        GROUP BY a.actor_id
        ORDER BY COUNT(fa.film_id) DESC
        LIMIT 1
    )
);

-- 7. Find the films rented by the most profitable customer in the Sakila database.
-- You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

SELECT f.title
FROM sakila.film f
WHERE f.film_id IN (
    SELECT i.film_id
    FROM sakila.inventory i
    JOIN sakila.rental r ON i.inventory_id = r.inventory_id
    WHERE r.customer_id = (
        SELECT p.customer_id
        FROM sakila.payment p
        GROUP BY p.customer_id
        ORDER BY SUM(p.amount) DESC
        LIMIT 1
    )
);

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.

SELECT
	customer_id,
	SUM(amount) AS total_amount_spent
FROM sakila.payment
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT
    	AVG(total_per_customer)
    FROM (
        SELECT
        	SUM(amount) AS total_per_customer
        FROM sakila.payment
        GROUP BY customer_id
    ) AS customer_totals
);