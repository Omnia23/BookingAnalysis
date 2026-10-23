USE BookingData 
GO

SELECT * FROM Bronze.Hotels

--------- Creating Silver Schema ---------
CREATE SCHEMA Silver ;


SELECT * 
INTO SILVER.HOTELS 
FROM Bronze.Hotels

SELECT * FROM Silver.HOTELS

---- 1. Datatypes ----

SELECT 
	c.name as Column_name ,
	t.name as DataType ,
	c.max_length 
FROM sys.columns c , sys.types t 
WHERE t.user_type_id = c.user_type_id and c.object_id = OBJECT_ID('Silver.Hotels')

ALTER TABLE SILVER.HOTELS 
ADD CONSTRAINT PK PRIMARY KEY(url_pk)


---- 2. Null values ----
SELECT 
	SUM(CASE WHEN url_pk IS NULL THEN 1 ELSE 0 END ) AS URL_null, 
	SUM(CASE WHEN CITY IS NULL THEN 1 ELSE 0 END ) AS city_null ,
	SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END ) AS name_null  ,
	SUM(CASE WHEN lat IS NULL THEN 1 ELSE 0 END ) AS lat_null ,
	SUM(CASE WHEN lon IS NULL THEN 1 ELSE 0 END ) AS lon_null ,
	SUM(CASE WHEN avg_price IS NULL THEN 1 ELSE 0 END ) AS price_null  ,
	SUM(CASE WHEN min_price IS NULL THEN 1 ELSE 0 END ) AS min_price_null  ,
	SUM(CASE WHEN max_price IS NULL THEN 1 ELSE 0 END ) AS max_price_null  ,
	SUM(CASE WHEN facilities IS NULL THEN 1 ELSE 0 END )AS faci_null  ,
	SUM(CASE WHEN categories_scores IS NULL THEN 1 ELSE 0 END ) AS catg_null  ,
	SUM(CASE WHEN pets IS NULL THEN 1 ELSE 0 END ) AS pet_null 
FROM Silver.HOTELS


SELECT * 
FROM Silver.HOTELS
WHERE name IS NULL 
	OR lat IS NULL 
	OR lon IS NULL 
	OR avg_price IS NULL 
	OR min_price IS NULL 
	OR max_price IS NULL 
	OR pets IS NULL 


UPDATE Silver.HOTELS
SET name = 'Suzanne Guest House' , 
	lat = 25.677379505124243 , 
	lon = 32.628349579521974 , 
	min_price = 1941 , 
	max_price = 2156 , 
	avg_price = (1941 + 2156) / 2, 
	pets  = 'Pets are allowed'
WHERE url_pk = 'https://www.booking.com/hotel/eg/suzanne-gusts-house.html'


UPDATE Silver.HOTELS
SET
	min_price = 997 , 
	max_price = 2965 , 
	avg_price = (997 + 2965 + 1407) / 3, 
	pets  = 'Pets are not allowed'
WHERE url_pk = 'https://www.booking.com/hotel/eg/luxor-bella-vista-apartments.html'

UPDATE Silver.HOTELS
SET pets  = 'Pets are not allowed'
WHERE url_pk = 'https://www.booking.com/hotel/eg/holiday-inn-suites-cairo-maadi-an-ihg.html'


DELETE FROM Silver.HOTELS
WHERE url_pk = 'https://www.booking.com/hotel/eg/eel-garden-paradise-dahab.html'


------ 3.Data Quality ----
SELECT * FROM Silver.HOTELS

-- Name Cleaning --
SELECT url_pk , name 
FROM Silver.HOTELS 
WHERE name LIKE '%[^a-zA-Z0-9 ]%'

UPDATE Silver.HOTELS
SET name = LTRIM(RTRIM(REPLACE(name , '?' , '')))

UPDATE Silver.HOTELS
SET name = LTRIM(RTRIM(REPLACE(name , '-' , '')))

-- check null agains 
-- no null values ! 

SELECT * FROM Silver.HOTELS

-- Price Column Statisticals --

SELECT 
	MIN(min_price) AS MinPrice, 
	MAX(max_price) AS MaxPrice,
	AVG(avg_price) As AvgPrice ,
	COUNT(*) AS TotalHotels
FROM Silver.HOTELS 

SELECT name , city , avg_price 
FROM Silver.HOTELS 
WHERE  avg_price > (
	SELECT AVG(avg_price) + 2 * STDEV(avg_price)
	FROM Silver.HOTELS
)
ORDER BY city


-- 4. Categoties scores ---

SELECT TOP 1 url_pk , categories_scores
FROM Silver.HOTELS
ORDER BY LEN(categories_scores) DESC  


SELECT 
    h.url_pk,
    j.[key] AS score_name,
    j.[value] AS score_value
FROM Silver.HOTELS h
CROSS APPLY OPENJSON(REPLACE(h.categories_scores, '''', '"')) j;

-- Creating new table for url + category name + score --

CREATE TABLE Silver.HotelScores(
url_pk VARCHAR(500),
category VARCHAR(50) , 
score FLOAT ,
PRIMARY KEY(url_pk , category)
);


INSERT INTO Silver.HotelScores (url_pk, category, score)
SELECT 
    h.url_pk,
    j.[key],
    CAST(j.[value] AS FLOAT)
FROM Silver.HOTELS h
CROSS APPLY OPENJSON(REPLACE(h.categories_scores, '''', '"')) j;


SELECT * FROM Silver.HotelScores

-- Detect null values 

SELECT * 
FROM Silver.HotelScores 
WHERE category IS NULL OR score IS NULL 

--- Delet category scores from base table ---

ALTER TABLE [Silver].[Hotels] 
DROP COLUMN categories_scores 

------ Silver layer is Done ------


