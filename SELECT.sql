-- Основы
-- выберем все поля из таблицы film
SELECT * FROM film;

-- выберем столбец title таблицы film
SELECT title FROM film;

-- выберем 2 столбца из таблицы film
SELECT title, release_year FROM film;


-- Как работает DISTINCT
-- выведем столбец rating из film
SELECT DISTINCT rating FROM film;


-- Примеры с арифметикой
-- переведем цены в условные рубли
SELECT amount * 70 FROM payment;

-- узнаем время аренды по позициям
SELECT return_date - rental_date FROM rental;


-- WHERE
-- найдем фильмы, вышедшие после 2000
SELECT title, release_year FROM film
WHERE release_year >= 2000;

-- найдем сотрудников, которые сейчас работают
SELECT first_name, last_name, active FROM staff
WHERE active = true;

-- критерий не обязательно должен входить в выборку
SELECT first_name, last_name FROM staff
WHERE active = true;

-- найдем ID, имена, фамилии актеров, которых зовут Joe
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = 'Joe';

-- найдем всех сотрудников, которые работают не во втором магазине
SELECT first_name, last_name FROM staff
WHERE store_id != 2;

-- найдем только работающих сотрудников из всех магазинов, кроме 1
SELECT first_name, last_name FROM staff
WHERE active = true AND NOT store_id = 1;

-- найдем фильмы, цена проката которых меньше 0.99, а цена возмещения меньше 9.99
SELECT title, rental_rate, replacement_cost FROM film
WHERE rental_rate <= 0.99 AND replacement_cost <= 9.99;

-- найдем фильмы аналогичные предыдущему примеру или продолжительностью меньше 50 минут
SELECT title, length, rental_rate, replacement_cost FROM film
WHERE rental_rate <= 0.99 AND replacement_cost <= 9.99 OR length < 50;


-- IN / NOT IN
-- найдем фильмы с рейтингом R, NC-17
SELECT title, description, rating FROM film
WHERE rating IN ('R', 'NC-17');

-- найдем недетские фильмы
SELECT title, description, rating FROM film
WHERE rating NOT IN ('G', 'PG');


-- BETWEEN
-- в диапазоне (включая границы)
SELECT title, rental_rate FROM film
WHERE rental_rate BETWEEN 0.99 AND 3;

-- вне диапазона (границы тоже инвертируются => не включая границы)
SELECT title, rental_rate FROM film
WHERE rental_rate NOT BETWEEN 0.99 AND 3;


-- LIKE
-- найдем фильм, в описании которого есть Scientist
SELECT title, description FROM film
WHERE description LIKE '%Scientist%';

-- найдем ID, имена, фамилии актеров, фамилия которых содержит gen
SELECT actor_id, first_name, last_name FROM actor
WHERE last_name LIKE '%gen%';

-- найдем ID, имена, фамилии актеров, фамилия которых оканчивается на gen
SELECT actor_id, first_name, last_name FROM actor
WHERE last_name LIKE '%gen';


-- ORDER BY
-- отсортируем фильмы по цене проката
SELECT title, rental_rate FROM film
ORDER BY rental_rate;

-- по убыванию
SELECT title, rental_rate FROM film
ORDER BY rental_rate DESC;

-- сортируем по нескольким столбцам: продолжительности и цене проката
SELECT title, length, rental_rate FROM film
ORDER BY length DESC, rental_rate ASC;

-- найдем ID, имена, фамилии актеров, чья фамилия содержит li, 
-- отсортируем в алфавитном порядке по фамилии, затем по имени
SELECT actor_id, first_name, last_name FROM actor 
WHERE last_name LIKE '%li%' 
ORDER BY last_name, first_name;


-- LIMIT
-- выведем первые 15 записей
SELECT title, length, rental_rate FROM film
ORDER BY length DESC, rental_rate
LIMIT 15;


-- Агрегирующие функции
-- найдем максимальную стоимость проката
SELECT MAX(rental_rate) FROM film;

-- посчитаем среднюю продолжительность фильма
SELECT AVG(length) FROM film;

-- сколько уникальных имен актеров?
SELECT COUNT(DISTINCT first_name) FROM actor

-- посчитаем сумму и средние продажи по конкретному продавцу
SELECT SUM(amount), AVG(amount) FROM payment
WHERE staff_id = 1;


