

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
                  (SELECT trips.client_id FROM trips                
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

