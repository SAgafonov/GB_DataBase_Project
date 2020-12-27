DROP DATABASE IF EXISTS kinopoisk;
CREATE DATABASE kinopoisk;

USE kinopoisk;


#
# TABLE STRUCTURE FOR: users
#

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY COMMENT "Record identifier",
	login VARCHAR(64) NOT NULL COMMENT "Username",
	email VARCHAR(100) NOT NULL COMMENT "Email",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated"
) COMMENT "Main information about users."; 
CREATE UNIQUE INDEX index_of_email_login ON users(email, login);
CREATE INDEX index_of_login ON users(login);


#
# TABLE STRUCTURE FOR: countries
#

DROP TABLE IF EXISTS countries;
CREATE TABLE countries (
	id SERIAL PRIMARY KEY COMMENT "Record identifier",
	country_name VARCHAR(64) NOT NULL COMMENT "Country's name",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated"
) COMMENT "List of available countries";
CREATE UNIQUE INDEX index_of_country_name ON countries(country_name);


#
# TABLE STRUCTURE FOR: cities
#

DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
	id SERIAL PRIMARY KEY COMMENT "Record identifier",
	city_name VARCHAR(64) NOT NULL COMMENT "City's name",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated"
) COMMENT "List of available cities";
CREATE UNIQUE INDEX index_of_city_name ON cities(city_name);


#
# TABLE STRUCTURE FOR: profiles
#

DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
	user_id BIGINT UNSIGNED NOT NULL COMMENT "Link to user",
	first_name VARCHAR(64) NOT NULL COMMENT "First name of a user",
	last_name VARCHAR(64) NOT NULL COMMENT "Last name of a user",
	birthday DATE NOT NULL COMMENT "Birthday of a user",
	gender ENUM('male', 'female') COMMENT "Gender of a user",
	phone VARCHAR(20) NOT NULL COMMENT "Phone number",
	country_id BIGINT UNSIGNED COMMENT "User's country",
	city_id BIGINT UNSIGNED COMMENT "User's city",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	PRIMARY KEY (user_id, phone),
	CONSTRAINT profiles_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
	CONSTRAINT profiles_country_id_fk FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE RESTRICT,
	CONSTRAINT profiles_city_id_fk FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE RESTRICT
) COMMENT "General information about users."; 
CREATE UNIQUE INDEX index_of_user_id_phone ON profiles(user_id, phone);
CREATE INDEX index_of_phone ON profiles(phone);


#
# TABLE STRUCTURE FOR: user_avatar
#

DROP TABLE IF EXISTS user_avatar;
CREATE TABLE user_avatar (
	user_id BIGINT UNSIGNED NOT NULL COMMENT "Link to user",
	path_to_file VARCHAR(255) NOT NULL COMMENT "Path to user's photo",
	file_size INT NOT NULL COMMENT "Size of a file",
	metadata JSON COMMENT "File's metadata",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	CONSTRAINT user_avatar_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) COMMENT "Include path to users' avatars, its metadata, size.";
CREATE INDEX index_of_avatar_file_size ON user_avatar(file_size);


#
# TABLE STRUCTURE FOR: age_limits
#

DROP TABLE IF EXISTS age_limits;
CREATE TABLE age_limits (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE COMMENT "Record identifier",
	age_limit VARCHAR(10) COMMENT "Type of age limit",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	PRIMARY KEY (id)
) COMMENT "List of age restrictions for films.";
CREATE INDEX index_of_age_limit ON age_limits(age_limit);


#
# TABLE STRUCTURE FOR: media_type
#

DROP TABLE IF EXISTS media_type;
CREATE TABLE media_type (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE COMMENT "Record identifier",
	name ENUM('video', 'teaser', 'photo') NOT NULL COMMENT "Type of media (video, teaser, photo)",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	PRIMARY KEY (id)
)  COMMENT "List of possible media types.";


#
# TABLE STRUCTURE FOR: media
#

DROP TABLE IF EXISTS media;
CREATE TABLE media (
	id SERIAL PRIMARY KEY COMMENT "Record identifier",
	media_type_id TINYINT(10) UNSIGNED NOT NULL COMMENT "Link to a type of media",
	path_to_file VARCHAR(255) NOT NULL COMMENT "Path to media",
	file_size INT NOT NULL COMMENT "Size of a file",
	metadata JSON COMMENT "File's metadata",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	CONSTRAINT media_media_type_id_fk FOREIGN KEY (media_type_id) REFERENCES media_type(id) ON DELETE RESTRICT
) COMMENT "Include path to all type of film's media: video, teaser, pictures.";
CREATE INDEX index_of_media_file_size ON media(file_size);


