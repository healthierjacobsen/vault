
DROP TABLE IF EXISTS mdr.dma_import;

CREATE TABLE mdr.dma_import
(
    dma_code integer,
    dma_name text
);

ALTER TABLE mdr.dma_import
    OWNER TO sql_analyst;

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON mdr.dma_import TO chartio;

