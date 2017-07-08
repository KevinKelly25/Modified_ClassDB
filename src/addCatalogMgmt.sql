--addCatalogMgmt.sql - ClassDB

--Andrew Figueroa, Steven Rollo, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script should be run as either a superuser or a user with write access
-- to the PUBLIC schema

--This script should be run in every database to which ClassDB is to be added
-- it should be run after running addHelpers.sql

--This script creates two publicly accessible functions, intended for students
-- These functions provide an easy way for students to DESCRIBE a tables
-- and list all tables in a schema.  Both functions are wrappers to
-- INFORMATION_SCHEMA queries


BEGIN TRANSACTION;

--Suppress NOTICE messages for this script only, this will not apply to functions
-- defined within. This hides messages that are unimportant, but possibly confusing
SET LOCAL client_min_messages TO WARNING;


DROP FUNCTION IF EXISTS public.listTables(VARCHAR(63));
--Returns a list of tables and views in the specified schema
--Defaults to current_user, as each student (the intended users of this function)
--will primarily use a schema named <current_user>

CREATE FUNCTION public.listTables(schemaName VARCHAR(63) DEFAULT current_user)
   RETURNS TABLE
(  --Since these functions access the INFORMATION_SCHEMA, we use the standard
   --info schema types for the return table
   "Name" INFORMATION_SCHEMA.SQL_IDENTIFIER,
   "Type" INFORMATION_SCHEMA.CHARACTER_DATA
)
AS $$
   --foldedPgSchema replicates PostgreSQLs folding behvaior. This code is currently
   -- duplicated to avoid the use of foldPgID since it is in the classdb schema.
   WITH foldedPgSchema(foldedSchemaName) AS (
      SELECT CASE WHEN SUBSTRING($1 from 1 for 1) = '"' AND
                  SUBSTRING($1 from LENGTH($1) for 1) = '"'
             THEN
                  SUBSTRING($1 from 2 for LENGTH($1) - 2)
             ELSE
                  LOWER($1)
      END
   )
   SELECT table_name, table_type
   FROM INFORMATION_SCHEMA.TABLES i JOIN foldedpgSchema fs ON
      i.table_schema = fs.foldedSchemaName;
$$
LANGUAGE sql;

ALTER FUNCTION public.listTables(VARCHAR(63)) OWNER TO ClassDB;
GRANT EXECUTE ON FUNCTION public.listTables(VARCHAR(63)) TO PUBLIC;


DROP FUNCTION IF EXISTS public.describe(VARCHAR(63), VARCHAR(63));
--Returns a list of columns in the specified table or view in the specified schema
--schemaName also defaults to current_user, for the same reasons as above
CREATE FUNCTION public.describe(tableName VARCHAR(63),
   schemaName VARCHAR(63) DEFAULT current_user)
RETURNS TABLE
(
   "Table Name" INFORMATION_SCHEMA.SQL_IDENTIFIER,
   "Column Name" INFORMATION_SCHEMA.SQL_IDENTIFIER,
   "Data Type" INFORMATION_SCHEMA.CHARACTER_DATA,
   "Maximum Length" INFORMATION_SCHEMA.CARDINAL_NUMBER
)
AS $$
   --foldedPgTable and foldedPgSchema replicate PostgreSQLs folding behvaior. 
   -- This code is currently duplicated to avoid the use of foldPgID since it is
   -- in the classdb schema.
   WITH foldedPgTable(foldedTableName) AS (
      SELECT CASE WHEN SUBSTRING($1 from 1 for 1) = '"' AND
                  SUBSTRING($1 from LENGTH($1) for 1) = '"'
             THEN
                  SUBSTRING($1 from 2 for LENGTH($1) - 2)
             ELSE
                  LOWER($1)
      END
   ), foldedPgSchema(foldedSchemaName) AS (
      SELECT CASE WHEN SUBSTRING($2 from 1 for 1) = '"' AND
                  SUBSTRING($2 from LENGTH($2) for 1) = '"'
             THEN
                  SUBSTRING($2 from 2 for LENGTH($2) - 2)
             ELSE
                  LOWER($2)
      END
   )
   SELECT table_name, column_name, data_type, character_maximum_length
   FROM INFORMATION_SCHEMA.COLUMNS i JOIN foldedPgTable ft ON 
      table_name = ft.foldedTableName JOIN foldedPgSchema fs ON
      table_schema = fs.foldedSchemaName;
$$
LANGUAGE sql;

ALTER FUNCTION public.describe(VARCHAR(63), VARCHAR(63)) OWNER TO ClassDB;
GRANT EXECUTE ON FUNCTION public.describe(VARCHAR(63), VARCHAR(63)) TO PUBLIC;


COMMIT;
