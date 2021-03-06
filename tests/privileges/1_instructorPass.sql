--1_instructorPass.sql - ClassDB

--Andrew Figueroa, Steven Rollo, Sean Murthy
--Data Science & Systems Lab (DASSL)
--https://dassl.github.io/

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

START TRANSACTION;


--Execute appropriate ClassDB functions (these tests do not verify correctness
-- of each function)
SELECT ClassDB.listUserConnections('teststu_pt');
SELECT ClassDB.killUserConnections('teststu_pt');


SELECT ClassDB.importConnectionLog();


--CRUD on tables created by the instructor. This table should be placed in their
-- own schema and be accessed without needing to be fully schema qualified
--Create without schema qualification
CREATE TABLE Test
(
   Col1 VARCHAR(10)
);

--Insert with schema qualification - ensures test table was created in the
-- ptins0 schema
INSERT INTO ptins0.Test VALUES ('hello');

--Select
SELECT * FROM Test;

--Update
UPDATE Test
SET Col1 = 'goodbye';

--Delete
DELETE FROM Test;
DROP TABLE Test;


--CRUD on public schema
CREATE TABLE public.PublicTest
(
   Col1 VARCHAR(10)
);

INSERT INTO public.PublicTest VALUES ('hello');

SELECT * FROM public.PublicTest;

UPDATE public.PublicTest
SET Col1 = 'goodbye';

DELETE FROM public.PublicTest;
DROP TABLE public.PublicTest;

--Create and drop schema
CREATE SCHEMA ptins0schema;
DROP SCHEMA ptins0schema;


--Read from columns in RoleBase table
SELECT * FROM ClassDB.RoleBase;


--Read from columns in User, Student, Instructor, and DBManager views
SELECT * FROM ClassDB.User;
SELECT * FROM ClassDB.DBManager;
SELECT * FROM ClassDB.Student;
SELECT * FROM ClassDB.Instructor;

--Read from team views
SELECT * FROM ClassDB.TeamMember;
SELECT * FROM ClassDB.Team;

--Read from frequent views
SELECT * FROM ClassDB.StudentTable;
SELECT * FROM ClassDB.StudentTableCount;
SELECT * FROM ClassDB.StudentActivitySummary;
SELECT * FROM ClassDB.StudentActivitySummaryAnon;
SELECT * FROM ClassDB.StudentActivity;
SELECT * FROM ClassDB.StudentActivityAnon;

--Read from public frequent views
SELECT * FROM public.myActivitySummary;
SELECT * FROM public.MyDDLActivity;
SELECT * FROM public.MyConnectionActivity;
SELECT * FROM public.myActivity;


--Create table in public schema to test read privileges for all users
CREATE TABLE public.TestInsPublic
(
   Col1 VARCHAR(20)
);

INSERT INTO public.testInsPublic VALUES ('Read by: anyone');

--Create table in $user schema to test non-access for other roles
CREATE TABLE TestInsUsr
(
   col1 VARCHAR(20)
);

INSERT INTO testInsUsr VALUES('Read by: ptins0');


COMMIT;
