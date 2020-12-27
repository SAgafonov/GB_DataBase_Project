#
# Using JOIN for table 'user_avatar' and view 'users_main_data'. 
# Sort user's avatars by size.
#

SELECT umd.id, umd.name, umd.login, umd.email, ua.path_to_file, ua.file_size 
FROM users_main_data umd 
	JOIN user_avatar ua 
		ON umd.id = ua.user_id 
ORDER BY ua.file_size DESC;


#
# Get TOP 5 users who spent the most money.
#

SELECT name, price FROM biggest_spenders bs;


#
# Using view 'films_data' and table 'user_purchases' get user IDs who has bought films where Kelsie Nikolaus filmed.
#

SELECT fd.id, fd.film_name, GROUP_CONCAT(up.user_id SEPARATOR ', ') AS user_ids
	FROM user_purchases up
		JOIN films_data AS fd 
			ON up.film_id = fd.id 
	WHERE fd.actors like '%Kelsie Nikolaus%'
GROUP BY fd.id;


#
# Get list of films according to their genres
#

SELECT g.genre, GROUP_CONCAT(films_genres.film_name SEPARATOR ', ') AS films
	FROM genres g
		JOIN (SELECT fd.film_name, fg.genre_id 
				FROM films_data fd 
					JOIN film_genres fg
						ON fd.id = fg.film_id) AS films_genres
			ON g.id = films_genres.genre_id 
GROUP BY g.genre;


#
# Get amount of seasons and series in each serial
#
	
SELECT serial.film_id, f.film_name, serial.season_num AS season, COUNT(serial.series_num) AS number_of_series
FROM films f
JOIN (SELECT s.film_id, s.season_num, s.series_num 
			FROM media m
				LEFT JOIN media_type mt
					ON m.media_type_id = mt.id
				JOIN serials s
					ON s.media_id = m.id 
			WHERE mt.name = 'video') AS serial
		ON f.id = serial.film_id
GROUP BY serial.film_id, serial.season_num;


#
# Get info what film each user voted for. And film's rating.
#

SELECT
	f.id,
	f.film_name,
	GROUP_CONCAT(ur.user_id
		ORDER BY
		ur.user_id ASC SEPARATOR ', ') AS users,
		ROUND((select (f.number_of_points / f.overall_votes)), 2) AS rating
FROM
	films f
JOIN user_ratings ur ON
	f.id = ur.film_id
GROUP BY
	f.id;