-- Вложенные запросы
-- найдем все фильмы с продолжительностью ваше среднего
-- так работать не будет
SELECT title, length  FROM film
WHERE length >= AVG(length);
-- нужно вот так
SELECT title, length FROM film
WHERE length >= (SELECT AVG(length) FROM film);

-- найдем названия фильмов, стоимость проката которых не максимальная
SELECT title, rental_rate FROM film
WHERE rental_rate < (SELECT MAX(rental_rate) FROM film)
ORDER BY rental_rate DESC;


-- Группировки
-- посчитаем количество актеров в разрезе фамилий (найдем однофамильцев)
SELECT last_name, COUNT(*) FROM actor
GROUP BY last_name
ORDER BY COUNT(*) DESC;

-- посчитаем количество фильмов в разрезе рейтингов (распределение рейтингов)
SELECT rating, COUNT(title) FROM film
GROUP BY rating
ORDER BY COUNT(title) DESC;

-- найдем максимальные продажи в разрезе продавцов
SELECT staff_id, MAX(amount) FROM payment
GROUP BY staff_id;

-- найдем средние продажи каждого продавца каждому покупателю
SELECT staff_id, customer_id, AVG(amount) FROM payment
GROUP BY staff_id, customer_id
ORDER BY AVG(amount) DESC;

-- найдем среднюю продолжительность фильма в разрезе рейтингов в 2006 году
SELECT rating, AVG(length) FROM film
WHERE release_year = 2006
GROUP BY rating;


-- Оператор HAVING
-- отберем только фамилии актеров, которые не повторяются
SELECT last_name, COUNT(*) FROM actor
GROUP BY last_name
HAVING COUNT(*) = 1;

-- отберем и посчитаем только фамилии актеров, которые повторяются
SELECT last_name, COUNT(*) FROM actor
GROUP BY last_name
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- найдем фильмы, у которых есть Super в названии 
-- и они сдавались в прокат суммарно более, чем на 5 дней
SELECT title, SUM(rental_duration) FROM film
WHERE title LIKE '%Super%'
GROUP BY title
HAVING SUM(rental_duration) > 5;


-- ALIAS
-- предыдущий запрос с псевдонимами
SELECT title AS t, SUM(rental_duration) AS sum_t FROM film AS f
WHERE title LIKE '%Super%'
GROUP BY t
HAVING SUM(rental_duration) > 5;

-- ключевое слово AS можно не писать
SELECT title t, SUM(rental_duration) sum_t FROM film f
WHERE title LIKE '%Super%'
GROUP BY t
HAVING SUM(rental_duration) > 5;


-- Объединение таблиц
-- выведем имена, фамилии и адреса всех сотрудников
SELECT first_name, last_name, address FROM staff s
LEFT JOIN address a ON s.address_id = a.address_id;

-- определим количество продаж каждого продавца
SELECT s.last_name, COUNT(amount) FROM payment p
LEFT JOIN staff s ON p.staff_id = s.staff_id
GROUP BY s.last_name;

-- посчитаем, сколько актеров играло в каждом фильме
SELECT title, COUNT(actor_id) actor_q FROM film f
JOIN film_actor a ON f.film_id = a.film_id
GROUP BY f.title
ORDER BY actor_q DESC;

-- сколько копий фильмов со словом Super в названии есть в наличии
SELECT title, COUNT(inventory_id) FROM film f
JOIN inventory i ON f.film_id = i.film_id
WHERE title LIKE '%Super%'
GROUP BY title;

-- выведем список покупателей с количеством их покупок в порядке убывания
SELECT c.last_name n, COUNT(p.amount) amount FROM customer c
LEFT JOIN payment p ON c.customer_id = p.customer_id
GROUP BY n
ORDER BY amount DESC;

-- выведем имена и почтовые адреса всех покупателей из России
SELECT c.last_name, c.first_name, c.email FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ON a.city_id = city.city_id
JOIN country co ON city.country_id = co.country_id
WHERE country = 'Russian Federation';

-- фильмы, которые берут в прокат чаще всего
SELECT f.title, COUNT(r.inventory_id) count FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY count DESC;

-- суммарные доходы магазинов
SELECT s.store_id, SUM(p.amount) sales FROM store s 
JOIN staff st ON s.store_id = st.store_id
JOIN payment p ON st.staff_id = p.staff_id
GROUP BY s.store_id;

-- найдем города и страны каждого магазина
SELECT store_id, city, country FROM store s 
JOIN address a ON s.address_id = a.address_id
JOIN city ON a.city_id = city.city_id
JOIN country c ON city.country_id = c.country_id;

