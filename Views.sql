#
# VIEW: main data of users
#

DROP VIEW IF EXISTS users_main_data;

CREATE VIEW users_main_data AS
SELECT
	u.id,
	CONCAT(p.first_name, ' ', p.first_name) AS name,
	p.birthday,
	u.login,
	u.email,
	p.phone,
	ua.path_to_file AS user_avatar,
	purchases.num_of_user_purchases
FROM
	users u
JOIN profiles p ON
	u.id = p.user_id
LEFT JOIN user_avatar ua ON
	u.id = ua.user_id
LEFT JOIN (
	SELECT
		u.id AS id, COUNT(up.film_id) AS num_of_user_purchases
	FROM
		users u
	JOIN user_purchases up ON
		u.id = up.user_id
	GROUP BY
		u.id) AS purchases ON
	u.id = purchases.id
ORDER BY
	u.id;


#
# VIEW: movies and serials with their actors and languages
#

DROP VIEW IF EXISTS films_data;

CREATE VIEW films_data AS
SELECT f.id, f.film_name, movie.id AS media_movie_id, serial.series AS media_serial_id, lang_codes.film_lang AS languages, actrs.film_actrs AS actors
FROM films f
	LEFT JOIN (SELECT mv.film_id, m.id
			FROM media m
				LEFT JOIN media_type mt
					ON m.media_type_id = mt.id
				JOIN movies mv
					ON mv.media_id = m.id 
				WHERE mt.name = 'video'
			 ) AS movie
		ON f.id = movie.film_id
	LEFT JOIN (SELECT s.film_id,
			GROUP_CONCAT(m.id SEPARATOR ', ') AS series
			FROM media m
				LEFT JOIN media_type mt
					ON m.media_type_id = mt.id
				JOIN serials s
					ON s.media_id = m.id 
			WHERE mt.name = 'video'
			GROUP BY s.film_id) AS serial
		ON f.id = serial.film_id
	JOIN (SELECT f.id, GROUP_CONCAT(langs.language_name SEPARATOR ', ') AS film_lang
			FROM films f
				JOIN (SELECT fl.film_id, l.language_name 
					FROM languages l
						JOIN film_languages fl
							ON l.id = fl.language_id
				 	 ) AS langs
				ON f.id = langs.film_id 
			GROUP BY f.id) AS lang_codes 
		ON f.id = lang_codes.id
	JOIN (SELECT f.id, GROUP_CONCAT(actors.names SEPARATOR ', ') AS film_actrs
			FROM films f
				JOIN (SELECT fa.film_id, CONCAT(a.first_name, ' ', a.last_name) AS names
						FROM actors a
							JOIN film_actors fa
								ON a.id = fa.actor_id
					 ) AS actors
					ON f.id = actors.film_id 
			GROUP BY f.id) AS actrs
		ON f.id = actrs.id
ORDER BY f.id;


#
# VIEW: link films with their media
#

DROP VIEW IF EXISTS films_media_data;

CREATE VIEW films_media_data AS
SELECT
	f.id,
	f.film_name,
	movie_serials.path_to_file,
	movie_serials.metadata,
	movie_serials.type_name
FROM
	films f
LEFT JOIN (
	SELECT
		m_s.film_id, m.id AS media_id, m.metadata, m.path_to_file, mt.name AS type_name
	FROM
		(
		SELECT
			film_id, media_id
		FROM
			movies
	UNION
		SELECT
			film_id, media_id
		FROM
			serials) AS m_s
	JOIN media m ON
		m.id = m_s.media_id
	LEFT JOIN media_type mt ON
		m.media_type_id = mt.id) AS movie_serials ON
	f.id = movie_serials.film_id
ORDER BY
	f.id;


#
# VIEW: link movies with their media
#

DROP VIEW IF EXISTS movies_media_data;

CREATE VIEW movies_media_data AS
SELECT
	f.id,
	f.film_name,
	movie.path_to_file,
	movie.type_name AS media_type
FROM
	films f
JOIN (
	SELECT
		mv.film_id, m.id, m.path_to_file, mt.name AS type_name
	FROM
		media m
	LEFT JOIN media_type mt ON
		m.media_type_id = mt.id
	JOIN movies mv ON
		mv.media_id = m.id ) AS movie ON
	f.id = movie.film_id
ORDER BY
	f.id;


#
# VIEW: link serials with their media
#

DROP VIEW IF EXISTS serials_media_data;

CREATE VIEW serials_media_data AS
SELECT
	f.id,
	f.film_name,
	serial.season_num,
	serial.series_num,
	serial.path_to_file,
	serial.type_name AS media_type
FROM
	films f
JOIN (
	SELECT
		s.film_id, s.season_num, s.series_num, m.id, m.path_to_file, mt.name AS type_name
	FROM
		media m
	LEFT JOIN media_type mt ON
		m.media_type_id = mt.id
	JOIN serials s ON
		s.media_id = m.id ) AS serial ON
	f.id = serial.film_id
ORDER BY
	f.id;


#
# VIEW: TOP 5 the most spending users
#
DROP VIEW IF EXISTS biggest_spenders;

CREATE VIEW biggest_spenders AS
SELECT u.id, CONCAT(p.first_name, ' ', p.last_name) AS name, users_expenses.price
FROM users u
	JOIN profiles p
		ON u.id = p.user_id 
	JOIN (SELECT up.user_id AS id, SUM(IF(up.purchase_type_id = 1, f.price_for_lifetime, f.price_for_rent)) AS price 
			FROM user_purchases up 
			JOIN films f
			ON f.id = up.film_id 
			GROUP BY up.user_id) AS users_expenses
		ON u.id = users_expenses.id
	ORDER BY users_expenses.price DESC
LIMIT 5;
