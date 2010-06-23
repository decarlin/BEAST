INSERT INTO keyspace (id, organism) VALUES (1, 'Vehicles');

 
INSERT INTO entity (id, name, description, entity_key, keyspace_id) VALUES (1,  'Fit', '', 'h_fit_2010', 1);
INSERT INTO entity (id, name, description, entity_key, keyspace_id) VALUES (2,  'Pilot', '', 'h_pilot_2010', 1);
INSERT INTO entity (id, name, description, entity_key, keyspace_id) VALUES (3,  'S2000', '', 'h_s2000_2010', 1);
INSERT INTO entity (id, name, description, entity_key, keyspace_id) VALUES (4,  'Odyssey', '', 'h_odyssey_2010', 1);

INSERT INTO entity (id, name, description, entity_key, keyspace_id) VALUES (5,  '335', '', 'b_335_2010', 1);
INSERT INTO entity (id, name, description, entity_key, keyspace_id) VALUES (6,  'X5', '', 'b_x5_2010', 1);
INSERT INTO entity (id, name, description, entity_key, keyspace_id) VALUES (7,  'M3', '', 'b_m3_2010', 1);
INSERT INTO entity (id, name, description, entity_key, keyspace_id) VALUES (8,  'M6', '', 'b_m3_2010', 1);

INSERT INTO entity (id, name, description, entity_key, keyspace_id) VALUES (9,  'Matrix', '', 't_matrix_2010', 1);
INSERT INTO entity (id, name, description, entity_key, keyspace_id) VALUES (10, 'Sienna', '', 't_sienna_2010', 1);
INSERT INTO entity (id, name, description, entity_key, keyspace_id) VALUES (11, 'RAV4', '', 't_rav4_2010', 1);
INSERT INTO entity (id, name, description, entity_key, keyspace_id) VALUES (12, 'Highlander', '', 't_highlander_2010', 1);
INSERT INTO entity (id, name, description, entity_key, keyspace_id) VALUES (13, '4Runner', '', 't_4runner_2010', 1);
INSERT INTO entity (id, name, description, entity_key, keyspace_id) VALUES (14, 'FJ Cruiser', '', 't_fjcruiser_2010', 1);


INSERT INTO entity_set (id, name) VALUES (1, "Honda");
INSERT INTO entity_set (id, name) VALUES (2, "BMW");
INSERT INTO entity_set (id, name) VALUES (3, "Toyota");
INSERT INTO entity_set (id, name) VALUES (4, "Car");
INSERT INTO entity_set (id, name) VALUES (5, "SUV");
INSERT INTO entity_set (id, name) VALUES (6, "Van");
INSERT INTO entity_set (id, name) VALUES (7, "Sport");

#Hondas
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (1, 1);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (1, 2);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (1, 3);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (1, 4);

#BMWs
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (2, 5);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (2, 6);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (2, 7);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (2, 8);

#Toyotas
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (3, 9);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (3, 10);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (3, 11);

#Cars
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (4, 1);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (4, 5);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (4, 9);

#SUVs
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (5, 2);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (5, 6);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (5, 11);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (5, 12);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (5, 13);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (5, 14);

#Vans
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (6, 4);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (6, 10);

#Sports
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (7, 3);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (7, 7);
INSERT INTO entity_set_entity (entity_set_id, entity_id) VALUES (7, 8);


