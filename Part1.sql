

SELECT cities.city_name, 
EXTRACT (DOW of _ts) AS day_of_week, 
(SUM (CASE WHEN events.rider_id IN (SELECT client_id FROM trips LEFT OUTER JOIN events ON trips.client_id = events.rider_id WHERE status = ‘completed’ AND request_at < events._ts + INTERVAL ‘168 hours’) THEN 1 ELSE null end)/ COUNT(*) ) AS percentage
FROM events 
LEFT OUTER JOIN cities ON events.city_id = cities.city_id
WHERE events.event_name = ‘sign_up_success’
AND cities.city_name IN (‘Qarth’, ‘Mareen’)
AND EXTRACT(YEAR FROM events._ts) == 2016
AND EXTRACT(WEEK FROM events._ts) == 1
GROUP BY cities.city_name, day_of_week;