#
# TABLE STRUCTURE FOR: films
#

DROP TABLE IF EXISTS films;
CREATE TABLE films (
	id SERIAL PRIMARY KEY COMMENT "Record identifier",
	film_name VARCHAR(100) NOT NULL COMMENT "Movie's name",
	is_cartoon BOOLEAN NOT NULL COMMENT "True if it's a cartoon",
	price_for_rent DECIMAL(7,2) COMMENT "Price to rent a film",
	price_for_lifetime DECIMAL(7,2) COMMENT "Price to buy a film for a lifetime",
	age_limit_id TINYINT UNSIGNED NOT NULL COMMENT "Link to a type of age restriction",
	year_of_release YEAR NOT NULL COMMENT "Year of release",
	overall_votes BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT "Number of votes",
	number_of_points BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT "Number of stars the movie received",
	description TEXT NOT NULL COMMENT "What movie about",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	CONSTRAINT films_age_limit_id_fk FOREIGN KEY (age_limit_id) REFERENCES age_limits(id) ON DELETE RESTRICT
) COMMENT "General list of films and serials with prices, description, votes.";
CREATE INDEX index_of_film_name ON films(film_name);
CREATE INDEX index_of_price_for_lifetime_rent ON films(price_for_lifetime, price_for_rent);
CREATE INDEX index_of_year_of_release ON films(year_of_release);
CREATE INDEX index_of_overall_votes ON films(overall_votes);
CREATE INDEX index_of_number_of_points ON films(number_of_points);


#
# TABLE STRUCTURE FOR: movies
#

DROP TABLE IF EXISTS movies;
CREATE TABLE movies (
	film_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a movie",
	media_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a media",
	duration TIME COMMENT "Film's duration",
	CONSTRAINT movies_film_id_fk FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE RESTRICT,
	CONSTRAINT movies_media_id_fk FOREIGN KEY (media_id) REFERENCES media(id) ON DELETE RESTRICT
) COMMENT "Connects the title of the film with link to its file and photos";
CREATE INDEX index_of_duration ON movies(duration);


#
# TABLE STRUCTURE FOR: serials
#

DROP TABLE IF EXISTS serials;
CREATE TABLE serials (
	film_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a serial",
	media_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a media",
	series_num TINYINT UNSIGNED NOT NULL COMMENT "Number of a series",
	season_num TINYINT UNSIGNED NOT NULL COMMENT "Number of a season",
	duration TIME COMMENT "Film's duration",
	PRIMARY KEY (media_id, series_num, season_num) COMMENT "Composite primary key.",
	CONSTRAINT serials_film_id_fk FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE RESTRICT,
	CONSTRAINT serials_media_id_fk FOREIGN KEY (media_id) REFERENCES media(id) ON DELETE RESTRICT
) COMMENT "Connects the title of the seriel with links to its episodes and photos";
CREATE INDEX index_of_series_num ON serials(series_num);
CREATE INDEX index_of_season_num ON serials(season_num);
CREATE INDEX index_of_duration ON serials(duration);


#
# TABLE STRUCTURE FOR: film_countries
#

DROP TABLE IF EXISTS film_countries;
CREATE TABLE film_countries (
	film_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a movie or a serial",
	country_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a country",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	CONSTRAINT film_countries_film_id_fk FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE CASCADE,
	CONSTRAINT film_countries_country_id_fk FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE RESTRICT
) COMMENT "Connection between film and its country.";


#
# TABLE STRUCTURE FOR: actors
#

DROP TABLE IF EXISTS actors;
CREATE TABLE actors (
	id SERIAL COMMENT "Record identifier",
	first_name VARCHAR(125) COMMENT "First name of an actor",
	last_name VARCHAR(125) COMMENT "Last name of an actor",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	PRIMARY KEY (id)
) COMMENT "List of actors";
CREATE INDEX index_of_actor_first_name ON actors(first_name);
CREATE INDEX index_of_actor_last_name ON actors(last_name);


#
# TABLE STRUCTURE FOR: film_actors
#

DROP TABLE IF EXISTS film_actors;
CREATE TABLE film_actors (
	film_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a film",
	actor_id BIGINT UNSIGNED NOT NULL COMMENT "Link to an actor",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	CONSTRAINT film_actors_film_id_fk FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE CASCADE,
	CONSTRAINT film_actors_actor_id_fk FOREIGN KEY (actor_id) REFERENCES actors(id) ON DELETE RESTRICT
) COMMENT "Connection between film and its actors.";


#
# TABLE STRUCTURE FOR: genres
#

