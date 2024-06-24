CREATE DATABASE IF NOT EXISTS exampledb;
CREATE USER 'exampleuser'@'%' IDENTIFIED BY 'examplepass';
GRANT ALL PRIVILEGES ON exampledb.* TO 'exampleuser'@'%';
FLUSH PRIVILEGES;
