CREATE DATABASE IF NOT EXISTS exampledb;

-- Check if the user exists before creating it
CREATE USER IF NOT EXISTS 'exampleuser'@'%' IDENTIFIED BY 'examplepass';

-- Grant privileges to the user
GRANT ALL PRIVILEGES ON exampledb.* TO 'exampleuser'@'%';

FLUSH PRIVILEGES;