-- выведем топ-5 жанров по доходу
SELECT c.name, SUM(p.amount) revenue FROM category c 
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY revenue DESC 
LIMIT 5;



-- SELECT-запрос, выводит название и год выхода альбомов, вышедших в 2018 году; 
SELECT album_name, album_year FROM album
WHERE album_year = 2018;

-- SELECT-запрос, выводит название и продолжительность самого длительного трека; 
SELECT track_name, track_duration FROM track
ORDER BY track_duration DESC
LIMIT 1;

-- SELECT-запрос, название треков, продолжительность которых не менее 3,5 минуты;
SELECT track_name, track_duration FROM track
WHERE track_duration >= 210;

-- SELECT-запрос, названия сборников, вышедших в период с 2018 по 2020 год включительно;
SELECT compilation_name, compilation_year FROM compilation
WHERE compilation_year BETWEEN 2018 AND 2020;

-- SELECT-запрос, исполнители, чье имя состоит из 1 слова;
SELECT singer_name FROM singer
WHERE singer_name NOT LIKE '% %';

-- SELECT-запрос, название треков, которые содержат слово "мой"/"my";
SELECT track_name FROM track
WHERE track_name ILIKE '%my%';

-- SELECT-запрос, количество исполнителей в каждом жанре;
SELECT genre_name, COUNT(*) FROM singers_genres_list sgl
LEFT JOIN genre g ON sgl.genre_id = g.id 
GROUP BY genre_name
ORDER BY genre_name ASC;

-- SELECT-запрос, количество треков, вошедших в альбомы 2019-2020 годов;
SELECT COUNT(track_id) FROM track t
LEFT JOIN album a ON t.album_id = a.id
WHERE album_year BETWEEN 2019 AND 2020;

-- SELECT-запрос, средняя продолжительность треков по каждому альбому;
SELECT album_name, AVG(track_duration) FROM track t
LEFT JOIN album a ON t.album_id = a.id
GROUP BY album_name
ORDER BY album_name ASC;

-- SELECT-запрос, все исполнители, которые не выпустили альбомы в 2020 году;
SELECT singer_name FROM singers_albums_list sat
JOIN singer s ON sat.singer_id = s.id
JOIN album a ON sat.album_id = a.id
WHERE album_year != 2020
ORDER BY singer_id; 

-- SELECT-запрос, названия сборников, в которых присутствует конкретный исполнитель (выберите сами);
SELECT DISTINCT singer_name, compilation_name FROM tracks_compilations_list tcl
LEFT JOIN compilation c ON tcl.compilation_id = c.id
LEFT JOIN track t ON tcl.track_id = t.track_id
LEFT JOIN album a ON t.album_id = a.id
LEFT JOIN singers_albums_list sal ON a.id = sal.singer_id 
LEFT JOIN singer s ON sal.singer_id = s.id
WHERE singer_name LIKE '%AC%'; 

-- SELECT-запрос, название альбомов, в которых присутствуют исполнители более 1 жанра;
SELECT album_name, singer_name FROM singers_albums_list sal 
LEFT JOIN album a ON sal.album_id = a.id 
LEFT JOIN singer s ON sal.singer_id = s.id
LEFT JOIN singers_genres_list sgl ON s.id = sgl.singer_id
GROUP BY album_name, singer_name
HAVING COUNT(genre_id) > 1; 

-- SELECT-запрос, наименование треков, которые не входят в сборники;
SELECT track_name FROM track t
LEFT JOIN tracks_compilations_list tcl ON t.track_id = tcl.id 
WHERE tcl.id IS NULL;

-- SELECT-запрос, исполнителя(-ей), написавшего самый короткий по продолжительности трек (теоретически таких треков может быть несколько);
SELECT singer_name, track_name, track_duration FROM track t
LEFT JOIN album a ON t.album_id = a.id 
LEFT JOIN singers_albums_list sal ON a.id = sal.album_id 
LEFT JOIN singer s ON sal.singer_id = s.id 
WHERE track_duration = (SELECT min(track_duration) FROM track);

-- SELECT-запрос,название альбомов, содержащих наименьшее количество треков.
SELECT album_name, COUNT(album_id) FROM track t 
LEFT JOIN album a ON t.album_id = a.id 
GROUP BY album_name
HAVING COUNT(album_id) <= (SELECT COUNT(album_id) AS tr_min FROM track tr GROUP BY album_id LIMIT 1);
