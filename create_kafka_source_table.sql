set schema 'sc_dev';

drop table kafka_source_test_data;


CREATE TABLE kafka_source_test_data (
    id SERIAL PRIMARY KEY,  -- Auto-incrementing ID column
    description TEXT,  -- Optional description column
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP not null  -- Timestamp column with default value
);

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_date = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON kafka_source_test_data
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();


insert into kafka_source_test_data (description) values ('test_rec1');


select *
from kafka_source_test_data;

insert into kafka_source_test_data (description) values ('test_rec2');

insert into kafka_source_test_data (description) values ('test_rec3');

insert into kafka_source_test_data (description) values ('test_rec4');

SELECT * FROM pg_replication_slots;

SELECT pg_create_logical_replication_slot('debezium_slot', 'pgoutput');

SHOW rds.logical_replication;



insert into kafka_source_test_data (description) values ('test_rec5');

insert into kafka_source_test_data (description) values ('test_rec6');


insert into kafka_source_test_data (description) values ('test_rec7');

insert into kafka_source_test_data (description) values ('test_rec8');


insert into kafka_source_test_data (description) values ('test_rec9');

insert into kafka_source_test_data (description) values ('test_rec10');

SHOW TIMEZONE;

commit;


