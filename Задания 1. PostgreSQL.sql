--Задание 1. Выведите уникальные названия городов из таблицы городов
select distinct city from city c order by city

/* Задание 2. Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города,
 * названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов. */
SELECT DISTINCT city
FROM city
WHERE city LIKE 'L%a' AND city NOT LIKE '% %';

/* Задание 3. Получите из таблицы платежей за прокат фильмов информацию по платежам,
 * которые выполнялись в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно и стоимость которых превышает 1.00.
 * Платежи нужно отсортировать по дате платежа*/
SELECT *
FROM payment
WHERE payment_date BETWEEN '2005-06-17' AND '2005-06-19'
  AND amount > 1.00
ORDER BY payment_date;

--Задание 4. Выведите информацию о 10-ти последних платежах за прокат фильмов.
SELECT *
FROM payment
ORDER BY payment_date DESC
LIMIT 10;

/* Задание 5. Выведите следующую информацию по покупателям:
Фамилия и имя (в одной колонке через пробел)
Электронная почта
Длину значения поля email
Дату последнего обновления записи о покупателе (без времени)
Каждой колонке задайте наименование на русском языке.*/
SELECT 
    CONCAT(first_name, ' ', last_name) AS "Фамилия и имя", 
    email AS "Электронная почта", 
    LENGTH(email) AS "Длина email", 
    DATE(last_update) AS "Дата последнего обновления"
FROM customer;

/* Задание 6. Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE.
 * Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.*/
SELECT 
    LOWER(first_name) AS first_name, 
    LOWER(last_name) AS last_name
FROM customer
WHERE active = 1
  AND (first_name = 'KELLY' OR first_name = 'WILLIE');
 
/* Задание 7. Выведите одним запросом информацию о фильмах,
 * у которых рейтинг “R” и стоимость аренды указана от 0.00 до 3.00 включительно,
 * а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.*/
SELECT *
FROM film
WHERE (rating = 'R' AND rental_rate BETWEEN 0.00 AND 3.00)
   OR (rating = 'PG-13' AND rental_rate >= 4.00);
  
--Задание 8. Получите информацию о трёх фильмах с самым длинным описанием фильма.
SELECT *
FROM film
ORDER BY LENGTH(description) DESC
LIMIT 3;

/*Задание 9. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
в первой колонке должно быть значение, указанное до @,
во второй колонке должно быть значение, указанное после @.*/
SELECT 
    SUBSTRING_INDEX(email, '@', 1) AS local_part, 
    SUBSTRING_INDEX(email, '@', -1) AS domain_part
FROM customer;

/*Задание 10. Доработайте запрос из предыдущего задания,
 * скорректируйте значения в новых колонках: первая буква должна быть заглавной, остальные строчными.*/
SELECT 
    CONCAT(UPPER(LEFT(LEFT(email, POSITION('@' IN email) - 1), 1)), 
           LOWER(SUBSTRING(LEFT(email, POSITION('@' IN email) - 1) FROM 2))) AS local_part,
    CONCAT(UPPER(LEFT(RIGHT(email, LENGTH(email) - POSITION('@' IN email)), 1)), 
           LOWER(SUBSTRING(RIGHT(email, LENGTH(email) - POSITION('@' IN email)) FROM 2))) AS domain_part
FROM customer;

