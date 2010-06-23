SELECT * FROM entity e, entity_set_entity ese, entity_set es WHERE e.id=ese.entity_id AND es.id=ese.entity_set_id;
SELECT * FROM entity e, entity_set_entity ese, entity_set es WHERE e.id=ese.entity_id AND es.id=ese.entity_set_id AND es.name='BMW';
SELECT * FROM entity e, entity_set_entity ese, entity_set es WHERE e.id=ese.entity_id AND es.id=ese.entity_set_id AND es.name in ('Honda', 'Toyota');
SELECT * FROM entity e, entity_set_entity ese, entity_set es WHERE e.id=ese.entity_id AND es.id=ese.entity_set_id AND es.name='SUV';

