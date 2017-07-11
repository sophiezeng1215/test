

--q1
SELECT cities.city_name, 
       PERCENTILE_DISC(0.9) WITHIN GROUP (ORDER BY trips.predicted_eta – trips.actual_eta)
       as 90th_percentile
FROM trips LEFT OUTER JOIN cities ON trips.city_id = cities.city_id
WHERE cities.city_name IN (‘Qarth’, ‘Meereen’) 
AND trips.status = ‘completed’
AND trops.request_at > CURRENT_TIMESTAMP -  INTERVAL ‘30 days’;


--q2
SELECT cities.city_name, 
       EXTRACT (DOW of events._ts) AS day_of_week,    
       (SUM (CASE WHEN events.rider_id IN 
                  (SELECT DISTINCT trips.client_id FROM trips                
                   INNER JOIN events
                   ON trips.client_id = events.rider_id
                   WHERE trips.status = ‘completed’ 
                   AND trips.request_at < events._ts + INTERVAL ‘168 hours’) 
              THEN 1 ELSE 0 END)*100.0
        / COUNT(*)) AS percentage
FROM events 
LEFT OUTER JOIN cities 
ON events.city_id = cities.city_id
WHERE events.event_name = ‘sign_up_success’
AND cities.city_name IN (‘Qarth’, ‘Mareen’)
AND EXTRACT(YEAR FROM events._ts) = 2016
AND EXTRACT(WEEK FROM events._ts) = 1
GROUP BY cities.city_name, day_of_week;


--q2 version 2
/* SELECT cities.city_name, 
       EXTRACT (DOW of events._ts) AS day_of_week,    
       (SUM (CASE WHEN events.rider_id IN 
                  (SELECT client_id, MIN(request_at) FROM trips
                   WHERE status = ‘completed’ 
                   GROUP BY client_id) 
                   request_at < events._ts + INTERVAL ‘168 hours’ 
                   
                   trips.client_id FROM trips                
                   LEFT OUTER JOIN events
                   ON trips.client_id = events.rider_id
                   WHERE trips.status = ‘completed’ 
                   AND trips.request_at < events._ts + INTERVAL ‘168 hours’) 
              THEN 1 ELSE 0 END)*100.0
        / COUNT(*)) AS percentage
FROM events 
LEFT OUTER JOIN cities 
ON events.city_id = cities.city_id
WHERE events.event_name = ‘sign_up_success’
AND cities.city_name IN (‘Qarth’, ‘Mareen’)
AND EXTRACT(YEAR FROM events._ts) = 2016
AND EXTRACT(WEEK FROM events._ts) = 1
GROUP BY cities.city_name, day_of_week;
 */
 
 
--p2 Someone else's

SELECT signups_enhanced.day_of_week, AVG(rode_in_first_week::int)
  FROM

  -- Create sub-table with one row for every rider who signed up, with rode_in_first_week metric
   ( SELECT events.*
        EXTRACT( DOW FROM _ts) AS day_of_week
        -- Actually compute rode_in_first_week metric
        -- Check if user has a ride
        (MIN(trips.request_at) IS NOT NULL
         -- First ride within 168 hours
        AND MIN(trips.request_at) <= MIN(events._ts) + INTERVAL '168 hours'
        -- No rides before sign up
        AND MIN(trips.request_at) >= MIN(events._ts))
          AS rode_in_first_week
      FROM trips
      LEFT OUTER JOIN

        --   Create sub-table with every rider's first completed trip
        (SELECT DISTINCT ON (trips.client_id) trips.client_id, request_at
          FROM trips
            WHERE trips.status == 'completed'
          ORDER BY trips.request_at ASC
        ) AS first_completed_trips

        WHERE events.rider_id  == first_completed_trips.client_id
        AND event_name == 'sign_up_success'
    ) AS signups_enhanced

    GROUP BY signups_enhanced.day_of_week
    WHERE EXTRACT(WEEK FROM signup_ts) == 1
      AND EXTRACT(YEAR FROM signup_ts) == 2016;
      AND city_name IN ('Qarth', 'Meereen');
