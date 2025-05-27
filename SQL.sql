--Retrieves all columns and rows from the video_game_sales_mani table.
SELECT * FROM video_game_sales_mani;

-- Selects and displays the Name, Platform, and Global_Sales columns.
SELECT Name, Platform, Global_Sales FROM video_game_sales_mani;

-- Fetches all columns for games released after the year 2000.
SELECT * FROM video_game_sales_mani 
WHERE Year_of_Release > 2000;

-- Calculates total global sales for each platform.
SELECT Platform, SUM(Global_Sales) AS Total_Global_Sales
FROM video_game_sales_mani 
GROUP BY Platform;

-- Displays game names and their global sales, sorted from highest to lowest.
SELECT Name, Global_Sales FROM video_game_sales_mani
ORDER BY Global_Sales DESC;

-- Lists the top 5 best-selling sports games in North America 
SELECT Name, NA_Sales 
FROM (SELECT Name, NA_Sales 
      FROM video_game_sales_mani 
      WHERE Genre = 'Sports' 
      ORDER BY NA_Sales DESC)
WHERE ROWNUM <= 5;

-- Lists the top 5 best-selling sports games in Europe 
SELECT Name, EU_Sales 
FROM (SELECT Name, EU_Sales 
      FROM video_game_sales_mani 
      WHERE Genre = 'Sports' 
      ORDER BY EU_Sales DESC)
WHERE ROWNUM <= 5;

-- Counts and displays the number of games in each genre.
SELECT Genre, COUNT(*) AS NumberOfGames FROM video_game_sales_mani
GROUP BY Genre;

-- Find the top 5 developers that have produced the most games selling over 10 million copies globally
-- between 2000 and 2020
SELECT Developer, COUNT(*) AS games_over_10m
FROM video_game_sales_mani
WHERE Global_Sales > 10 AND Year_of_Release BETWEEN 2000 AND 2020
GROUP BY Developer
ORDER BY games_over_10m DESC
FETCH FIRST 5 ROWS ONLY;