DROP TABLE IF EXISTS genres;
CREATE TABLE genres (
	id SERIAL PRIMARY KEY COMMENT "Record identifier",
	genre VARCHAR(20) NOT NULL COMMENT "Genre name",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated"
) COMMENT "List of film genres";
CREATE INDEX index_of_genre ON genres(genre);


#
# TABLE STRUCTURE FOR: film_genres
#

DROP TABLE IF EXISTS film_genres;
CREATE TABLE film_genres (
	film_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a film",
	genre_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a genre",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	CONSTRAINT film_genres_film_id_fk FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE CASCADE,
	CONSTRAINT film_genres_genre_id_fk FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE RESTRICT
) COMMENT "Connection between film and its genres.";


#
# TABLE STRUCTURE FOR: languages
#

DROP TABLE IF EXISTS languages;
CREATE TABLE languages (
	id SERIAL PRIMARY KEY COMMENT "Record identifier",
	language_name VARCHAR(20) COMMENT "Name of a language",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated"
) COMMENT "List of languages";
CREATE INDEX index_of_language_name ON languages(language_name);


#
# TABLE STRUCTURE FOR: film_languages
#

DROP TABLE IF EXISTS film_languages;
CREATE TABLE film_languages (
	film_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a film",
	language_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a language",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	PRIMARY KEY (film_id, language_id),
	CONSTRAINT film_languages_film_id_fk FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE CASCADE,
	CONSTRAINT film_languages_language_id_fk FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE RESTRICT
) COMMENT "Language(-s) what film is available on";


#
# TABLE STRUCTURE FOR: user_favorites
#

DROP TABLE IF EXISTS user_favorites;
CREATE TABLE user_favorites (
	user_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a user",
	film_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a film",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	PRIMARY KEY (user_id, film_id) COMMENT "Composite primary key",
	CONSTRAINT user_favorites_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	CONSTRAINT user_favorites_film_id_fk FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE CASCADE
) COMMENT "Represents films that users added to favorites";


#
# TABLE STRUCTURE FOR: user_ratings
#

DROP TABLE IF EXISTS user_ratings;
CREATE TABLE user_ratings (
	user_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a user",
	film_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a movie or a serial",
	number_of_stars TINYINT UNSIGNED NOT NULL COMMENT "Number of stars the user set to film",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	PRIMARY KEY (user_id, film_id) COMMENT "Composite primary key",
	CONSTRAINT user_ratings_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	CONSTRAINT user_ratings_film_id_fk FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE CASCADE
) COMMENT "Represents user ratings for films";


#
# TABLE STRUCTURE FOR: purchase_types
#

DROP TABLE IF EXISTS purchase_types;
CREATE TABLE purchase_types (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE COMMENT "Record identifier",
	purchase_type ENUM('lifetime', 'rent') COMMENT "Type of purchasing",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	PRIMARY KEY (id)
);


#
# TABLE STRUCTURE FOR: user_purchases
#

DROP TABLE IF EXISTS user_purchases;
CREATE TABLE user_purchases (
	user_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a user",
	film_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a movie or a serial",
	purchase_type_id TINYINT UNSIGNED NOT NULL COMMENT "Link to a purchase type",
	receipt_num  VARCHAR(128) UNIQUE NOT NULL COMMENT "Receipt",
	expired_at DATETIME COMMENT "Time when rent is expired. NULL if purchase_type is 'lifetime'. Rent time is fixed.",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	CONSTRAINT user_purchases_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
	CONSTRAINT user_purchases_film_id_fk FOREIGN KEY (film_id) REFERENCES films(id) ON DELETE RESTRICT,
	CONSTRAINT user_purchases_purchase_type_id_fk FOREIGN KEY (purchase_type_id) REFERENCES purchase_types(id) ON DELETE RESTRICT
) COMMENT "Represents what films users have bought";
CREATE INDEX index_of_expired_at ON user_purchases(expired_at);


#
# TABLE STRUCTURE FOR: user_is_watching
#

DROP TABLE IF EXISTS user_is_watching;
CREATE TABLE user_is_watching (
	user_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a user",
	media_id BIGINT UNSIGNED NOT NULL COMMENT "Link to a movie or a serial",
	stopped_at SMALLINT UNSIGNED COMMENT "Seconds from the beggining of a film. NULL if user has finished watching.",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Time when record was created",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE NOW() COMMENT "Time when record was updated",
	CONSTRAINT user_is_watching_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
	CONSTRAINT user_is_watching_film_id_fk FOREIGN KEY (media_id) REFERENCES media(id) ON DELETE RESTRICT
) COMMENT "Represents where user finished watch a movie";

