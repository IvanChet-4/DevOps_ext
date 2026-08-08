CREATE TABLE users_shard_1 (
    user_id BIGINT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    registration_date TIMESTAMP NOT NULL DEFAULT NOW()
);
