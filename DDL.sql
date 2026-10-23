------- بسم الله اللهم لا سهلُا الا ما جعلته سهلا وانت اذا شئت تجعل الحزن سهلا --------

--- 1. Create database / schema / table ---
CREATE DATABASE BookingData ;
USE BookingData 
GO

CREATE SCHEMA Bronze ; 

CREATE TABLE Bronze.Hotels (
url_pk varchar(500) primary key, 
city varchar(10) not null , 
name varchar(200) not null  ,
lat float not null , 
lon float not null ,
min_price decimal , 
avg_price decimal ,
max_price decimal , 
facilities varchar(1000) , 
categories_scores varchar(1000) , 
pets varchar(50) )

ALTER TABLE BRONZE.HOTELS 
ALTER COLUMN NAME VARCHAR(1000)

ALTER TABLE BRONZE.HOTELS 
ALTER COLUMN lat float null 


ALTER TABLE BRONZE.HOTELS 
ALTER COLUMN lon float null 


INSERT 
INTO Bronze.Hotels(url_pk , city , name, lat , lon , min_price ,
				   avg_price , max_price , facilities , categories_scores ,pets )
SELECT * FROM dbo.hotels 


SELECT * FROM Bronze.Hotels 

