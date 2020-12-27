#
# Add new film
#

-- Default values
SET @is_cartoon = 0;
SET @age_limit = 'R';
SET @year_of_release = YEAR(CURDATE()); 


DELIMITER //

-- Function to get age_limit_id
DROP FUNCTION IF EXISTS get_age_limit_id//
CREATE FUNCTION get_age_limit_id(age_lim VARCHAR(10))
RETURNS TINYINT DETERMINISTIC
BEGIN
	RETURN (SELECT id FROM age_limits WHERE age_limit = age_lim);
END//

-- Create trigger to set default values before inserting into 'films'
DROP TRIGGER IF EXISTS check_data_before_film_insert//
CREATE TRIGGER check_data_before_film_insert BEFORE INSERT ON films
FOR EACH ROW
BEGIN 
	DECLARE al VARCHAR(10);
	SELECT get_age_limit_id(@age_limit) INTO al;
	SET NEW.age_limit_id = COALESCE(NEW.age_limit_id, al);
	SET NEW.year_of_release = COALESCE(NEW.year_of_release, @year_of_release);
	SET NEW.is_cartoon = COALESCE(NEW.is_cartoon, @is_cartoon);
END//

DELIMITER ;


-- To check that default values will be used
INSERT
	INTO
	films (film_name, description)
VALUES ('test', 'description');

SELECT * FROM films f WHERE film_name = 'test';


