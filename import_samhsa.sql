-- copies the data into tmp TABLE
-- populates import_record and import_record_service_code table with applicable service codes for record
-- another function will take the information from all of the import_record rows and import into application db
DROP FUNCTION IF EXISTS imports.populate_service_codes_samhsa(text);


CREATE FUNCTION imports.import_samhsa(filename text) RETURNS int AS $$
    TRUNCATE imports.tmp_samhsa;
	COPY imports.tmp_samhsa FROM $1;
	SELECT COUNT(*) FROM imports.tmp_samhsa;
$$ LANGUAGE plpgsql;

execute imports.import_samhsa('')	;
