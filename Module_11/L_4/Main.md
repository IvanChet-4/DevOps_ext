# «SQL. Часть 2»

### Задание 1

Одним запросом получите информацию о магазине, в котором обслуживается более 300 покупателей, и выведите в результат следующую информацию: 
- фамилия и имя сотрудника из этого магазина;
- город нахождения магазина;
- количество пользователей, закреплённых в этом магазине.

#### Решение  

```  
SELECT 
    st.last_name AS "Фамилия сотрудника",
    st.first_name AS "Имя сотрудника",
    ci.city AS "Город магазина",
    COUNT(cu.customer_id) AS "Количество клиентов"
FROM store s
JOIN staff st ON s.manager_staff_id = st.staff_id
JOIN address a ON s.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN customer cu ON s.store_id = cu.store_id
GROUP BY s.store_id, st.last_name, st.first_name, ci.city
HAVING COUNT(cu.customer_id) > 300;
```  


----

### Задание 2

Получите количество фильмов, продолжительность которых больше средней продолжительности всех фильмов.

#### Решение  

```  
SELECT COUNT(*) AS "Количество фильмов"
FROM film
WHERE length > (SELECT AVG(length) FROM film);
```  

----

### Задание 3

Получите информацию, за какой месяц была получена наибольшая сумма платежей, и добавьте информацию по количеству аренд за этот месяц.

#### Решение  

```  
SELECT 
    DATE_FORMAT(p.payment_date, '%Y-%m') AS "Месяц",
    SUM(p.amount) AS "Сумма платежей",
    COUNT(DISTINCT r.rental_id) AS "Количество аренд"
FROM payment p
LEFT JOIN rental r ON p.rental_id = r.rental_id
GROUP BY DATE_FORMAT(p.payment_date, '%Y-%m')
ORDER BY "Сумма платежей" DESC
LIMIT 1;
```  

----


## Дополнительные задания (со звёздочкой*)
Эти задания дополнительные, то есть не обязательные к выполнению, и никак не повлияют на получение вами зачёта по этому домашнему заданию. Вы можете их выполнить, если хотите глубже шире разобраться в материале.

### Задание 4*

Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 8000, то значение в колонке будет «Да», иначе должно быть значение «Нет».

#### Решение  

```  
SELECT 
    st.staff_id AS "ID продавца",
    st.last_name AS "Фамилия",
    st.first_name AS "Имя",
    COUNT(p.payment_id) AS "Количество продаж",
    CASE 
        WHEN COUNT(p.payment_id) > 8000 THEN 'Да'
        ELSE 'Нет'
    END AS "Премия"
FROM staff st
JOIN payment p ON st.staff_id = p.staff_id
GROUP BY st.staff_id, st.last_name, st.first_name;
```  

----

### Задание 5*

Найдите фильмы, которые ни разу не брали в аренду.

#### Решение  

```  
SELECT 
    f.film_id AS "ID фильма",
    f.title AS "Название фильма"
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL;
```  

----
