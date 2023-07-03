CREATE DEFINER=`sean_coley`@`%` PROCEDURE `sp_populate_date_dimension`()
BEGIN 

	DECLARE dt DATE;
	DECLARE end_dt DATE;
    DECLARE month_wk INT DEFAULT 1;
    DECLARE temp_month INT;

	SET dt = '2019-01-01';
	SET end_dt = '2030-12-31';
    SET temp_month = MONTH(dt);

	WHILE dt <= end_dt DO

        -- Reset week of the month if the month changes
        IF temp_month <> MONTH(dt) THEN
            SET month_wk = 1;
            SET temp_month = MONTH(dt);
        END IF;

		INSERT INTO
			date_dimension(
				date_key,
				`date`,
				`day`,
				day_suffix,
				`weekday`,
				weekday_name,
				weekday_name_short,
				weekday_name_first_letter,
				day_of_year,
				week_of_month,
				week_of_year,
				`month`,
				month_name,
				month_name_short,
				month_name_first_letter,
				`quarter`,
				quarter_name,
				`year`,
				mm_yyyy,
				month_year,
				is_weekend,
				is_holiday,
				first_date_of_year,
				last_date_of_year,
				first_date_of_quarter,
				last_date_of_quarter,
				first_date_of_month,
				last_date_of_month,
				first_date_of_week,
				last_date_of_week,
				fy_quarter,
				fy_quarter_name,
				fy_year,
				fy_month,
				first_date_of_financial_year,
				last_date_of_financial_year
			)
		VALUES
		(
				DATE_FORMAT(dt, '%Y%m%d'),
				dt,
				DAY(dt),
				CASE
					WHEN DAY(dt) IN (1, 21, 31) THEN 'st'
					WHEN DAY(dt) IN (2, 22) THEN 'nd'
					WHEN DAY(dt) IN (3, 23) THEN 'rd'
					ELSE 'th'
				END,
				DAYOFWEEK(dt),
				DAYNAME(dt),
				UPPER(SUBSTRING(DAYNAME(dt), 1, 3)),
				UPPER(SUBSTRING(DAYNAME(dt), 1, 1)),
				DAYOFYEAR(dt),
				month_wk,
				WEEK_OF_YEAR_CUSTOM(dt),
				MONTH(dt),
				MONTHNAME(dt),
				UPPER(SUBSTRING(MONTHNAME(dt), 1, 3)),
				UPPER(SUBSTRING(MONTHNAME(dt), 1, 1)),
				QUARTER(dt),
				CASE
					WHEN QUARTER(dt) = 1 THEN 'First'
					WHEN QUARTER(dt) = 2 THEN 'Second'
					WHEN QUARTER(dt) = 3 THEN 'Third'
					WHEN QUARTER(dt) = 4 THEN 'Fourth'
				END,
				YEAR(dt),
				CONCAT(MONTH(dt), YEAR(dt)),
				CONCAT(MONTHNAME(dt), YEAR(dt)),
				CASE
					WHEN DAYOFWEEK(dt) IN (1, 7) THEN 1
					ELSE 0
				END,
				0,
				MAKEDATE(YEAR(dt), 1),
				MAKEDATE(YEAR(dt), 365) + INTERVAL (IS_LEAP_YEAR(YEAR(dt)) > 0) DAY,
				DATE(CONCAT(YEAR(dt),'-', QUARTER(dt)*3-2,'-01')), 
                LAST_DAY(DATE_ADD(DATE(dt), INTERVAL 3 - MONTH(dt) % 3 MONTH)),
				DATE(dt - INTERVAL DAYOFMONTH(dt) - 1 DAY),
				LAST_DAY(dt),
				DATE(dt + INTERVAL (1 - DAYOFWEEK(dt)) DAY),
				DATE(dt + INTERVAL (7 - DAYOFWEEK(dt)) DAY),
				IF(MONTH(dt) >= 7, QUARTER(DATE_SUB(dt, INTERVAL 6 MONTH)), QUARTER(DATE_ADD(dt, INTERVAL 6 MONTH))),
				CASE
					WHEN IF(MONTH(dt) >= 7, QUARTER(DATE_SUB(dt, INTERVAL 6 MONTH)), QUARTER(DATE_ADD(dt, INTERVAL 6 MONTH))) = 1 THEN 'First'
					WHEN IF(MONTH(dt) >= 7, QUARTER(DATE_SUB(dt, INTERVAL 6 MONTH)), QUARTER(DATE_ADD(dt, INTERVAL 6 MONTH))) = 2 THEN 'Second'
					WHEN IF(MONTH(dt) >= 7, QUARTER(DATE_SUB(dt, INTERVAL 6 MONTH)), QUARTER(DATE_ADD(dt, INTERVAL 6 MONTH))) = 3 THEN 'Third'
					WHEN IF(MONTH(dt) >= 7, QUARTER(DATE_SUB(dt, INTERVAL 6 MONTH)), QUARTER(DATE_ADD(dt, INTERVAL 6 MONTH))) = 4 THEN 'Fourth'
				END,
				IF(MONTH(dt) >= 7, YEAR(dt), YEAR(dt) - 1),
				IF(MONTH(dt) >= 7, MONTH(dt) - 6, MONTH(dt) + 6),
				IF(MONTH(dt) >= 7, CONCAT(YEAR(dt), '-07-01'), CONCAT(YEAR(dt) -1, '-07-01')),
				IF(MONTH(dt) >= 7, CONCAT(YEAR(dt) +1, '-06-30'), CONCAT(YEAR(dt), '-06-30'))
			);

		SET dt = dt + INTERVAL 1 DAY;
        IF DAYOFWEEK(dt) = 1 THEN
			SET month_wk = month_wk + 1;
		END IF;

	END WHILE;

END