USE master;

create TABLE netflix_titles(
	[show_id] [varchar](10) primary key,
	[type] [varchar](10) NULL,
	[title] [nvarchar](200) NULL,
	[director] [varchar](250) NULL,
	[cast] [varchar](1000) NULL,
	[country] [varchar](150) NULL,
	[date_added] [varchar](20) NULL,
	[release_year] [int] NULL,
	[rating] [varchar](10) NULL,
	[duration] [varchar](10) NULL,
	[listed_in] [varchar](100) NULL,
	[description] [varchar](500) NULL
);

SELECT * FROM netflix_titles;

-- Selecting specific show by show_id
SELECT * FROM netflix_titles 
WHERE show_id='s5023';

-- Removing duplicates
SELECT show_id, COUNT(*) 
FROM netflix_titles
GROUP BY show_id 
HAVING COUNT(*) > 1;

-- Finding duplicates based on title and type
SELECT * FROM netflix_titles
WHERE CONCAT(UPPER(title), type) IN (
    SELECT CONCAT(UPPER(title), type) 
    FROM netflix_titles
    GROUP BY UPPER(title), type
    HAVING COUNT(*) > 1
)
ORDER BY title;

-- Removing duplicates and retaining unique rows
WITH cte AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY title, type ORDER BY show_id) AS rn
    FROM netflix_titles
)
SELECT show_id, type, title, CAST(date_added AS DATE) AS date_added, release_year, rating, 
    CASE WHEN duration IS NULL THEN rating ELSE duration END AS duration, description
INTO netflix
FROM cte 
WHERE rn = 1;

-- Select all rows from netflix
SELECT * FROM netflix;

-- Extracting genres into a separate table
SELECT show_id, TRIM(value) AS genre
INTO netflix_genre
FROM netflix_titles
CROSS APPLY STRING_SPLIT(listed_in, ',');

-- Creating netflix_country table
SELECT show_id, TRIM(value) AS country
INTO netflix_country
FROM netflix_titles
CROSS APPLY STRING_SPLIT(country, ',');

-- Creating netflix_directors table
SELECT show_id, TRIM(value) AS director
INTO netflix_directors
FROM netflix_titles
CROSS APPLY STRING_SPLIT(director, ',');

-- Creating netflix_cast table
SELECT show_id, TRIM(value) AS cast_member
INTO netflix_cast
FROM netflix_titles
CROSS APPLY STRING_SPLIT(cast, ',');

-- Select all rows from netflix_titles
SELECT * FROM netflix_titles;

-- Populating missing values in the country column
INSERT INTO netflix_country
SELECT show_id, m.country 
FROM netflix_titles nr
INNER JOIN (
    SELECT director, country
    FROM netflix_country nc
    INNER JOIN netflix_directors nd ON nc.show_id = nd.show_id
    GROUP BY director, country
) m ON nr.director = m.director
WHERE nr.country IS NULL;

-- Select specific director's entries
SELECT * FROM netflix_titles WHERE director='Ahishor Solomon';

-- Grouping by director and country
SELECT director, country
FROM netflix_country nc
INNER JOIN netflix_directors nd ON nc.show_id = nd.show_id
GROUP BY director, country;

-- Select rows with null duration
SELECT * FROM netflix_titles WHERE duration IS NULL;

-- Netflix data analysis

-- 1. Directors who created both movies and TV shows
SELECT nd.director, 
    COUNT(DISTINCT CASE WHEN n.type = 'Movie' THEN n.show_id END) AS no_of_movies,
    COUNT(DISTINCT CASE WHEN n.type = 'TV Show' THEN n.show_id END) AS no_of_tvshow
FROM netflix n
INNER JOIN netflix_directors nd ON n.show_id = nd.show_id
GROUP BY nd.director
HAVING COUNT(DISTINCT n.type) > 1;

-- 2. Country with the highest number of comedy movies
SELECT TOP 1 nc.country, COUNT(DISTINCT ng.show_id) AS no_of_movies
FROM netflix_genre ng
INNER JOIN netflix_country nc ON ng.show_id = nc.show_id
INNER JOIN netflix n ON ng.show_id = nc.show_id
WHERE ng.genre = 'Comedies' AND n.type = 'Movie'
GROUP BY nc.country
ORDER BY no_of_movies DESC;

-- 3. Director with maximum movies released each year
WITH cte AS (
    SELECT nd.director, YEAR(date_added) AS date_year, COUNT(n.show_id) AS no_of_movies
    FROM netflix n
    INNER JOIN netflix_directors nd ON n.show_id = nd.show_id
    WHERE type = 'Movie'
    GROUP BY nd.director, YEAR(date_added)
), cte2 AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY date_year ORDER BY no_of_movies DESC, director) AS rn
    FROM cte
)
SELECT * FROM cte2 WHERE rn = 1;

-- 4. Average duration of movies in each genre
SELECT ng.genre, AVG(CAST(REPLACE(duration, ' min', '') AS INT)) AS avg_duration
FROM netflix n
INNER JOIN netflix_genre ng ON n.show_id = ng.show_id
WHERE type = 'Movie'
GROUP BY ng.genre;

-- 5. Directors who have created both horror and comedy movies
SELECT nd.director,
    COUNT(DISTINCT CASE WHEN ng.genre = 'Comedies' THEN n.show_id END) AS no_of_comedy,
    COUNT(DISTINCT CASE WHEN ng.genre = 'Horror Movies' THEN n.show_id END) AS no_of_horror
FROM netflix n
INNER JOIN netflix_genre ng ON n.show_id = ng.show_id
INNER JOIN netflix_directors nd ON n.show_id = nd.show_id
WHERE type = 'Movie' AND ng.genre IN ('Comedies', 'Horror Movies')
GROUP BY nd.director
HAVING COUNT(DISTINCT ng.genre) = 2;

-- Select genres for a specific director
SELECT * FROM netflix_genre WHERE show_id IN 
(SELECT show_id FROM netflix_directors WHERE director = 'Steve Brill')
ORDER BY genre;
