SELECT 
    COUNT(*)

FROM

(SELECT
    room_type
    ,minimum_nights
    ,availability_365

FROM
    airbnb_2019

WHERE
    room_type = 'Private room'
    OR room_type = 'Entire home/apt') AS two_types


-- How do I check to see if an Airbnb labeled neighborhood is outside of the NY
-- Does it make sense to join the SQL tables by borough type and create a view with this join? How would I then check to see if an airbnb dot was in the right borders?

CREATE TABLE NYC_2019 
(
    id integer NOT NULL
    ,name text
    ,host_id integer NOT NULL
    ,host_name text
    ,neighbourhood_group text
    ,neighbourhood text
    ,latitude numeric
    ,longitude numeric
    ,room_type text
    ,price integer
    ,minimum_nights smallint
    ,number_of_reviews smallint
    ,last_review date
    ,reviews_per_month numeric
    ,calculated_host_listings_count smallint
    ,availability_365 smallint
)
-- Changed tablename

ALTER TABLE nyc_2019
  RENAME TO airbnb_2019;

-- Populating Postgres Table with data from a CSV

COPY 
    nyc_2019

FROM 
    '/Users/galvanize/Documents/projects/AB_NYC_2019.csv' DELIMITER ',' CSV HEADER;




COPY
(SELECT 
    neighbourhood
    ,COUNT(neighbourhood)

FROM
    airbnb_2019

GROUP BY
    neighbourhood

ORDER BY
    2 DESC)

TO '/Users/galvanize/Documents/regression/teleco/newtest.csv' csv header;


-- Grouping neighborhood posts together, and counting all NYC neighborhoods. 221 neighborhoods, probably some overlap
WITH all_neighborhoods AS (
    SELECT 
    neighbourhood
    ,COUNT(neighbourhood)

    FROM
        airbnb_2019

    GROUP BY
        neighbourhood

    ORDER BY
        2 DESC)


SELECT 
    COUNT(*)

FROM
    all_neighborhoods;


--Creating neighborhood table

CREATE TABLE nyc_neighborhoods 
(
    the_geom geometry
    ,BoroCode integer
    ,CountyFIPS integer
    ,BoroName text
    ,NTACode varchar
    ,NTAName text
    ,Shape_Length numeric
    ,Shape_Area numeric
)

-- Populating Postgres Table with data from a CSV

COPY 
    nyc_neighborhoods

FROM 
    '/Users/galvanize/Downloads/cityofnewyork_neighborhoods.csv' DELIMITER ',' CSV HEADER;

-- The count neighborhoods from the city of NY (195 neighborhoods) 


-- Making points in postgres
SELECT ST_MakePoint(longitude,latitude) as geom 
FROM airbnb_2019

-- Adding a new column

SELECT AddGeometryColumn('airbnb_2019', 'geom', 4326, 'POINT', 2);  
UPDATE airbnb_2019 SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);


-- TESTING PGADMIN JOINS 
SELECT bnb.host_name, bnb.price, nyc.ntacode 
FROM airbnb_2019 as bnb
JOIN nyc_neighborhoods as nyc
ON bnb.neighbourhood_group = nyc.boroname;

SELECT nyc.the_geom, ST_SetSRID(ST_MakePoint(bnb.longitude, bnb.latitude),4326)
FROM nyc_neighborhoods as nyc
JOIN airbnb_2019 as bnb
ON bnb.neighbourhood = nyc.ntaname;


-- Neighborhoods that airbnb and the city of new york have in common
SELECT
    COUNT(*)

FROM

(SELECT
    bnb.neighbourhood
    ,nyc.ntaname

FROM
    airbnb_2019 as bnb
JOIN
    nyc_neighborhoods as nyc
ON
    bnb.neighbourhood_group = nyc.boroname

WHERE
    bnb.neighbourhood = nyc.ntaname

GROUP BY
    1,2

ORDER BY
    1) AS in_common

-- Count of them is 67

SELECT
    bnb.neighbourhood
    ,nyc.ntaname

FROM
    airbnb_2019 as bnb
JOIN
    nyc_neighborhoods as nyc
ON
    bnb.neighbourhood_group = nyc.boroname

WHERE
    bnb.neighbourhood != nyc.ntaname

GROUP BY
    1,2