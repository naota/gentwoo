BEGIN TRANSACTION;

DELETE FROM cache_pop_packages;
DELETE FROM cache_pop_users;

INSERT INTO cache_pop_packages (cnt, package_id, created_at)
  SELECT count(emerges.id) AS cnt, packages.id, CURRENT_TIMESTAMP FROM packages 
  INNER JOIN emerges ON emerges.package_id = packages.id 
  WHERE (buildtime > datetime(CURRENT_TIMESTAMP, '-7 days')) 
  GROUP BY package_id;

INSERT INTO cache_pop_users (cnt, user_id, created_at)
  SELECT count(emerges.id) AS cnt, users.id,CURRENT_TIMESTAMP FROM users
  INNER JOIN emerges ON emerges.user_id = users.id
  WHERE (buildtime > datetime(CURRENT_TIMESTAMP, '-7 days')) 
  GROUP BY user_id;

COMMIT TRANSACTION;
