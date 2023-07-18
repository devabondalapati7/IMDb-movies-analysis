
-- Segment 1: Database - Tables, Columns, Relationships
-- A. What are the different tables in the database and how are they connected to each other in the database?
use imdb;
SHOW tables; -- here we have 6 different tables & connection is many to one by observing ER diagrams

-- B. Find the total number of rows in each table of the schema.
select count(*) as total_row from director_mapping; -- 3867
select count(*) as total_row from genre; -- 14663
select count(*) as total_row from movie; -- 7997
select count(*) as total_row from names; -- 25735
select count(*) as total_row from ratings; -- 7997
select count(*) as total_row from role_mapping; -- 15615

-- C. Identify which columns in the movie table have null values.
SELECT 
  COUNT(CASE WHEN id IS NUll THEN 1 END) AS id_null_check,
  COUNT(CASE WHEN title IS NULL then 1 END) AS title_null_check,
  COUNT(CASE WHEN year is null THEN 1 END) AS year_null_check,
  COUNT(CASE WHEN date_published is null THEN 1 END) AS dp_null_check,
  COUNT(CASE WHEN duration is null THEN 1 END) AS duration_null_check,
  COUNT(CASE WHEN country is null THEN 1 END) AS country_null_check,
  COUNT(CASE WHEN worlwide_gross_income is null THEN 1 END) AS wgi_null_check,
  COUNT(CASE WHEN languages is null THEN 1 END) AS languages_null_check,
  COUNT(CASE WHEN production_company is null THEN 1 END) AS pc_null_check
FROM movie;

-- ---------------------------------------------------------------------------------------------------------------------------------------

-- Segment 2: Movie Release Trends

-- A. Determine the total number of movies released each year and analyse the month-wise trend.
SELECT year,
SUM(title) total_movie 
FROM movie 
group by year;

SELECT month(date_published) as month_wise, 
sum(title) AS total_movie 
FROM movie 
GROUP BY month_wise 
ORDER BY total_movie desc;

-- B. Calculate the number of movies produced in the USA or India in the year 2019.
SELECT COUNT(title) as total_movies
 FROM movie WHERE (year = '2019') 
 AND 
 (country = 'India' OR country = 'USA');

-- ----------------------------------------------------------------------------------------------------------------------------------------

-- Segment 3: Production Statistics and Genre Analysis
-- A. Retrieve the unique list of genres present in the dataset.
SELECT DISTINCT(genre) 
FROM genre;

-- B. Identify the genre with the highest number of movies produced overall.
SELECT g.genre ,
COUNT(m.title) as movie_count 
from movie m 
join genre g 
on m.id= g.movie_id 
GROUP BY g.genre
ORDER BY movie_count DESC LIMIT 1;

-- C. Determine the count of movies that belong to only one genre.
WITH count_info as
( 
	SELECT m.title, 
	count(g.genre) as genre_count 
	from movie m 
	join genre g 
	on m.id= g.movie_id 
	group by m.title  
	having genre_count = 1
)
SELECT COUNT(*) AS movie_count 
FROM count_info; 

-- D. Calculate the average duration of movies in each genre.
SELECT title,genre, 
avg(duration) over(partition by g.genre order by title) as avg_time
from movie m 
join genre g 
on m.id= g.movie_id ;

-- E. Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.
WITH info AS
(
	SELECT g.genre , 
	COUNT(m.title) as movie_count
	from movie m 
	join genre g 
	on m.id= g.movie_id 
	GROUP BY g.genre
)
SELECT *,
row_number() over(order by movie_count DESC) as n_rank 
FROM info;

--             OR

SELECT GENRE,COUNT(MOVIE_ID) as MOVIE_COUNT,
DENSE_RANK() OVER (ORDER BY COUNT(genre.movie_id) DESC) AS genre_rank
FROM movie
JOIN genre ON movie.id = genre.movie_id
GROUP BY genre;

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Segment 4: Ratings Analysis and Crew Members
-- A. Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).
SELECT MIN(avg_rating) AS min_avg_rating,
MAX(avg_rating) AS max_avg_rating,
MIN(total_votes) AS min_total_votes,
MAX(total_votes) AS max_total_votes,
MIN(median_rating) AS min_median_rating,
MAX(median_rating) AS max_median_rating 
FROM ratings;

