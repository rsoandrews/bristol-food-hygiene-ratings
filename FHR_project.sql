/* 
Bristol Food Hygiene Ratings Analysis
-------------------------------------
Question: Which types of food business in Bristol are most likely to have low hygiene ratings?

Data: Food Standards Agency food hygiene rating open data (https://ratings.food.gov.uk/open-data), Local Authority: Bristol, downloaded 2026-11-01
Contains public sector information licensed under the Open Government Licence v3.0.
*/

SELECT TOP 20 * 
FROM hygiene_ratings;

SELECT
	RatingValue,
    COUNT(*) AS num_of_businesses
FROM hygiene_ratings
GROUP BY RatingValue
ORDER BY RatingValue;

-- Average rating by business type
SELECT
	BusinessType,
	COUNT(*) AS num_of_businesses,
	AVG(CAST(RatingValue AS DECIMAL(3,2))) AS avg_rating
FROM hygiene_ratings
WHERE RatingValue IN ('0', '1', '2', '3', '4', '5') -- ignores Exempt/AwaitingInspection/AwaitingPublication
GROUP BY BusinessType
HAVING COUNT(*) >= 20 -- removes small groups
ORDER BY avg_rating;

-- Share of low-rated (0-2) businesses by business type
SELECT 
    BusinessType,
    COUNT(*) AS total_rated,
    SUM(CASE WHEN RatingValue IN ('0','1','2') THEN 1 ELSE 0 END) AS low_rated,
    CAST(100.0 * SUM(CASE WHEN RatingValue IN ('0','1','2') THEN 1 ELSE 0 END) 
         / COUNT(*) AS DECIMAL(5,1)) AS pct_low
FROM hygiene_ratings
WHERE RatingValue IN ('0','1','2','3','4','5')
GROUP BY BusinessType
HAVING COUNT(*) >= 20
ORDER BY pct_low DESC;

-- Overall % of low-rated businesses for comparison
SELECT
	COUNT(*) AS total_rated,
    SUM(CASE WHEN RatingValue IN ('0','1','2') THEN 1 ELSE 0 END) AS low_rated,
	CAST(100.0 * SUM(CASE WHEN RatingValue IN ('0','1','2') THEN 1 ELSE 0 END)
		/ COUNT(*) AS DECIMAL(5,1)) AS pct_low
FROM hygiene_ratings
WHERE RatingValue IN ('0','1','2','3','4','5')
AND BusinessType IN (
	SELECT BusinessType
    FROM hygiene_ratings
    WHERE RatingValue IN ('0','1','2','3','4','5')
    GROUP BY BusinessType
    HAVING COUNT(*) >= 20
    );