-- Schema: imports

-- DROP SCHEMA imports;

CREATE SCHEMA IF NOT EXISTS imports
  AUTHORIZATION postgres;

GRANT ALL ON SCHEMA imports TO postgres;
GRANT ALL ON SCHEMA imports TO public;
COMMENT ON SCHEMA imports
  IS 'schema for import logic';



CREATE TABLE IF NOT EXISTS imports.import_record (
	id INT PRIMARY KEY,
	--other columns
	name1 VARCHAR(255),
	name2 VARCHAR(255),
	street1 VARCHAR(255), street2 VARCHAR(255), city VARCHAR(100),
	state CHAR(2), zip CHAR(5), zip4 CHAR(4), county VARCHAR(100),
	phone VARCHAR(25), intake_prompt  VARCHAR(100),intake1 VARCHAR(100),intake2 VARCHAR(100),
	hotline_prompt VARCHAR(100), hotline1 VARCHAR(100), hotline2 VARCHAR(100), website  VARCHAR(255),
	dir_prefix  VARCHAR(10), dir_first  VARCHAR(100), dir_mi CHAR(1), dir_last VARCHAR(100),dir_suffix  VARCHAR(10),
	dir_title VARCHAR(100), dir_phone VARCHAR(25), dir_fax VARCHAR(25), dir_email VARCHAR(255),
	mail_street1 VARCHAR(255), mail_street2 VARCHAR(255), mail_city  VARCHAR(100),
	mail_state CHAR(2), mail_zip CHAR(5), mail_zip4 CHAR(4),
    latitude  VARCHAR(25), longitude  VARCHAR(25), -- need to get this from address somehow??
	type_facility VARCHAR(10),  --MH or SA in the case of SAMHSA
	-- anything else?
	last_update  VARCHAR(100),	
	date_created timestamp, -- record created in this table
	date_loaded timestamp -- loaded into app database
);

CREATE SEQUENCE  imports.import_record_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE imports.import_record_id_seq OWNED BY imports.import_record.id;

-- imports.import_record_service_codes
-- a link table to contain links between import_record and service codes
-- the table the service codes are found in can be determined from lookup_import_source.lookup_service_table
-- mapping to fields in app data will occur based on lookup_service_code_mapping
-- this may or may not be applicable to all import sources
CREATE TABLE IF NOT EXISTS imports.import_record_service_codes  (
		import_record_id INT,  -- import_record.id
		service_code VARCHAR(10), -- lookup_service_code_*.service_code (table determined by lookup_import_source.lookup_service_code_table)
		-- may make sense to store display text and import_source_code here too
		display_text VARCHAR(255) -- the text that is to be added to application database
);

-- LOOKUP TABLES

-- imports.lookup_import_source
-- a list of all import sources and related tables that are used, anything else needed for documentation
CREATE TABLE IF NOT EXISTS imports.lookup_import_source (
	code VARCHAR(10),  -- ie SAMHSA
	description VARCHAR(255),  -- ie. SAMHSA behavioral health treatment facility listing
	tmp_table_name VARCHAR(255), -- where does the data first get imported
	last_import_date timestamp, -- optional, last time this source was imported from
	source_update_date timestamp, -- optional, date source was last updated per 
	lookup_service_code_table VARCHAR(255), -- should be service_code_samhsa
	url VARCHAR(500)  -- optional, url where data is downloaded from for documentation purposes
);

----------------------------------------------------------------------------------------------------
-- imports.lookup_service_code_mapping
--indicates where a given service code for a given import source will be 
--mapped to the fields in locations or services tables
-- this information still needs to be determined
CREATE TABLE IF NOT EXISTS imports.lookup_service_code_mapping (
	import_source_code VARCHAR(10),
	service_code VARCHAR(10),
	dest_table VARCHAR(255),  -- what table in application database
	dest_column VARCHAR(255)  -- what column in application database
-- possible values for services table - audience, name, short_desc, description, eligibility, fees, funding_sources, service_areas, how_to_apply	
);