-- B. Identify the top 10 movies based on average rating.
SELECT m.title,r.avg_rating 
FROM movie m 
JOIN ratings r 
ON m.id=r.movie_id 
ORDER BY r.avg_rating DESC LIMIT 10;

-- C. Summarise the ratings table based on movie counts by median ratings.
SELECT r.median_rating , 
COUNT(m.title) AS movie_count 
FROM movie m 
JOIN ratings r 
ON m.id=r.movie_id 
GROUP BY r.median_rating
ORDER BY movie_count DESC;

-- D. Identify the production house that has produced the most number of hit movies (average rating > 8).
SELECT m.production_company, 
COUNT(m.title) as movie_count 
FROM movie m 
JOIN ratings r 
ON m.id=r.movie_id 
WHERE r.avg_rating > 8
GROUP BY m.production_company
ORDER BY movie_count DESC;

-- E. Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.
SELECT g.genre,
COUNT(m.title) as movie_count 
from movie m 
join genre g 
on m.id = movie_id
join ratings r 
on m.id =  r.movie_id 
WHERE 	(m.date_published BETWEEN '2017-03-01' AND '2017-03-31')
		AND (m.country = 'USA') 
        AND (r.total_votes > 1000)
GROUP BY genre;

-- F. Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.
SELECT g.genre,
COUNT(m.title) as movie_count 
from movie m 
join genre g 
on m.id = movie_id
join ratings r 
on m.id =  r.movie_id 
WHERE (m.title LIKE 'The%') AND r.avg_rating>8
GROUP BY genre;



-- ---------------------------------------------------------------------------------------------------------------------------------------

-- Segment 5: Crew Analysis
-- A. Identify the columns in the names table that have null values.
SELECT 
  COUNT(CASE WHEN id IS NUll THEN 1 END) AS id_null_check,
  COUNT(CASE WHEN name IS NULL then 1 END) AS name_null_check,
  COUNT(CASE WHEN height is null THEN 1 END) AS height_null_check,
  COUNT(CASE WHEN date_of_birth is null THEN 1 END) AS dob_null_check,
  COUNT(CASE WHEN known_for_movies is null THEN 1 END) AS kfm_null_check
  FROM names;
  
-- B.Determine the top three directors in the top three genres with movies having an average rating > 8.
SELECT d.name_id 
FROM director_mapping d
JOIN genre g
ON g.movie_id = d.movie_id
WHERE g.genre IN
(
	SELECT g.genre 
	FROM genre g 
	JOIN ratings r 
	ON g.movIe_id = r.movie_id
	WHERE r.avg_rating>8
	ORDER BY avg_rating DESC
) LIMIT 3;
-- C. Find the top two actors whose movies have a median rating >= 8.
select rm.name_id 
from role_mapping rm 
JOIN ratings r 
ON rm.movie_id= r.movie_id 
WHERE r.median_rating>=8
ORDER BY median_rating DESC 
LIMIT 2;

-- D. Identify the top three production houses based on the number of votes received by their movies.
SELECT m.production_company
FROM movie m 
JOIN ratings r 
ON m.id = r.movie_id
ORDER BY r.total_votes DESC 
LIMIT 3;
 
-- E. Rank actors based on their average ratings in Indian movies released in India.

SELECT rm.name_id,
ROW_NUMBER() OVER(ORDER BY r.avg_rating DESC) AS actors_ranking
FROM role_mapping rm
JOIN movie m 
ON m.id=rm.movie_id
JOIN ratings r 
ON r.movie_id = m.id
WHERE m.country = 'India';

-- F. Identify the top five actresses in Hindi movies released in India based on their average ratings
SELECT rm.name_id
FROM role_mapping rm
JOIN movie m 
ON m.id=rm.movie_id
JOIN ratings r 
ON r.movie_id = m.id
WHERE m.country = 'India'
AND rm.category='actress'
ORDER BY r.avg_rating DESC LIMIT 5;

