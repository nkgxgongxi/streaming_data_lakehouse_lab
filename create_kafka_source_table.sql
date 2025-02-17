set schema 'sc_dev';

drop table kafka_source_test_data;


CREATE TABLE kafka_source_test_data (
    id SERIAL PRIMARY KEY,  -- Auto-incrementing ID column
    description TEXT,  -- Optional description column
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Timestamp column with default value
);