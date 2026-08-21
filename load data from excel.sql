create database sample;

create table adventureworkssales
(CustomerKey int8 primary key,Customer_ID varchar(50) default null,Customer varchar(255) default null, City varchar(50) default null,State_Province varchar(50) default null,Country_Region varchar(50) default null,Postal_Code varchar(50)default null);

SET NAMES 'utf8'; 

load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\AdventureWorksSales.csv'
into table adventureworkssales
fields terminated by ','
LINES TERMINATED BY '\n'
ignore 1 rows;


show variables like "secure_file_priv";

show variables like "local_infile";
set global local_infile = 1;

# For each database:
ALTER DATABASE pqr_pvt_ltd CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
# For each table:
ALTER TABLE adventure_sales CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
# For each column:

ALTER TABLE adventure_sales MODIFY customer VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

select* from adventureworkssales;

SHOW VARIABLES LIKE 'character_set_server';
SHOW VARIABLES LIKE 'character_set_client';

