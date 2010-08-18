DROP TABLE IF EXISTS sets;
CREATE TABLE sets (
  id INTEGER NOT NULL AUTO_INCREMENT,
  name VARCHAR(128) NOT NULL,
  external_id CHAR(64) NOT NULL,
  PRIMARY KEY (id)
);


DROP TABLE IF EXISTS entity;
CREATE TABLE entity (
  id INTEGER NOT NULL AUTO_INCREMENT,
  name VARCHAR(128) NOT NULL,
  description VARCHAR(512) DEFAULT NULL,
  entity_key CHAR(64) NOT NULL,
  keyspace_id INTEGER NOT NULL,
  PRIMARY KEY (id)
);


DROP TABLE IF EXISTS set_entity;
CREATE TABLE set_entity (
  sets_id INTEGER NOT NULL,
  entity_id INTEGER NOT NULL,
  member_value DOUBLE DEFAULT NULL,
  PRIMARY KEY (sets_id, entity_id)
);

DROP TABLE IF EXISTS keyspace;
CREATE TABLE keyspace (
  id INTEGER NOT NULL AUTO_INCREMENT,
  organism VARCHAR(64) DEFAULT NULL,
  source VARCHAR(64) DEFAULT NULL,
  version VARCHAR(32) DEFAULT NULL,
  description VARCHAR(512) DEFAULT NULL,
  created TIMESTAMP,
  last_modified TIMESTAMP,
  PRIMARY KEY (id)
);

DROP TABLE IF EXISTS meta_sets;
CREATE TABLE meta_sets (
  sets_meta_id INTEGER DEFAULT NULL,
  sets_id INTEGER DEFAULT NULL,
  meta_meta_id INTEGER DEFAULT NULL
);

DROP TABLE IF EXISTS meta;
CREATE TABLE meta (
  id INTEGER NOT NULL AUTO_INCREMENT DEFAULT NULL,
  name VARCHAR(128) NOT NULL,
  external_id CHAR(64) NOT NULL,
  PRIMARY KEY (id)
);

DROP TABLE IF EXISTS roots;
CREATE TABLE roots (
  meta_id INTEGER NOT NULL,
  PRIMARY KEY (meta_id)
);

DROP TABLE IF EXISTS sets_info;
CREATE TABLE sets_info (
  sets_id INTEGER NOT NULL,
  name VARCHAR(64) NOT NULL,
  value VARCHAR(64) DEFAULT NULL
);

ALTER TABLE entity ADD FOREIGN KEY (keyspace_id) REFERENCES keyspace (id);
ALTER TABLE set_entity ADD FOREIGN KEY (sets_id) REFERENCES sets (id);
ALTER TABLE set_entity ADD FOREIGN KEY (entity_id) REFERENCES entity (id);
ALTER TABLE meta_sets ADD FOREIGN KEY (sets_meta_id) REFERENCES meta (id);
ALTER TABLE meta_sets ADD FOREIGN KEY (sets_id) REFERENCES sets (id);
ALTER TABLE meta_sets ADD FOREIGN KEY (meta_meta_id) REFERENCES meta (id);
ALTER TABLE sets_info ADD FOREIGN KEY (sets_id) REFERENCES sets (id);
ALTER TABLE roots ADD FOREIGN KEY (meta_id) REFERENCES meta (id);
