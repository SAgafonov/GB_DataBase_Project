#
# TABLES actors, cities, countries, languages, media, profiles, users
# Fix the case when created_at > updated_at
#

UPDATE actors SET updated_at = (now() - interval floor(rand()*(60*24*60)) second) WHERE created_at > updated_at;
UPDATE cities SET updated_at = (now() - interval floor(rand()*(60*24*60)) second) WHERE created_at > updated_at;
UPDATE countries SET updated_at = (now() - interval floor(rand()*(60*24*60)) second) WHERE created_at > updated_at;
UPDATE languages SET updated_at = (now() - interval floor(rand()*(60*24*60)) second) WHERE created_at > updated_at;
UPDATE media SET updated_at = (now() - interval floor(rand()*(60*24*60)) second) WHERE created_at > updated_at;
UPDATE profiles SET updated_at = (now() - interval floor(rand()*(60*24*60)) second) WHERE created_at > updated_at;
UPDATE users SET updated_at = (now() - interval floor(rand()*(60*24*60)) second) WHERE created_at > updated_at;


#
# TABLE profiles
# Check that user is more than 18 y.o. 
# Set random country and city
#

UPDATE profiles SET birthday = (DATE_FORMAT(DATE_SUB(created_at, INTERVAL 19 YEAR), '%Y-%m-%d')) WHERE DATEDIFF(created_at, birthday) < 6600;
UPDATE profiles SET city_id = 1 + FLOOR(RAND() * 50), country_id = 1 + FLOOR(RAND() * 50);


#
# TABLE films
# Update created_at if expiration date of user's purchase is before film's creation date
#

UPDATE films f
JOIN user_purchases up
ON up.film_id = f.id
SET f.created_at = DATE_SUB(up.expired_at, INTERVAL 1 YEAR)
WHERE up.expired_at < f.created_at;

#
# Use commented query below to check result of previous UPDATE.
#
-- SELECT up.user_id, up.film_id , up.expired_at, f.created_at
-- FROM user_purchases up
-- JOIN films f
-- ON up.film_id = f.id;


#
# TABLE films
# Update overall_votes, number_of_points according to data from TABLE user_ratings
#

UPDATE films f
JOIN (
	SELECT film_id, COUNT(number_of_stars) AS votes FROM user_ratings ur GROUP BY film_id
) AS ur 
ON f.id = ur.film_id
SET f.overall_votes = ur.votes;


UPDATE films f
JOIN (
	SELECT film_id, SUM(number_of_stars) AS sum_of_stars FROM user_ratings ur GROUP BY film_id
) AS ur 
ON f.id = ur.film_id
SET f.number_of_points = ur.sum_of_stars;

#
# Use commented query below to check result of two previous UPDATEs.
# f.overall_votes == number_of_votes; f.number_of_points == sum_of_stars
#
-- SELECT f.id AS film_id, f.overall_votes, f.number_of_points, COUNT(ur.number_of_stars) AS number_of_votes, SUM(ur.number_of_stars) AS sum_of_stars
-- FROM films f
-- JOIN user_ratings ur
-- ON f.id = ur.film_id
-- GROUP BY f.id ;


