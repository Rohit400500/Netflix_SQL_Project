-- Netfix project

CREATE TABLE netflix
(
	show_id	VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(210),
	castS VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),	
	duration VARCHAR(15),
	listed_in VARCHAR(80),
	description VARCHAR(250)
);

SELECT * FROM netflix;

SELECT
	DISTINCT(TYPE) 
FROM
	NETFLIX;

--   15 BUSINESS PROBLEMS
  
-- 1. Count the number of Movies vs TV Shows

SELECT
	type,
	COUNT(SHOW_ID) AS TOTAL_CONTENT
FROM
	NETFLIX
GROUP BY
	type;

-- 2. Find the most common rating for movies and TV shows

SELECT
	TYPE,
	RATING
FROM
	(
		SELECT
			TYPE,
			COUNT(RATING),
			RATING,
			RANK() OVER (
				PARTITION BY
					TYPE
				ORDER BY
					COUNT(RATING) DESC
			)
		FROM
			NETFLIX
		GROUP BY
			1,
			3
		ORDER BY
			2 DESC
	)
WHERE
	RANK = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT
	*
FROM
	NETFLIX
WHERE
	TYPE = 'Movie'
	AND RELEASE_YEAR = 2020;

-- 4. Find the top 5 countries with the most content on Netflix

SELECT
	UNNEST(STRING_TO_ARRAY(COUNTRY, ',')),
	COUNT(SHOW_ID) AS C
FROM
	NETFLIX
GROUP BY
	1
ORDER BY
	C DESC
LIMIT
	5;

-- 5. Identify the longest movie


SELECT * FROM NETFLIX
WHERE
	TYPE = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM NETFLIX)


-- 6. Find content added in the last 5 years

SELECT
	*
FROM
	NETFLIX
WHERE
	TO_DATE(DATE_ADDED, 'Month,DD,YYYY') >= CURRENT_DATE - INTERVAL '5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM NETFLIX
WHERE director like '%Rajiv Chilaka%' 


-- 8. List all TV shows with more than 5 seasons

SELECT
	*
FROM
	NETFLIX
WHERE
	TYPE = 'TV Show' 
	AND
	SPLIT_PART(duration, ' ' , 1)::numeric >5

-- 9. Count the number of content items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(LISTED_IN, ',')) AS GENRE,
	COUNT(SHOW_ID) AS TOTAL_CONTENT
FROM
	NETFLIX
GROUP BY 1

-- 10.Find each year and the average numbers of content release in India on netflix.
-- return top 5 year with highest avg content release!

SELECT
	EXTRACT(YEAR
		FROM
			TO_DATE(DATE_ADDED, 'Month DD,YYYY')) AS YEAR,
	COUNT(*) AS YEARLY_CONTENT,
	ROUND(
		COUNT(*)::NUMERIC / (
			SELECT
				COUNT(*)
			FROM
				NETFLIX
			WHERE
				COUNTRY = 'India'
		)::NUMERIC * 100,
		2) AS AVG_CONTENT_PER_YEAR
FROM
	NETFLIX
WHERE
	COUNTRY = 'India'
GROUP BY 1

-- 11. List all movies that are documentaries

SELECT * FROM NETFLIX
WHERE listed_in ILIKE '%Documentaries'
	AND
	TYPE = 'Movie'

-- 12. Find all content without a director
SELECT * FROM
	NETFLIX
WHERE
	DIRECTOR IS NULL
	
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM
	NETFLIX
WHERE
	CASTS ILIKE '%Salman Khan%'
	AND RELEASE_YEAR > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT
	COUNT(SHOW_ID),
	UNNEST(STRING_TO_ARRAY(CASTS, ','))
FROM
	NETFLIX
WHERE country ILIKE '%India'
GROUP BY 2
ORDER BY 1 DESC LIMIT 10

-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

WITH new_table
AS
(
SELECT *, CASE
		  WHEN
		  	description ILIKE '%kill%' OR 
			description ILIKE '%violence%' THEN 'Bad_content'
			ELSE 'Good_content'
			END category
FROM NETFLIX
)
SELECT category, COUNT(*) as total_content
FROM new_table
GROUP BY 1