--SAMHSA Format specific
--
CREATE TABLE IF NOT EXISTS imports.tmp_samhsa (
--
	name1 VARCHAR(255),
	name2 VARCHAR(255),
	street1 VARCHAR(255), street2 VARCHAR(255), city VARCHAR(100),
	state CHAR(2), zip CHAR(5), zip4 CHAR(4), county VARCHAR(100),
	phone VARCHAR(25), intake_prompt  VARCHAR(100),intake1 VARCHAR(100),intake2 VARCHAR(100),
	hotline_prompt VARCHAR(100), hotline1 VARCHAR(100), hotline2 VARCHAR(100), website  VARCHAR(255),
	dir_prefix  VARCHAR(10), dir_first  VARCHAR(100), dir_mi CHAR(1), dir_last VARCHAR(100),dir_suffix  VARCHAR(10),
	dir_title VARCHAR(100), dir_phone VARCHAR(25), dir_fax VARCHAR(25), dir_email VARCHAR(255),
	mail_street1 VARCHAR(255), mail_street2 VARCHAR(255), mail_city  VARCHAR(100),
	mail_state CHAR(2), mail_zip CHAR(5), mail_zip4 CHAR(4),
    latitude  VARCHAR(25), longitude  VARCHAR(25),
	type_facility VARCHAR(10),
	last_update  VARCHAR(100),
	--POPULATION
	adlt CHAR(1), chld CHAR(1), yad CHAR(1), cit CHAR(1), wi CHAR(1),
	bmo CHAR(1), du CHAR(1), mo CHAR(1), pub CHAR(1), pvt CHAR(1),
	vamc CHAR(1), atr CHAR(1), ihs CHAR(1), mc CHAR(1), md CHAR(1),
	mi CHAR(1), np CHAR(1), pi CHAR(1), sf CHAR(1), si CHAR(1),
	pa CHAR(1), ss CHAR(1), ct CHAR(1), hi CHAR(1), hid CHAR(1),
	hit CHAR(1), msnh CHAR(1), od CHAR(1), odt CHAR(1), oit CHAR(1),
	omb CHAR(1), op CHAR(1), ores CHAR(1), ort CHAR(1), ph CHAR(1),
	rd CHAR(1), res CHAR(1), rl CHAR(1), rs CHAR(1), rtca CHAR(1),
	rtcc CHAR(1), tele CHAR(1), ad CHAR(1), adm CHAR(1), alz CHAR(1),
	bc CHAR(1), cj CHAR(1), co CHAR(1), dv CHAR(1), gl CHAR(1),
	hv CHAR(1), mf CHAR(1), mn CHAR(1), peer CHAR(1), ptsd CHAR(1),
	pw CHAR(1), se CHAR(1), sed CHAR(1), smi CHAR(1), tbi CHAR(1),
	trma CHAR(1), vet CHAR(1), wn CHAR(1), xa CHAR(1), ah CHAR(1),
	fx CHAR(1), nx CHAR(1), sp CHAR(1), bu CHAR(1), dm CHAR(1),
	dt CHAR(1), hh CHAR(1), mh CHAR(1), mm CHAR(1), nxn CHAR(1),
	otpa CHAR(1), sa CHAR(1), vtrl CHAR(1)
);	

-- this is the key for all of the bit fields
-- A link table import_record_service_codes will hold a record for each of these codes which is active for a given import record
--  It will be populated with data from here (service_name?)
-- Table lookup_service_code_mapping will determine which fields in the application database, the service_name should map to
CREATE TABLE IF NOT EXISTS imports.lookup_service_code_samhsa (
	service_code VARCHAR(10),
	service_name VARCHAR(50),	
	service_description	VARCHAR(255),
	service_category VARCHAR(10),	
	sa_code	CHAR(1),
	mh_code	CHAR(1),
	use_for_selection CHAR(1),
	both_code CHAR(1),	
	category_code VARCHAR(10),	-- These are categories for what this code pertains to - EMS, SET, PAY, ETC
	category_name VARCHAR(255),  -- special groups, language services, payment types, etc
	sa_category	CHAR(1),
	mh_category	CHAR(1),
	both_category CHAR(1)
);
