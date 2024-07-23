--Задание 1. Напишите SQL-запрос, который выводит всю информацию о фильмах со специальным атрибутом (поле special_features) равным “Behind the Scenes”.
SELECT * FROM film
WHERE 'Behind the Scenes' = ANY(special_features);

--Задание 2. Напишите ещё 2 варианта поиска фильмов с атрибутом “Behind the Scenes”, используя другие функции или операторы языка SQL для поиска значения в массиве.
--Вариант 1.
--Вариант 1.
SELECT * FROM film
WHERE POSITION('Behind the Scenes' IN special_features::text) > 0;
--Вариант 2.
SELECT * FROM film
WHERE special_features @> ARRAY['Behind the Scenes'];

/*Задание 3. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в CTE.*/
WITH behind_the_scenes_films AS (
    SELECT film_id
    FROM film
    WHERE 'Behind the Scenes' = ANY(special_features)
)
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    COUNT(r.rental_id) AS bts_rentals_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN behind_the_scenes_films btf ON i.film_id = btf.film_id
GROUP BY c.customer_id, c.first_name, c.last_name;

/* Задание 4. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в подзапрос, который необходимо использовать для решения задания.*/
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    COUNT(r.rental_id) AS bts_rentals_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN (SELECT film_id FROM film WHERE 'Behind the Scenes' = ANY(special_features)) btf ON i.film_id = btf.film_id
GROUP BY c.customer_id, c.first_name, c.last_name;

--Задание 5. Создайте материализованное представление с запросом из предыдущего задания и напишите запрос для обновления материализованного представления.
-- Создание материализованного представления
CREATE MATERIALIZED VIEW mv_bts_rentals AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    COUNT(r.rental_id) AS bts_rentals_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN 
    (SELECT film_id FROM film WHERE 'Behind the Scenes' = ANY(special_features)) btf ON i.film_id = btf.film_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- Запрос для обновления материализованного представления
REFRESH MATERIALIZED VIEW mv_bts_rentals;

/*Задание 6. С помощью explain analyze проведите анализ скорости выполнения запросов из предыдущих заданий и ответьте на вопросы:
с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания, поиск значения в массиве происходит быстрее;
какой вариант вычислений работает быстрее: с использованием CTE или с использованием подзапроса.*/
EXPLAIN ANALYZE
SELECT *FROM film
WHERE 'Behind the Scenes' = ANY(special_features);

EXPLAIN ANALYZE
SELECT *FROM film
WHERE POSITION('Behind the Scenes' IN special_features::text) > 0;

EXPLAIN ANALYZE
SELECT *FROM film
WHERE special_features @> ARRAY['Behind the Scenes'];

-- Анализ CTE против подзапроса
EXPLAIN ANALYZE
WITH behind_the_scenes_films AS (
	SELECT *FROM film
    WHERE 'Behind the Scenes' = ANY(special_features)
)
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    COUNT(r.rental_id) AS bts_rentals_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN behind_the_scenes_films btf ON i.film_id = btf.film_id
GROUP BY c.customer_id, c.first_name, c.last_name;

EXPLAIN ANALYZE
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    COUNT(r.rental_id) AS bts_rentals_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN 
    (SELECT film_id FROM film WHERE 'Behind the Scenes' = ANY(special_features)) btf ON i.film_id = btf.film_id
GROUP BY c.customer_id, c.first_name, c.last_name;


--Задание 7. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.   
WITH first_sales AS (
    SELECT 
        p.staff_id,
        p.payment_id,
        p.customer_id,
        p.amount,
        p.payment_date,
        ROW_NUMBER() OVER (PARTITION BY p.staff_id ORDER BY p.payment_date) AS sale_rank
    FROM payment p
)
SELECT 
    fs.staff_id,
    fs.payment_id,
    fs.customer_id,
    fs.amount,
    fs.payment_date
FROM first_sales fs
WHERE fs.sale_rank = 1
ORDER BY fs.staff_id;


/*Задание 8. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
день, в который арендовали больше всего фильмов (в формате год-месяц-день);
количество фильмов, взятых в аренду в этот день;
день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
сумму продажи в этот день.*/
WITH rental_stats AS (
    SELECT 
        i.store_id,
        r.rental_date::date AS rental_day,
        COUNT(r.rental_id) AS rental_count,
        ROW_NUMBER() OVER (PARTITION BY i.store_id ORDER BY COUNT(r.rental_id) DESC) AS max_rentals_rank
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    GROUP BY i.store_id, r.rental_date::date
),
payment_stats AS (
    SELECT 
        s.store_id,
        p.payment_date::date AS payment_day,
        SUM(p.amount) AS total_sales,
        ROW_NUMBER() OVER (PARTITION BY s.store_id ORDER BY SUM(p.amount)) AS min_sales_rank
    FROM payment p
    JOIN staff s ON p.staff_id = s.staff_id
    GROUP BY s.store_id, p.payment_date::date
)
SELECT 
    rs.store_id,
    rs.rental_day AS max_rentals_day,
    rs.rental_count,
    ps.payment_day AS min_sales_day,
    ps.total_sales
FROM rental_stats rs
JOIN payment_stats ps ON rs.store_id = ps.store_id
WHERE rs.max_rentals_rank = 1
    AND ps.min_sales_rank = 1
ORDER BY rs.store_id;
   
   
   
   