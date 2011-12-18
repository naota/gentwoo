TRUNCATE TABLE cache_pop_packages;
TRUNCATE TABLE cache_pop_users;

INSERT INTO cache_pop_packages (cnt, package_id, created_at)
  SELECT count(emerges.id) AS cnt, packages.id, CURRENT_TIMESTAMP FROM packages 
  INNER JOIN emerges ON emerges.package_id = packages.id 
  WHERE (buildtime > date_add(CURRENT_TIMESTAMP, interval -7 day)) 
  GROUP BY package_id;

INSERT INTO cache_pop_users (cnt, user_id, created_at)
  SELECT count(emerges.id) AS cnt, users.id,CURRENT_TIMESTAMP FROM users
  INNER JOIN emerges ON emerges.user_id = users.id
  WHERE (buildtime > date_add(CURRENT_TIMESTAMP, interval -7 day))
  GROUP BY user_id;
