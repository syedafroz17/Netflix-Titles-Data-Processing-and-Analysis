# Netflix-Titles-Data-Processing-and-Analysis

### Introduction
This document details the steps taken to load, transform, and analyze a dataset of Netflix titles. The data was sourced from the Kaggle API, loaded into a SQL database, and subsequently transformed for further analysis. We utilized an Extract, Load, Transform (ELT) approach to handle the data.

### ELT Process Overview
1. **Extract**: Data was extracted from Kaggle using the Kaggle API.
2. **Load**: The extracted data was loaded into a SQL database table named `netflix_titles`.
3. **Transform**: Various transformations were applied to clean the data, remove duplicates, and create related tables for genres, countries, directors, and cast members.
4. **Analysis**: The transformed data was analyzed to derive insights about directors, genres, countries, and more.

### Data Loading
The dataset was loaded into a SQL table with columns for show ID, type, title, director, cast, country, date added, release year, rating, duration, genres (listed_in), and description.

### Data Transformation
1. **Removing Duplicates**: 
   - Identified and removed duplicates based on the `show_id`.
   - Found and removed duplicates based on the combination of `title` and `type`.

2. **Extracting Related Tables**: 
   - Created separate tables for genres (`netflix_genre`), countries (`netflix_country`), directors (`netflix_directors`), and cast members (`netflix_cast`) by splitting the relevant columns.

3. **Populating Missing Values**:
   - Addressed null values in the `country` column by matching directors with existing country data.

### Data Analysis
Various analyses were performed to derive insights from the dataset:

1. **Directors Who Created Both Movies and TV Shows**:
   - Identified directors who have created both movies and TV shows and counted the number of each.

2. **Country with the Highest Number of Comedy Movies**:
   - Determined which country has produced the highest number of comedy movies.

3. **Director with Maximum Movies Released Each Year**:
   - Identified the director who released the maximum number of movies each year based on the `date_added` column.

4. **Average Duration of Movies in Each Genre**:
   - Calculated the average duration of movies for each genre.

5. **Directors Who Have Created Both Horror and Comedy Movies**:
   - Found directors who have created both horror and comedy movies and counted the number of each.

6. **Genres for a Specific Director**:
   - Listed all genres for the shows directed by a specific director.

### Conclusion
This documentation provides a comprehensive overview of the process followed to load, transform, and analyze Netflix titles data. By utilizing the ELT approach, we were able to efficiently handle the data, remove duplicates, and derive meaningful insights through various SQL queries.
