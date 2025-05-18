-- COHORTS FROM TIME SERIES

SELECT
    first_state,
    period,
    FIRST_VALUE(cohort_retained) OVER (PARTITION BY first_state ORDER BY period) AS cohort_size,
    cohort_retained,
    cohort_retained * 1.0 / FIRST_VALUE(cohort_retained) OVER (PARTITION BY first_state ORDER BY period) AS pct_retained

FROM (
    SELECT 
        a.first_state,
        COALESCE(DATE_PART('year', AGE(c.date, a.first_term)), 0) AS period,
        COUNT(DISTINCT a.id_bioguide) AS cohort_retained
    FROM (
        SELECT
            DISTINCT id_bioguide,
            MIN(term_start) OVER (PARTITION BY id_bioguide) AS first_term,
            FIRST_VALUE(state) OVER (PARTITION BY id_bioguide ORDER BY term_start) AS first_state
        FROM legislators_terms
    ) a
    JOIN legislators_terms b ON a.id_bioguide = b.id_bioguide
    LEFT JOIN date_dim c ON c.date BETWEEN b.term_start AND b.term_end
        AND c.month_name = 'December' AND c.day_of_month = 31
    GROUP BY a.first_state, COALESCE(DATE_PART('year', AGE(c.date, a.first_term)), 0)
) aa;






SELECT
	first_century, period,
	FIRST_VALUE(cohort_retained) OVER (PARTITION BY 
										first_century ORDER BY period) AS
											cohort_size,
	cohort_retained,
	cohort_retained * 1.0 / FIRST_VALUE(cohort_retained) OVER
							(PARTITION BY first_century ORDER BY period) AS
								pct_retained
FROM
(
	SELECT 
		DATE_PART('century', a.first_term) AS first_century,
		COALESCE(DATE_PART('year', AGE(c.date, a.first_term)), 0) AS period,
		COUNT(DISTINCT a.id_bioguide) AS cohort_retained
	FROM
	(
		SELECT
			id_bioguide, MIN(term_start) AS first_term
		FROM legislators_terms
		GROUP BY id_bioguide
	) a
	JOIN legislators_terms b ON a.id_bioguide = b.id_bioguide
	LEFT JOIN date_dim c ON c.date BETWEEN b.term_start AND b.term_end
		AND c.month_name = 'December' AND c.day_of_month = 31
	GROUP BY 1,2
) aa
ORDER BY 1,2
;

-- RETENTION
SELECT
	period,
	FIRST_VALUE(cohort_retained) OVER (ORDER BY period) AS cohort_size,
	cohort_retained,
	cohort_retained * 1.0 /  FIRST_VALUE(cohort_retained) 
								OVER (ORDER BY period) AS pct_retained
FROM
(
	SELECT
		COALESCE(DATE_PART('year', AGE(c.date, a.first_term)), 0) AS period
		, COUNT(DISTINCT a.id_bioguide) AS cohort_retained
	FROM
	(
		SELECT
			id_bioguide, MIN(term_start) AS first_term
		FROM legislators_terms
		GROUP BY id_bioguide
	) a
	JOIN legislators_terms b ON a.id_bioguide = b.id_bioguide
	LEFT JOIN date_dim c ON c.date BETWEEN b.term_start AND b.term_end
		AND c.month_name = 'December' AND c.day_of_month = 31
	GROUP BY  1
) aa;




SELECT
	a.id_bioguide, a.first_term,
	b.term_start, b.term_end,
	c.date,
	date_part('year', age(c.date, a.first_term)) as period
FROM
(
	SELECT
		id_bioguide, min(term_start) as first_term
	FROM legislators_terms
	GROUP BY id_bioguide
) a
JOIN legislators_terms b ON a.id_bioguide = b.id_bioguide
LEFT JOIN date_dim c ON c.date BETWEEN b.term_start AND b.term_end
	AND c.month_name = 'December' AND c.day_of_month = 31;


SELECT 
	period,
	first_value(cohort_retained) over (order by period) as cohort_size,
	cohort_retained,
	cohort_retained * 1.0 / first_value(cohort_retained) over (order by period) as pct_retained
FROM
(
	SELECT 
		date_part('year', age(b.term_start, a.first_term)) as period,
		count(distinct a.id_bioguide) as cohort_retained
	FROM
	(
		SELECT 
			id_bioguide,
			min(term_start) as first_term
		FROM legislators_terms
		GROUP BY id_bioguide
	) a
	JOIN legislators_terms b ON a.id_bioguide = b.id_bioguide
	GROUP BY period
) aa
;



SELECT cohort_size
	,max(case when period = 0 then pct_retained end) as yr0
	,max(case when period = 1 then pct_retained end) as yr1
	,max(case when period = 2 then pct_retained end) as yr2
	,max(case when period = 3 then pct_retained end) as yr3
	,max(case when period = 4 then pct_retained end) as yr4
FROM
(
        SELECT period
        ,first_value(cohort_retained) over (order by period) as cohort_size
        ,cohort_retained
        ,cohort_retained * 1.0 / first_value(cohort_retained) over (order by period) as pct_retained
        FROM
        (
                SELECT 
                date_part('year',age(b.term_start,a.first_term)) as period
                ,count(*) as cohort_retained
                FROM
                (
                        SELECT id_bioguide
                        ,min(term_start) as first_term
                        FROM legislators_terms 
                        GROUP BY 1
                ) a
                JOIN legislators_terms b on a.id_bioguide = b.id_bioguide 
                GROUP BY 1
        ) aa
) aaa
GROUP BY 1
;
