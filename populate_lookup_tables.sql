
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

-- add the SAMHSA import source
	INSERT INTO imports.lookup_import_source (
		code,  -- ie SAMHSA
		description,  -- ie. SAMHSA behavioral health treatment facility listing
		tmp_table_name, -- full table name where does the data first get imported
		last_import_date, -- optional, last time this source was imported from
		source_update_date, -- optional, date source was last updated per 
		lookup_service_code_table -- should be imports.service_code_samhsa
		)
	SELECT
		'SAMHSA',
		'SAMSHA Behavioural Health Provider Listing',
		'imports.tmp_samhsa',
		null,
		null,
		'imports.lookup_service_code_samhsa'
	WHERE NOT EXISTS (SELECT 1 FROM imports.lookup_import_source WHERE code = 'SAMHSA');

DROP FUNCTION IF EXISTS imports.populate_service_codes_samhsa(text);

CREATE FUNCTION imports.populate_service_codes_samhsa(filename text) RETURNS integer AS $$
   --TRUNCATE imports.lookup_service_code_samhsa;
   --COPY imports.lookup_service_code_samhsa FROM $1;
	SELECT COUNT(*) FROM lookup_service_code_samhsa;
$$ LANGUAGE plpgsql;

execute populate_service_codes_samhsa('')	;