-- ----------------------------------------------------------------------------------------------------------------------------------------
-- Segment 6: Broader Understanding of Data

-- A. Classify thriller movies based on average ratings into different categories.
SELECT g.movie_id,
CASE 
WHEN r.avg_rating >9 THEN 'Best movie'
WHEN r.avg_rating >7.5 THEN 'Good movie'  
WHEN r.avg_rating > 6 THEN 'Average movie' 
ELSE 'Not a good movie'
END as movie_category
    
FROM genre g 
JOIN ratings r
ON g.movie_id= r.movie_id 
WHERE g.genre = 'Thriller';

-- B. analyse the genre-wise running total and moving average of the average movie duration.
							-- CONCEPT USED
							-- select *,	
							-- sum(age) 	over (partition by name order by name) as new_sum,
							-- avg(age)	over (partition by name order by name) as new_age
							-- from t20;
select g.genre,	
sum(m.duration)	over (partition by g.genre order by m.title) as new_duration,
avg(m.duration)  over(partition by g.genre order by m.title) as new_avg
FROM movie m 
JOIN genre g
ON m.id = g.movie_id;	





-- C. Identify the five highest-grossing movies of each year that belong to the top three genres.
WITH info as
(
	SELECT m.title,m.year,
	row_number() over(partition by m.year order by worlwide_gross_income DESC ) as movie_rank
	FROM movie m
)
SELECT * 
FROM info
WHERE movie_rank BETWEEN 1 AND 5; 

-- D. Determine the top two production houses that have produced the highest number of hits among multilingual movies.
SELECT production_company
FROM movie
WHERE
(
	SELECT COUNT(languages) AS lang_of_movie
    FROM movie
)>=2
ORDER BY  worlwide_gross_income DESC 
LIMIT 2;

-- E. Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.
SELECT name 
FROM names
WHERE id IN
(
	SELECT rm.name_id 
	FROM role_mapping rm
	JOIN ratings r
	ON r.movie_id = rm.movie_id 
	JOIN genre g 
	ON g.movie_id = rm.movie_id
	WHERE (r.avg_rating > 8) AND (g.genre = 'drama') AND rm.category = 'actress'
	ORDER BY r.avg_rating DESC 
)LIMIT 2;

-- F. Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.
SELECT *
FROM
(SELECT  NAMES.NAME AS DIRECTOR_NAME,
COUNT(DISTINCT(MOVIE.ID)) AS TOTAL_MOVIE,
AVG(DURATION), 
AVG(AVG_RATING) AS AVGR,
ROW_NUMBER() OVER(PARTITION BY COUNT(DISTINCT(MOVIE.ID)) ORDER BY AVG(DURATION) DESC ,AVG(AVG_RATING) DESC ) AS RNUM
FROM DIRECTOR_MAPPING
JOIN NAMES ON DIRECTOR_MAPPING.NAME_ID = NAMES.ID
JOIN RATINGS ON DIRECTOR_MAPPING.MOVIE_ID = RATINGS.MOVIE_ID
JOIN MOVIE ON DIRECTOR_MAPPING.MOVIE_ID = MOVIE.ID
GROUP BY NAME
ORDER BY TOTAL_MOVIE DESC) AS X
WHERE X.RNUM = 1;

SELECT  NM.NAME AS DIRECTOR_NAME,
COUNT(*) AS TOTAL_MOVIE,
AVG(M.DURATION) AS AVG_DURATION, 
AVG(R.AVG_RATING) AS AVGR,
SUM(R.TOTAL_VOTES) AS TOTAL_VOTES

FROM DIRECTOR_MAPPING DM
JOIN NAMES NM ON DM.NAME_ID = NM.ID
JOIN RATINGS R ON DM.MOVIE_ID = R.MOVIE_ID
JOIN MOVIE M ON DM.MOVIE_ID = M.ID
GROUP BY NAME
ORDER BY TOTAL_MOVIE DESC 
LIMIT 9;
