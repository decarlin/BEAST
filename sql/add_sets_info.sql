
DROP TABLE IF EXISTS sets_info;
		
CREATE TABLE sets_info (
  sets_id INTEGER NOT NULL,
  name VARCHAR(64) NOT NULL,
  value VARCHAR(64) DEFAULT NULL
);

ALTER TABLE sets_info ADD FOREIGN KEY (sets_id) REFERENCES sets (id);
