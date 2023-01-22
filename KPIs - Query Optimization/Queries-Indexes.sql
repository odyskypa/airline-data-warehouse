--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- ENABLING star-join transformation on ORACLE DB FOR THIS SESSION.

-- ALTER SESSION SET star_transformation_enabled = false; -- NOT REDUCING THE COST, DISABLING AGAIN

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- TRYING DIFFERENT INDEXES APPROACHES

-- CREATING BITMAPS ON FOREIGN KEYS OF THE FACT TABLES (BEST SOLUTION WITH AVAILABLE SPACE)
CREATE BITMAP INDEX index_au_a_ID
ON AircraftUtilization(AIRCRAFTID) PCTFREE 0;

CREATE BITMAP INDEX index_l_a_ID
ON LogBookReporting(AIRCRAFTID) PCTFREE 0;

CREATE BITMAP INDEX index_l_p_ID
ON LogBookReporting(PERSONID) PCTFREE 0;

-- ALTER TABLE AircraftUtilization ADD PRIMARY KEY (aircraftID, timeID) USING INDEX PCTFREE 33;

-- CREATING B+ TREES ON FOREIGN KEYS OF THE FACT TABLES (TAKING TOO MUCH SPACE, 
-- COST REDUCES MORE THAN BITMAPS)

-- CREATE INDEX b_tree_l_a_ID 
-- ON LogBookReporting (AIRCRAFTID) PCTFREE 33;

-- CREATE INDEX b_tree_au_a_ID 
-- ON AircraftUtilization (AIRCRAFTID) PCTFREE 33;

-- CREATING CLUSTERED INDEXES ON FOREIGN KEYS OF THE FACT TABLES --(DID NOT TRY, WILL TAKE
-- EVEN MORE SPACE THAN B-TREES)

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- KPI QUERIES:

-- 1. (30%) Give me FH and FC per month, filtered by the aircraft model (e.g., "777").

-- Initial Cost 526
-- Bitmap on au.AIRCRAFTID: 388

SELECT t.MONTHID, SUM(au.FLIGHTHOURS) AS FH, SUM(au.FLIGHTCYCLES) AS FC
FROM AircraftUtilization au, TemporalDimension t, AircraftDimension a
WHERE au.AIRCRAFTID = a.ID AND au.TIMEID = t.ID AND a.MODEL = '777'
GROUP BY t.MONTHID
ORDER BY t.MONTHID;

-- 2. (30%) Give me ADOSS, ADOSU per year, filtered by the aircraft from the fleet (e.g., "XY-WTR").

-- Initial Cost 528
-- Bitmap on au.AIRCRAFTID: 143

SELECT m.Y, SUM(SCHEDULEDOUTOFSERVICE) AS ADOSS, SUM(UNSCHEDULEDOUTOFSERVICE) AS ADOSU
FROM AircraftUtilization au, Months m, TemporalDimension t, AircraftDimension a 
WHERE au.AIRCRAFTID = a.ID AND au.TIMEID = t.ID AND t.MONTHID  = m.ID AND au.AIRCRAFTID = 'XY-WTR'
GROUP BY m.Y
ORDER BY m.Y;


-- 3. (20%) Give me the RRh, RRc, PRRh, PRRc, MRRh and MRRc per month, filtered by the aircraft model (e.g., "777").

-- Initial Cost 1764
-- Bitmap on au.AIRCRAFTID & l.AIRCRAFTID & l.pPERSONID: 1284

SELECT fhc.MONTHID, 1000*(PIREP + MAREP)/(FH) AS RRh, 100*(PIREP + MAREP)/FC AS RRc,
		1000*PIREP/FH AS PRRh,
       	100*PIREP/FC AS PRRc,
       	1000*MAREP/FH AS MRRh,
       	100*MAREP/FC AS MRRc
FROM 
	(SELECT t.MONTHID, SUM(au.FLIGHTHOURS) AS FH, SUM(au.FLIGHTCYCLES) AS FC
	FROM AircraftUtilization au, TemporalDimension t, AircraftDimension a
	WHERE au.AIRCRAFTID = a.ID AND au.TIMEID = t.ID AND a.MODEL = '777'
	GROUP BY t.MONTHID) fhc,
	(SELECT l.MONTHID,
		SUM(CASE WHEN p.ROLE ='P' THEN l.COUNTER ELSE 0 END) AS PIREP,
		SUM(CASE WHEN p.ROLE ='M' THEN l.COUNTER ELSE 0 END) AS MAREP
   	FROM LogBookReporting l, AircraftDimension a, PeopleDimension p 
   	WHERE l.AIRCRAFTID = a.ID AND p.ID = l.PERSONID AND a.MODEL = '777'
   	GROUP BY l.MONTHID) r
WHERE fhc.MONTHID = r.MONTHID
ORDER BY fhc.MONTHID;

-- 4. (20%) Give me the MRRh and MRRc per aircraft model, filtered by the airport of the reporting person (e.g., "KRS").


-- Initial Cost 1750
-- Bitmap on au.AIRCRAFTID & l.AIRCRAFTID & l.pPERSONID: 761

SELECT fhc.MODEL, 1000*MAREP/FH AS MRRh, 100*MAREP/FC AS MRRc
FROM 
	(SELECT a.MODEL,SUM(au.FLIGHTHOURS) AS FH, SUM(au.FLIGHTCYCLES) AS FC
	FROM AircraftUtilization au, AircraftDimension a
	WHERE au.AIRCRAFTID = a.ID
	GROUP BY a.MODEL) fhc,
	(SELECT a.MODEL,
		SUM(CASE WHEN p.ROLE ='P' THEN l.COUNTER ELSE 0 END) AS PIREP,
		SUM(CASE WHEN p.ROLE ='M' THEN l.COUNTER ELSE 0 END) AS MAREP
	FROM  LogBookReporting l, AircraftDimension a, PeopleDimension p
	WHERE l.AIRCRAFTID = a.ID AND p.AIRPORT = 'KRS' AND p.ID = l.PERSONID
	GROUP BY a.MODEL) r
WHERE fhc.MODEL = r.MODEL
ORDER BY fhc.MODEL;

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- SHRINKING TABLES, UPLOADING STATISTICS, REMOVING INDEXES AND CHECKING DISK BLOCKS OCCUPIED

ALTER TABLE AIRCRAFTDIMENSION SHRINK SPACE;
ALTER TABLE PEOPLEDIMENSION SHRINK SPACE;
ALTER TABLE TEMPORALDIMENSION SHRINK SPACE;
ALTER TABLE MONTHS SHRINK SPACE;
ALTER TABLE AIRCRAFTUTILIZATION SHRINK SPACE;
ALTER TABLE LOGBOOKREPORTING SHRINK SPACE;


-- Update Statistics

DECLARE
esquema VARCHAR2(100);
CURSOR c IS SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME NOT LIKE 'SHADOW_%';
BEGIN
SELECT '"'||sys_context('USERENV', 'CURRENT_SCHEMA')||'"' INTO esquema FROM dual;
FOR taula IN c LOOP
  DBMS_STATS.GATHER_TABLE_STATS( 
    ownname => esquema, 
    tabname => taula.table_name, 
    estimate_percent => NULL,
    method_opt =>'FOR ALL COLUMNS SIZE REPEAT',
    granularity => 'GLOBAL',
    cascade => TRUE
    );
  END LOOP;
END;


-- Drop Indexes
Begin
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
End;

-- Check Occupied Space
SELECT SUM(blocks) FROM USER_TS_QUOTAS;