USE BookingData
GO

SELECT * FROM SILVER.Hotels
SELECT * FROM SILVER.HotelScores

---- Gold Schema ----
CREATE SCHEMA Gold  


-- 1. Dimension & Fact tables 

-- Dimension Hotels table 
CREATE TABLE GOLD.Dim_Hotels(
url_pk VARCHAR(500) PRIMARY KEY,
name VARCHAR(1000),
city VARCHAR(10),
lat FLOAT,
lon FLOAT,
facilities VARCHAR(1000),
pets VARCHAR(50)
)
INSERT INTO Gold.Dim_Hotels( url_pk , name , city , lat , lon , facilities , pets )
SELECT url_pk , name , city , lat , lon , facilities , pets 
FROM Silver.HOTELS
SELECT * FROM Gold.Dim_Hotels ;


-- Fact Hotel scores table 
CREATE TABLE Gold.Fact_HotelScores (
    url_pk VARCHAR(500),
    category VARCHAR(50),
    score FLOAT,
    CONSTRAINT PK_Hotel_Score PRIMARY KEY(url_pk , category ) ,
    CONSTRAINT FK_Hotel_Score FOREIGN KEY (url_pk) REFERENCES Gold.Dim_Hotels(url_pk)
)
INSERT INTO Gold.Fact_HotelScores(url_pk , category , score )
SELECT * FROM Silver.HotelScores

SELECT * FROM Gold.Fact_HotelScores ; 


-- Fact Hotel price table 
CREATE TABLE Gold.Fact_HotelPrice (
url_pk VARCHAR(500) PRIMARY KEY , 
min_price DECIMAL , 
max_price DECIMAL , 
avg_price DECIMAL , 

)

ALTER TABLE Gold.Fact_HotelPrice
ADD CONSTRAINT FK_price FOREIGN KEY (url_pk) REFERENCES Gold.Dim_Hotels(url_pk)

INSERT INTO Gold.Fact_HotelPrice 
SELECT url_pk , min_price , max_price , avg_price 
FROM Silver.HOTELS

SELECT * FROM Gold.Fact_HotelPrice


----------------------------|------------------|------------------------------------------
----------------------------|  Analysis Report |------------------------------------------
----------------------------|------------------|------------------------------------------

SELECT * FROM Gold.Dim_Hotels
SELECT * FROM Gold.Fact_HotelScores
SELECT * FROM Gold.Fact_HotelPrice

-- 1. Analysis Hotels by City 
SELECT city , COUNT(*) AS NumberOHotels 
FROM Gold.Dim_Hotels 
GROUP BY city


SELECT city , MIN(min_price) AS MinPrice ,MAX(max_price) AS MaxPrice ,AVG(avg_price) AS AvgPrice 
FROM Gold.Dim_Hotels D
JOIN 
Gold.Fact_HotelPrice F ON D.url_pk = F.url_pk 
GROUP BY city
ORDER BY AvgPrice Desc


SELECT city ,  ROUND(Avg(score), 2) AS AverageRate  
FROM Gold.Dim_Hotels D , Gold.Fact_HotelScores F
WHERE D.url_pk = F.url_pk 
GROUP BY city 
ORDER BY AverageRate DESC


--------- Analysis by Hotel --------

SELECT name , city , avg_price
FROM Gold.Dim_Hotels D
JOIN 
Gold.Fact_HotelPrice F ON D.url_pk = F.url_pk
ORDER BY avg_price  


SELECT D.name, D.city, AVG(F.score) AS overall_avg_score
FROM Gold.Dim_Hotels D
JOIN Gold.Fact_HotelScores F 
    ON D.url_pk = F.url_pk
GROUP BY 
    D.url_pk, 
    D.name, 
    D.city 

ORDER BY overall_avg_score DESC














