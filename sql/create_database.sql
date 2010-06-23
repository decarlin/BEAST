use BEAST_dev;
-- ---
-- Table 'entity_set'
-- This table is for defining gene sets and associated metadata (though metadata may be broken out into a separate table at some point)
-- ---

DROP TABLE IF EXISTS entity_set;
		
CREATE TABLE entity_set (
  id INTEGER NOT NULL AUTO_INCREMENT,
  name VARCHAR(128) NOT NULL,
  PRIMARY KEY (id)
);

-- ---
-- Table 'entity'
-- 
-- ---

DROP TABLE IF EXISTS entity;
		
CREATE TABLE entity (
  id INTEGER NOT NULL AUTO_INCREMENT,
  name VARCHAR(128) NOT NULL,
  description VARCHAR(256) DEFAULT NULL,
  entity_key VARCHAR(64) NOT NULL,
  keyspace_id INTEGER NOT NULL,
  PRIMARY KEY (id)
);

-- ---
-- Table 'entity_set_entity'
-- 
-- ---

DROP TABLE IF EXISTS entity_set_entity;
		
CREATE TABLE entity_set_entity (
  entity_set_id INTEGER NOT NULL,
  entity_id INTEGER NOT NULL,
  member_value DOUBLE DEFAULT NULL,
  PRIMARY KEY (entity_set_id, entity_id)
);

-- ---
-- Table 'keyspace'
-- 
-- ---

DROP TABLE IF EXISTS keyspace;
		
CREATE TABLE keyspace (
  id INTEGER NOT NULL AUTO_INCREMENT,
  organism VARCHAR(64) DEFAULT NULL,
  source VARCHAR(64) DEFAULT NULL,
  version INTEGER DEFAULT NULL,
  description VARCHAR(512) DEFAULT NULL,
  created TIMESTAMP,
  last_modified TIMESTAMP,
  PRIMARY KEY (id)
);

-- ---
-- Table 'entity_set_meta_data'
-- 
-- ---

DROP TABLE IF EXISTS entity_set_meta_data;
		
CREATE TABLE entity_set_meta_data (
  id INTEGER NOT NULL AUTO_INCREMENT,
  entity_set_id INTEGER NOT NULL,
  meta_data_type_id INTEGER NOT NULL,
  meta_data_value INTEGER DEFAULT NULL,
  PRIMARY KEY (id)
);

-- ---
-- Table 'meta_data'
-- 
-- ---

DROP TABLE IF EXISTS meta_data;
		
CREATE TABLE meta_data (
  id INTEGER NOT NULL AUTO_INCREMENT,
  name INTEGER NOT NULL,
  description INTEGER DEFAULT NULL,
  PRIMARY KEY (id)
);

-- ---
-- Foreign Keys 
-- ---

ALTER TABLE entity ADD FOREIGN KEY (keyspace_id) REFERENCES keyspace (id);
ALTER TABLE entity_set_entity ADD FOREIGN KEY (entity_set_id) REFERENCES entity_set (id);
ALTER TABLE entity_set_entity ADD FOREIGN KEY (entity_id) REFERENCES entity (id);
ALTER TABLE entity_set_meta_data ADD FOREIGN KEY (entity_set_id) REFERENCES entity_set (id);
ALTER TABLE entity_set_meta_data ADD FOREIGN KEY (meta_data_type_id) REFERENCES meta_data (id);

-- ---
-- Table Properties
-- ---

-- ALTER TABLE entity_set ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
-- ALTER TABLE entity ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
-- ALTER TABLE entity_set_entity ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
-- ALTER TABLE keyspace ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
-- ALTER TABLE entity_set_meta_data ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
-- ALTER TABLE meta_data ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- ---
-- Test Data
-- ---

-- INSERT INTO entity_set (id,name) VALUES
-- ('','');
-- INSERT INTO entity (id,name,description,entity_key,keyspace_id) VALUES
-- ('','','','','');
-- INSERT INTO entity_set_entity (entity_set_id,entity_id,member_value) VALUES
-- ('','','');
-- INSERT INTO keyspace (id,organism,source,version,description,created,last_modified) VALUES
-- ('','','','','','','');
-- INSERT INTO entity_set_meta_data (id,entity_set_id,meta_data_type_id,meta_data_value) VALUES
-- ('','','','');
-- INSERT INTO meta_data (id,name,description) VALUES
-- ('','','');


