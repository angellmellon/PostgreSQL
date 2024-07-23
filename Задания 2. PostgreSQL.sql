--Задание 1. Выведите для каждого покупателя его адрес, город и страну проживания.
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    a.address,
    ci.city,
    co.country
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

/*Задание 2. С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
Доработайте запрос и выведите только те магазины, у которых количество покупателей больше 300. 
Для решения используйте фильтрацию по сгруппированным строкам с функцией агрегации. 
Доработайте запрос, добавив в него информацию о городе магазина, фамилии и имени продавца, который работает в нём.*/
WITH customer_counts AS (
    SELECT 
        store_id,
        COUNT(customer_id) AS customer_count
    FROM customer
    GROUP BY store_id
    HAVING COUNT(customer_id) > 300
)
SELECT 
    s.store_id,
    cc.customer_count,
    ci.city,
    st.first_name || ' ' || st.last_name AS manager_name
FROM customer_counts cc
JOIN store s ON cc.store_id = s.store_id
JOIN address a ON s.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN staff st ON s.manager_staff_id = st.staff_id;

--Задание 3. Выведите топ-5 покупателей, которые взяли в аренду за всё время наибольшее количество фильмов.
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    COUNT(r.rental_id) AS rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY rental_count DESC
LIMIT 5;

/* Задание 4. Посчитайте для каждого покупателя 4 аналитических показателя:
количество взятых в аренду фильмов;
общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
минимальное значение платежа за аренду фильма;
максимальное значение платежа за аренду фильма.*/
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    COUNT(r.rental_id) AS rental_count,
    ROUND(SUM(p.amount)) AS total_payment,
    MIN(p.amount) AS min_payment,
    MAX(p.amount) AS max_payment
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY c.customer_id;

/* Задание 5. Используя данные из таблицы городов, составьте одним запросом всевозможные пары городов так,
чтобы в результате не было пар с одинаковыми названиями городов. Для решения необходимо использовать декартово произведение.*/
SELECT 
    c1.city AS city1,
    c2.city AS city2
FROM 
    city c1,
    city c2
WHERE c1.city <> c2.city;

/* Задание 6. Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и дате возврата (поле return_date),
вычислите для каждого покупателя среднее количество дней, за которые он возвращает фильмы.*/
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    ROUND(AVG(DATE_PART('day', r.return_date - r.rental_date))) AS avg_days_to_return
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

--Задание 7. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую стоимость аренды фильма за всё время.
SELECT 
    f.film_id,
    f.title,
    COUNT(r.rental_id) AS rental_count,
    SUM(p.amount) AS total_rental_cost
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.film_id, f.title
ORDER BY film_id ASC;

--Задание 8. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые ни разу не брали в аренду.
SELECT 
    f.film_id,
    f.title,
    COUNT(r.rental_id) AS rental_count,
    SUM(p.amount) AS total_rental_cost
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.film_id, f.title
HAVING COUNT(r.rental_id) = 0;

/* Задание 9. Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия».
Если количество продаж превышает 7 300, то значение в колонке будет «Да», иначе должно быть значение «Нет».*/
SELECT 
    st.staff_id,
    st.first_name || ' ' || st.last_name AS full_name,
    COUNT(p.payment_id) AS sales_count,
    CASE 
        WHEN COUNT(p.payment_id) > 7300 THEN 'Да'
        ELSE 'Нет'
    END AS Премия
FROM staff st
JOIN payment p ON st.staff_id = p.staff_id
GROUP BY st.staff_id, st.first_name, st.last_name;

   

