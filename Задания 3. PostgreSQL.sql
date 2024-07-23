/*Задание 1. Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
Пронумеруйте все платежи от 1 до N по дате
Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.*/
SELECT 
    payment_id,
    customer_id,
    amount,
    payment_date,
    ROW_NUMBER() OVER (ORDER BY payment_date) AS row_num,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS customer_row_num,
    SUM(amount) OVER (PARTITION BY customer_id ORDER BY payment_date, amount) AS running_total,
    RANK() OVER (PARTITION BY customer_id ORDER BY amount DESC) AS payment_rank
FROM 
    payment;

--Задание 2. С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.
SELECT 
    payment_id,
    customer_id,
    amount,
    payment_date,
    LAG(amount, 1, 0.0) OVER (PARTITION BY customer_id ORDER BY payment_date) AS previous_payment
FROM payment;

--Задание 3. С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
SELECT 
    payment_id,
    customer_id,
    amount,
    payment_date,
    amount - LAG(amount, 1, 0.0) OVER (PARTITION BY customer_id ORDER BY payment_date) AS payment_difference
FROM payment;

--Задание 4. С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
SELECT 
    payment_id,
    customer_id,
    amount,
    payment_date
FROM 
    (
        SELECT 
            payment_id,
            customer_id,
            amount,
            payment_date,
            ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date DESC) AS rn
        FROM payment
    ) sub
WHERE sub.rn = 1;

/*Задание 5. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года с нарастающим итогом по каждому сотруднику
и по каждой дате продажи (без учёта времени) с сортировкой по дате.*/
SELECT 
    staff_id,
    payment_date::date AS sale_date,
    SUM(amount) OVER (PARTITION BY staff_id ORDER BY payment_date::date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_sales
FROM payment
WHERE payment_date >= '2005-08-01' AND payment_date < '2005-09-01'
ORDER BY sale_date;

/* Задание 6. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку на следующую аренду.
С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.*/
SELECT 
    customer_id,
    payment_date,
    amount
FROM 
    (
        SELECT 
            customer_id,
            payment_date,
            amount,
            ROW_NUMBER() OVER (PARTITION BY payment_date::date ORDER BY payment_date) AS rn
        FROM payment
        WHERE payment_date::date = '2005-08-20'
    ) sub
WHERE sub.rn % 100 = 0;

/* Задание 7. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
покупатель, арендовавший наибольшее количество фильмов;
покупатель, арендовавший фильмов на самую большую сумму;
покупатель, который последним арендовал фильм.*/
WITH CustomerRentals AS (
    SELECT
        c.customer_id,
        co.country_id,
        COUNT(r.rental_id) AS rental_count,
        SUM(p.amount) AS total_amount,
        MAX(r.rental_date) AS last_rental_date
    FROM customer c
    JOIN rental r ON c.customer_id = r.customer_id
    JOIN payment p ON r.rental_id = p.rental_id
    JOIN address a ON c.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country co ON ci.country_id = co.country_id
    GROUP BY c.customer_id, co.country_id
),
RankedRentals AS (
    SELECT 
        country_id, 
        customer_id, 
        rental_count, 
        total_amount, 
        last_rental_date,
        RANK() OVER (PARTITION BY country_id ORDER BY rental_count DESC) AS rental_rank,
        RANK() OVER (PARTITION BY country_id ORDER BY total_amount DESC) AS amount_rank,
        RANK() OVER (PARTITION BY country_id ORDER BY last_rental_date DESC) AS last_rental_rank
    FROM CustomerRentals
)
SELECT 
    country_id,
    customer_id,
    rental_count,
    total_amount,
    last_rental_date,
    CASE 
        WHEN rental_rank = 1 THEN 'Max Rentals'
        ELSE NULL
    END AS max_rentals_flag,
    CASE 
        WHEN amount_rank = 1 THEN 'Max Amount'
        ELSE NULL
    END AS max_amounts_flag,
    CASE 
        WHEN last_rental_rank = 1 THEN 'Last Rental'
        ELSE NULL
    END AS last_rentals_flag
FROM RankedRentals
WHERE rental_rank = 1 OR amount_rank = 1 OR last_rental_rank = 1
ORDER BY country_id, customer_id;

