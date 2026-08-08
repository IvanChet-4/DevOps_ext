-- 1. Включаем расширение для работы с удаленными базами данных (Foreign Data Wrapper)
CREATE EXTENSION postgres_fdw;

-- =========================================================================
-- НАСТРОЙКА КЛАТЕРА USERS (Вертикальный + Горизонтальный шардинг по хэшу)
-- =========================================================================

-- Регистрируем внешние сервера-шарды для пользователей
CREATE SERVER user_srv_1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'user-shard-1', dbname 'user_db_1', port '5432');
CREATE SERVER user_srv_2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'user-shard-2', dbname 'user_db_2', port '5432');

-- Создаем сопоставление пользователей (доступы)
CREATE USER MAPPING FOR postgres SERVER user_srv_1 OPTIONS (user 'postgres', password 'shard_password');
CREATE USER MAPPING FOR postgres SERVER user_srv_2 OPTIONS (user 'postgres', password 'shard_password');

-- Создаем единую головную таблицу пользователей на Роутере с логикой Хэш-секционирования
CREATE TABLE users (
    user_id BIGINT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    registration_date TIMESTAMP NOT NULL DEFAULT NOW()
) PARTITION BY HASH (user_id);

-- Привязываем удаленные шарды к соответствующим секциям хэша (Остаток от деления на 2)
CREATE FOREIGN TABLE users_p1 PARTITION OF users
    FOR VALUES WITH (MODULUS 2, REMAINDER 0)
    SERVER user_srv_1 OPTIONS (table_name 'users_shard_1');

CREATE FOREIGN TABLE users_p2 PARTITION OF users
    FOR VALUES WITH (MODULUS 2, REMAINDER 1)
    SERVER user_srv_2 OPTIONS (table_name 'users_shard_2');


-- =========================================================================
-- НАСТРОЙКА КЛАТЕРА BOOKS (Вертикальный + Горизонтальный шардинг по хэшу)
-- =========================================================================

-- Регистрируем внешние сервера-шарды для книг
CREATE SERVER book_srv_1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'book-shard-1', dbname 'book_db_1', port '5432');
CREATE SERVER book_srv_2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'book-shard-2', dbname 'book_db_2', port '5432');

-- Создаем сопоставление пользователей
CREATE USER MAPPING FOR postgres SERVER book_srv_1 OPTIONS (user 'postgres', password 'shard_password');
CREATE USER MAPPING FOR postgres SERVER book_srv_2 OPTIONS (user 'postgres', password 'shard_password');

-- Создаем единую головную таблицу книг на Роутере с логикой Хэш-секционирования
CREATE TABLE books (
    book_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(150) NOT NULL,
    isbn VARCHAR(13) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0
) PARTITION BY HASH (book_id);

-- Привязываем удаленные шарды книг
CREATE FOREIGN TABLE books_p1 PARTITION OF books
    FOR VALUES WITH (MODULUS 2, REMAINDER 0)
    SERVER book_srv_1 OPTIONS (table_name 'books_shard_1');

CREATE FOREIGN TABLE books_p2 PARTITION OF books
    FOR VALUES WITH (MODULUS 2, REMAINDER 1)
    SERVER book_srv_2 OPTIONS (table_name 'books_shard_2');


-- =========================================================================
-- НАСТРОЙКА КЛАТЕРА STORES (Вертикальный шардинг, без горизонтального)
-- =========================================================================

-- Регистрируем удаленный сервер для магазинов
CREATE SERVER store_srv FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'store-db', dbname 'store_db', port '5432');

-- Создаем сопоставление пользователей
CREATE USER MAPPING FOR postgres SERVER store_srv OPTIONS (user 'postgres', password 'store_password');

-- Подключаем удаленную таблицу магазинов напрямую (она монолитна)
CREATE FOREIGN TABLE stores (
    store_id INT NOT NULL,
    store_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    address VARCHAR(255) NOT NULL,
    manager_name VARCHAR(100) NOT NULL
) SERVER store_srv OPTIONS (table_name 'stores_main');
