# GB_DataBase_Project
Project was developed using MySQL.
Project describes a simplified model of storage data on kinopoisk.

Main tables: users and films.
The following data is stored in developed database: 
- info about users, such as name, login, email, phone, country, etc.;
- list of films with the following data: title, price, age restrictions, rating, description, etc.;
- films' media such as directly video file, pictures, teasers;
- languages that films are available on;
- actors filmed in;
- info about users' purchases;
- info about what films users voted for;
etc.

To simplify data fetching the following views were created:
- users_main_data - represents main information about user plus their's avatar and number of purchases user has made. Combines data form tables users, profiles, user_avatar, user_purchases.
- films_data - represents id of media that has type 'video', languages that films are available on, actors filmed in. Combines data from films, media, languages, actors.;
- films_media_data - represents films media and metadata. Combines data from films, media, media_type, movies, serials;
- movies_media_data - represents only movies' media. Combines data from films, media, media_type, movies;
- serials_media_data - represents only serials' media. Combines data from films, media, media_type, serials;
- biggest_spenders - represents top 5 users that spended the most money. Combines data from users, profiles, user_purchases.

Also function and trigger where created to check if all data was provided before executing INSERT query to 'films' table. If not it sets to default value.
For example only 'name' and 'description' fields are required, 'is_cartoon', 'age_limit', 'year_of_release' will be setted automatically.

#### Steps to reproduce the DB
Execute files in the following order:
1. DB_and_Tables_Creation.sql
2. Fill_DB_In.sql
3. Correct_Data.sql
4. Views.sql
5. Triggers_StoredProcedures.sql
6. Optional. Use Selections_Examples.sql to execute some queries provided as examples.
