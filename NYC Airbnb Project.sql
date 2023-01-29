


--loading our data to have a a general overview of what it looks like

--review table
SELECT *
FROM [NYC AirBnb Project].dbo.airbnb_last_review

--price table
SELECT *
FROM [NYC AirBnb Project].dbo.airbnb_price

--room type
SELECT *
FROM [NYC AirBnb Project].dbo.airbnb_room_type

--for our kpi
--kpi1 total number of listing, 
SELECT COUNT(distinct listing_id) as number_of_listing
FROM [NYC AirBnb Project].dbo.airbnb_last_review

--kpi2 latest day of listing, 
SELECT top 1 last_review, listing_id
FROM [NYC AirBnb Project].dbo.airbnb_last_review
order by 1 desc


--kpi3 most priced listing,

SELECT top 1 listing_id, price
FROM [NYC AirBnb Project].dbo.airbnb_price
order by 2 desc


--kpi4 what type of room is most priced
SELECT top 1 room_type, listing_id, description
FROM [NYC AirBnb Project].dbo.airbnb_room_type
where listing_id = 8069030
order by 1 desc


-- Q1. What is the average price, per night, of an Airbnb listing in NYC?
SELECT FORMAT(avg(CONVERT(money, price)), 'C', 'en-US') AS average_price_pernight
FROM [NYC AirBnb Project].dbo.airbnb_price
WHERE (price!=0) and price is not null;

--Q2. How does the average price of an Airbnb listing, per month, compare to the private rental market? 
-- According to https://www.rent.com/research/average-rent-price-report/ rent prices across diffrent bedroom types in New York City costs, on average, $4,010  per month factoring price flunctuations 
--calculating our average price for Airbnb in a month 
SELECT FORMAT(avg(CONVERT(money, price)*365/12), 'C', 'en-US') AS average_price_perMonth
FROM [NYC AirBnb Project].dbo.airbnb_price
WHERE (price!=0) and price is not null;

--q3. How many adverts are for private rooms?
SELECT room_type, count(room_type) AS room_type_adverts
	FROM(
		SELECT * 
		FROM [NYC AirBnb Project].dbo.airbnb_room_type
		WHERE room_type LIKE '%private%'
		) as type
GROUP BY room_type

--q4. How do Airbnb listing prices compare across the five NYC boroughs?
---joining the tables to get prices in comparism across NYC boroughs using Union

SELECT	[NYC AirBnb Project].dbo.airbnb_room_type.listing_id, [NYC AirBnb Project].dbo.airbnb_last_review.host_name, [NYC AirBnb Project].dbo.airbnb_last_review.last_review, 
		[NYC AirBnb Project].dbo.airbnb_room_type.description, [NYC AirBnb Project].dbo.airbnb_room_type.room_type, 
		[NYC AirBnb Project].dbo.airbnb_price.nbhood_full, [NYC AirBnb Project].dbo.airbnb_price.boroughs, [NYC AirBnb Project].dbo.airbnb_price.price        
FROM [NYC AirBnb Project].dbo.airbnb_room_type
FULL JOIN [NYC AirBnb Project].dbo.airbnb_price ON [NYC AirBnb Project].dbo.airbnb_room_type.listing_id = [NYC AirBnb Project].dbo.airbnb_price.listing_id
FULL JOIN [NYC AirBnb Project].dbo.airbnb_last_review ON [NYC AirBnb Project].dbo.airbnb_price.listing_id = [NYC AirBnb Project].dbo.airbnb_last_review.listing_id;

---Using CTE
WITH NYC_AirBnb_Listing
AS
(
SELECT	[NYC AirBnb Project].dbo.airbnb_room_type.listing_id, [NYC AirBnb Project].dbo.airbnb_last_review.host_name, [NYC AirBnb Project].dbo.airbnb_last_review.last_review, 
		[NYC AirBnb Project].dbo.airbnb_room_type.description, [NYC AirBnb Project].dbo.airbnb_room_type.room_type, 
		[NYC AirBnb Project].dbo.airbnb_price.nbhood_full, [NYC AirBnb Project].dbo.airbnb_price.boroughs, [NYC AirBnb Project].dbo.airbnb_price.price        
FROM [NYC AirBnb Project].dbo.airbnb_room_type
FULL JOIN [NYC AirBnb Project].dbo.airbnb_price ON [NYC AirBnb Project].dbo.airbnb_room_type.listing_id = [NYC AirBnb Project].dbo.airbnb_price.listing_id
FULL JOIN [NYC AirBnb Project].dbo.airbnb_last_review ON [NYC AirBnb Project].dbo.airbnb_price.listing_id = [NYC AirBnb Project].dbo.airbnb_last_review.listing_id
)
SELECT boroughs, FORMAT(avg(CONVERT(money, price)), 'C', 'en-US') as average_price_per_borough
FROM NYC_AirBnb_Listing
GROUP BY boroughs
ORDER BY 2;

-- assigning label/price
--Budget	$0-69
--Average	$70-175
--Expensive	$176-350
--Extravagant	> $350



--Analogy2
WITH price_group_count
AS
(
SELECT  price, boroughs,
	CASE
	WHEN price  <= 69 THEN 'Budget'
	WHEN price > 69 AND price <= 175 THEN 'Average'
	WHEN price  > 175 AND price <= 350 THEN 'Expensive'
	ELSE 'Extravagant'
	END AS Price_category
FROM [NYC AirBnb Project].dbo.airbnb_price
)
SELECT distinct boroughs, Price_category, COUNT(Price_category) as no_of_time
FROM price_group_count
GROUP BY boroughs, Price_category
ORDER BY 2;

 -- CASE
 --   WHEN price  <= 69 THEN '$0-69'
	--WHEN price > 69 AND price <= 175 THEN '$70-175'
	--WHEN price  > 175 AND price <= 350 THEN '$176-350'
	--ELSE 'Above $350'
	--END AS Price_Value