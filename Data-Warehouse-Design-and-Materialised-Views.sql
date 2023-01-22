CREATE TABLE time_day(
    day CHAR(10), -- abbreviation_of_day-abbreviation_of_month-year -> 3+3+4 
    month CHAR(7) NOT NULL, -- abbreviation_of_month-year -> 3+4
    year CHAR(4) NOT NULL,
    PRIMARY KEY (day)
);

CREATE TABLE time_month(
    month CHAR(7), -- abbreviation_of_month-year -> 3+4
    year CHAR(4) NOT NULL,
    PRIMARY KEY (month)
);

CREATE TABLE personnel(
    reporterId SMALLINT,
    airport CHAR(3) NOT NULL,
    PRIMARY KEY (reporterId)
);

CREATE TABLE aircraft(
    aircraft_reg_code CHAR(6),
    aircraft_model CHAR(20) NOT NULL,
    aircraft_manufacturer CHAR(20) NOT NULL,
    PRIMARY KEY (aircraft_reg_code)
);

CREATE TABLE flights(
    aircraft_reg_code CHAR(6),
    day CHAR(10),
    FH FLOAT NOT NULL, -- FH stands for Flight Hours
    FC INT NOT NULL, -- Using FC (flight cycles) instead of TO because TO is a reserved work for ORACLE DB
    PRIMARY KEY (aircraft_reg_code, day),
    FOREIGN KEY (aircraft_reg_code) REFERENCES aircraft(aircraft_reg_code),
    FOREIGN KEY (day) REFERENCES time_day(day)
);

CREATE TABLE flight_service(
    aircraft_reg_code CHAR(6),
    month CHAR(7),
    ADIS FLOAT NOT NULL,
    ADOS FLOAT NOT NULL,
    ADOSS FLOAT NOT NULL,
    ADOSU FLOAT NOT NULL,
    DYR FLOAT NOT NULL,
    CNR FLOAT NOT NULL,
    TDR FLOAT NOT NULL,
    ADeD FLOAT NOT NULL, -- Using ADeD (Average Delay Duration) instead of ADD because ADD is a reserved work for ORACLE DB
    RRh FLOAT NOT NULL,
    RRc FLOAT NOT NULL,
    PRRh FLOAT NOT NULL,
    PRRc FLOAT NOT NULL,
    MRRh FLOAT NOT NULL,
    MRRc FLOAT NOT NULL,
    PRIMARY KEY (aircraft_reg_code, month),
    FOREIGN KEY (aircraft_reg_code) REFERENCES aircraft(aircraft_reg_code),
    FOREIGN KEY (month) REFERENCES time_month(month)
);

CREATE TABLE maintainance_report_rates(
    aircraft_reg_code CHAR(6),
    reporterId SMALLINT,
    MRRh FLOAT NOT NULL,
    MRRc FLOAT NOT NULL,
    PRIMARY KEY (aircraft_reg_code, reporterId),
    FOREIGN KEY (aircraft_reg_code) REFERENCES aircraft(aircraft_reg_code),
    FOREIGN KEY (reporterId) REFERENCES personnel(reporterId)
);



-- Queries

-- a)

-- FH and TO per aircraft per day
SELECT t.day, a.aircraft_reg_code, SUM(f.FH) AS "Flight Hours", SUM(f.FC) AS "Flight Cycles"
FROM flights f , time_day t, aircraft a
WHERE t.day = f.day AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.day, a.aircraft_reg_code
ORDER BY t.day, a.aircraft_reg_code

-- FH and TO per aircraft per month
SELECT t.month, a.aircraft_reg_code, SUM(f.FH) AS "Flight Hours", SUM(f.FC) AS "Flight Cycles"
FROM flights f , time_day t, aircraft a
WHERE t.day = f.day AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.month, a.aircraft_reg_code
ORDER BY t.month, a.aircraft_reg_code

-- FH and TO per aircraft per year
SELECT t.year, a.aircraft_reg_code, SUM(f.FH) AS "Flight Hours", SUM(f.FC) AS "Flight Cycles"
FROM flights f , time_day t, aircraft a
WHERE t.day = f.day AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.year, a.aircraft_reg_code
ORDER BY t.year, a.aircraft_reg_code

-- FH and TO per model per day
SELECT t.day, a.aircraft_model, SUM(f.FH) AS "Flight Hours", SUM(f.FC) AS "Flight Cycles"
FROM flights f , time_day t, aircraft a
WHERE t.day = f.day AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.day, a.aircraft_model
ORDER BY t.day, a.aircraft_model

-- FH and TO per model per month
SELECT t.month, a.aircraft_model, SUM(f.FH) AS "Flight Hours", SUM(f.FC) AS "Flight Cycles"
FROM flights f , time_day t, aircraft a
WHERE t.day = f.day AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.month, a.aircraft_model
ORDER BY t.month, a.aircraft_model

-- FH and TO per model per year
SELECT t.year, a.aircraft_model, SUM(f.FH) AS "Flight Hours", SUM(f.FC) AS "Flight Cycles"
FROM flights f , time_day t, aircraft a
WHERE t.day = f.day AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.year, a.aircraft_model
ORDER BY t.year, a.aircraft_model

-- b)

-- ADIS, ADOS, ADOSS, ADOSU, DYR, CNR, TDR, ADD per aircraft per month
SELECT t.month, a.aircraft_reg_code, SUM(f.ADIS) AS "Aircraft Days in Service", SUM(f.ADOS) AS "Aircraft Days Out of Service", SUM(f.ADOSS) "Days OFF Service Scheduled", SUM(f.ADOSU) AS "Days OFF Service Unscheduled", SUM(f.DYR) AS "Delay Rate", SUM(f.CNR) AS "Cancellation Rate", SUM(f.TDR) "Technical Dispatch Reliability", SUM(f.ADeD) AS "Average Delay Duration"
FROM flight_service f, time_month t, aircraft a
WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.month, a.aircraft_reg_code
ORDER BY t.month, a.aircraft_reg_code

-- ADIS, ADOS, ADOSS, ADOSU, DYR, CNR, TDR, ADD per aircraft per year
SELECT t.year, a.aircraft_reg_code, SUM(f.ADIS) AS "Aircraft Days in Service", SUM(f.ADOS) AS "Aircraft Days Out of Service", SUM(f.ADOSS) "Days OFF Service Scheduled", SUM(f.ADOSU) AS "Days OFF Service Unscheduled", SUM(f.DYR) AS "Delay Rate", SUM(f.CNR) AS "Cancellation Rate", SUM(f.TDR) "Technical Dispatch Reliability", SUM(f.ADeD) AS "Average Delay Duration"
FROM flight_service f, time_month t, aircraft a
WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.year, a.aircraft_reg_code
ORDER BY t.year, a.aircraft_reg_code

-- ADIS, ADOS, ADOSS, ADOSU, DYR, CNR, TDR, ADD per model per month
SELECT t.month, a.aircraft_model, SUM(f.ADIS) AS "Aircraft Days in Service", SUM(f.ADOS) AS "Aircraft Days Out of Service", SUM(f.ADOSS) "Days OFF Service Scheduled", SUM(f.ADOSU) AS "Days OFF Service Unscheduled", SUM(f.DYR) AS "Delay Rate", SUM(f.CNR) AS "Cancellation Rate", SUM(f.TDR) "Technical Dispatch Reliability", SUM(f.ADeD) AS "Average Delay Duration"
FROM flight_service f, time_month t, aircraft a
WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.month, a.aircraft_model
ORDER BY t.month, a.aircraft_model

-- ADIS, ADOS, ADOSS, ADOSU, DYR, CNR, TDR, ADD per model per year
SELECT t.year, a.aircraft_model, SUM(f.ADIS) AS "Aircraft Days in Service", SUM(f.ADOS) AS "Aircraft Days Out of Service", SUM(f.ADOSS) "Days OFF Service Scheduled", SUM(f.ADOSU) AS "Days OFF Service Unscheduled", SUM(f.DYR) AS "Delay Rate", SUM(f.CNR) AS "Cancellation Rate", SUM(f.TDR) "Technical Dispatch Reliability", SUM(f.ADeD) AS "Average Delay Duration"
FROM flight_service f, time_month t, aircraft a
WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.year, a.aircraft_model
ORDER BY t.year, a.aircraft_model

-- c)

-- RRh, RRc, PRRh, PRRc, MRRh and MRRc per aircraft per month
SELECT t.month, a.aircraft_reg_code, SUM(f.RRh) AS "Report Rate per hour", SUM(f.RRc) AS "Report Rate per cycle", SUM(f.PRRh) AS "Pilot Report Rate per hour", SUM(f.PRRc) AS "Pilot Report Rate per cycle", SUM(f.MRRh) AS "Hourly Maintenance Report Rate", SUM(f.MRRc) AS "Cycle Maintenance Report Rate"
FROM flight_service f, time_month t, aircraft a
WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.month, a.aircraft_reg_code
ORDER BY t.month, a.aircraft_reg_code

-- RRh, RRc, PRRh, PRRc, MRRh and MRRc per aircraft per year
SELECT t.year, a.aircraft_reg_code, SUM(f.RRh) AS "Report Rate per hour", SUM(f.RRc) AS "Report Rate per cycle", SUM(f.PRRh) AS "Pilot Report Rate per hour", SUM(f.PRRc) AS "Pilot Report Rate per cycle", SUM(f.MRRh) AS "Hourly Maintenance Report Rate", SUM(f.MRRc) AS "Cycle Maintenance Report Rate"
FROM flight_service f, time_month t, aircraft a
WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.year, a.aircraft_reg_code
ORDER BY t.year, a.aircraft_reg_code

-- RRh, RRc, PRRh, PRRc, MRRh and MRRc per model per month
SELECT t.month, a.aircraft_model, SUM(f.RRh) AS "Report Rate per hour", SUM(f.RRc) AS "Report Rate per cycle", SUM(f.PRRh) AS "Pilot Report Rate per hour", SUM(f.PRRc) AS "Pilot Report Rate per cycle", SUM(f.MRRh) AS "Hourly Maintenance Report Rate", SUM(f.MRRc) AS "Cycle Maintenance Report Rate"
FROM flight_service f, time_month t, aircraft a
WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.month, a.aircraft_model
ORDER BY t.month, a.aircraft_model

-- RRh, RRc, PRRh, PRRc, MRRh and MRRc per model per year
SELECT t.year, a.aircraft_model, SUM(f.RRh) AS "Report Rate per hour", SUM(f.RRc) AS "Report Rate per cycle", SUM(f.PRRh) AS "Pilot Report Rate per hour", SUM(f.PRRc) AS "Pilot Report Rate per cycle", SUM(f.MRRh) AS "Hourly Maintenance Report Rate", SUM(f.MRRc) AS "Cycle Maintenance Report Rate"
FROM flight_service f, time_month t, aircraft a
WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.year, a.aircraft_model
ORDER BY t.year, a.aircraft_model

-- RRh, RRc, PRRh, PRRc, MRRh and MRRc per manufacturer per month
SELECT t.month, a.aircraft_manufacturer, SUM(f.RRh) AS "Report Rate per hour", SUM(f.RRc) AS "Report Rate per cycle", SUM(f.PRRh) AS "Pilot Report Rate per hour", SUM(f.PRRc) AS "Pilot Report Rate per cycle", SUM(f.MRRh) AS "Hourly Maintenance Report Rate", SUM(f.MRRc) AS "Cycle Maintenance Report Rate"
FROM flight_service f, time_month t, aircraft a
WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.month, a.aircraft_manufacturer
ORDER BY t.month, a.aircraft_manufacturer

-- RRh, RRc, PRRh, PRRc, MRRh and MRRc per manufacturer per year
SELECT t.year, a.aircraft_manufacturer, SUM(f.RRh) AS "Report Rate per hour", SUM(f.RRc) AS "Report Rate per cycle", SUM(f.PRRh) AS "Pilot Report Rate per hour", SUM(f.PRRc) AS "Pilot Report Rate per cycle", SUM(f.MRRh) AS "Hourly Maintenance Report Rate", SUM(f.MRRc) AS "Cycle Maintenance Report Rate"
FROM flight_service f, time_month t, aircraft a
WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
GROUP BY t.year, a.aircraft_manufacturer
ORDER BY t.year, a.aircraft_manufacturer

-- d)

-- MRRh and MRRc per airport per aircraft
SELECT p.airport, a.aircraft_reg_code, SUM(m.MRRh) AS "Hourly Maintenance Report Rate", SUM(m.MRRc) AS "Cycle Maintenance Report Rate"
FROM maintainance_report_rates m, personnel p, aircraft a
WHERE p.reporterId = m.reporterId AND a.aircraft_reg_code = m.aircraft_reg_code
GROUP BY p.airport, a.aircraft_reg_code
ORDER BY p.airport, a.aircraft_reg_code

-- MRRh and MRRc per airport per model
SELECT p.airport, a.aircraft_model, SUM(m.MRRh) AS "Hourly Maintenance Report Rate", SUM(m.MRRc) AS "Cycle Maintenance Report Rate"
FROM maintainance_report_rates m, personnel p, aircraft a
WHERE p.reporterId = m.reporterId AND a.aircraft_reg_code = m.aircraft_reg_code
GROUP BY p.airport, a.aircraft_model
ORDER BY p.airport, a.aircraft_model


CREATE MATERIALIZED VIEW aircraft_flights_per_month
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ENABLE QUERY REWRITE
    AS SELECT t.month, a.aircraft_reg_code, SUM(f.FH) AS "Flight Hours", SUM(f.FC) AS "Flight Cycles"
        FROM flights f , time_day t, aircraft a
        WHERE t.day = f.day AND a.aircraft_reg_code = f.aircraft_reg_code
        GROUP BY t.month, a.aircraft_reg_code
        ORDER BY t.month, a.aircraft_reg_code
;

CREATE MATERIALIZED VIEW aircraft_flights_per_year
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ENABLE QUERY REWRITE
    AS SELECT t.year, a.aircraft_reg_code, SUM(f.FH) AS "Flight Hours", SUM(f.FC) AS "Flight Cycles"
        FROM flights f , time_day t, aircraft a
        WHERE t.day = f.day AND a.aircraft_reg_code = f.aircraft_reg_code
        GROUP BY t.year, a.aircraft_reg_code
        ORDER BY t.year, a.aircraft_reg_code
;

CREATE MATERIALIZED VIEW model_flights_per_month
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ENABLE QUERY REWRITE
    AS SELECT t.month, a.aircraft_model, SUM(f.FH) AS "Flight Hours", SUM(f.FC) AS "Flight Cycles"
        FROM flights f , time_day t, aircraft a
        WHERE t.day = f.day AND a.aircraft_reg_code = f.aircraft_reg_code
        GROUP BY t.month, a.aircraft_model
        ORDER BY t.month, a.aircraft_model

;

CREATE MATERIALIZED VIEW model_flights_per_year
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ENABLE QUERY REWRITE
    AS SELECT t.year, a.aircraft_model, SUM(f.FH) AS "Flight Hours", SUM(f.FC) AS "Flight Cycles"
        FROM flights f , time_day t, aircraft a
        WHERE t.day = f.day AND a.aircraft_reg_code = f.aircraft_reg_code
        GROUP BY t.year, a.aircraft_model
        ORDER BY t.year, a.aircraft_model
;

CREATE MATERIALIZED VIEW aircraft_service_per_month
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ENABLE QUERY REWRITE
    AS SELECT t.month, a.aircraft_reg_code, SUM(f.ADIS) AS "Aircraft Days in Service", SUM(f.ADOS) AS "Aircraft Days Out of Service", SUM(f.ADOSS) "Days OFF Service Scheduled", SUM(f.ADOSU) AS "Days OFF Service Unscheduled", SUM(f.DYR) AS "Delay Rate", SUM(f.CNR) AS "Cancellation Rate", SUM(f.TDR) "Technical Dispatch Reliability", SUM(f.ADeD) AS "Average Delay Duration"
        FROM flight_service f, time_month t, aircraft a
        WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
        GROUP BY t.month, a.aircraft_reg_code
        ORDER BY t.month, a.aircraft_reg_code

;

CREATE MATERIALIZED VIEW aircraft_service_per_year
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ENABLE QUERY REWRITE
    AS SELECT t.year, a.aircraft_reg_code, SUM(f.ADIS) AS "Aircraft Days in Service", SUM(f.ADOS) AS "Aircraft Days Out of Service", SUM(f.ADOSS) "Days OFF Service Scheduled", SUM(f.ADOSU) AS "Days OFF Service Unscheduled", SUM(f.DYR) AS "Delay Rate", SUM(f.CNR) AS "Cancellation Rate", SUM(f.TDR) "Technical Dispatch Reliability", SUM(f.ADeD) AS "Average Delay Duration"
        FROM flight_service f, time_month t, aircraft a
        WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
        GROUP BY t.year, a.aircraft_reg_code
        ORDER BY t.year, a.aircraft_reg_code
;

CREATE MATERIALIZED VIEW model_service_per_month
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ENABLE QUERY REWRITE
    AS SELECT t.month, a.aircraft_model, SUM(f.ADIS) AS "Aircraft Days in Service", SUM(f.ADOS) AS "Aircraft Days Out of Service", SUM(f.ADOSS) "Days OFF Service Scheduled", SUM(f.ADOSU) AS "Days OFF Service Unscheduled", SUM(f.DYR) AS "Delay Rate", SUM(f.CNR) AS "Cancellation Rate", SUM(f.TDR) "Technical Dispatch Reliability", SUM(f.ADeD) AS "Average Delay Duration"
        FROM flight_service f, time_month t, aircraft a
        WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
        GROUP BY t.month, a.aircraft_model
        ORDER BY t.month, a.aircraft_model

;

CREATE MATERIALIZED VIEW model_service_per_year
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ENABLE QUERY REWRITE
    AS SELECT t.year, a.aircraft_model, SUM(f.ADIS) AS "Aircraft Days in Service", SUM(f.ADOS) AS "Aircraft Days Out of Service", SUM(f.ADOSS) "Days OFF Service Scheduled", SUM(f.ADOSU) AS "Days OFF Service Unscheduled", SUM(f.DYR) AS "Delay Rate", SUM(f.CNR) AS "Cancellation Rate", SUM(f.TDR) "Technical Dispatch Reliability", SUM(f.ADeD) AS "Average Delay Duration"
        FROM flight_service f, time_month t, aircraft a
        WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
        GROUP BY t.year, a.aircraft_model
        ORDER BY t.year, a.aircraft_model
;

CREATE MATERIALIZED VIEW aircraft_report_rate_per_month
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ENABLE QUERY REWRITE
    AS SELECT t.month, a.aircraft_reg_code, SUM(f.RRh) AS "Report Rate per hour", SUM(f.RRc) AS "Report Rate per cycle", SUM(f.PRRh) AS "Pilot Report Rate per hour", SUM(f.PRRc) AS "Pilot Report Rate per cycle", SUM(f.MRRh) AS "Hourly Maintenance Report Rate", SUM(f.MRRc) AS "Cycle Maintenance Report Rate"
        FROM flight_service f, time_month t, aircraft a
        WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
        GROUP BY t.month, a.aircraft_reg_code
        ORDER BY t.month, a.aircraft_reg_code
;

CREATE MATERIALIZED VIEW aircraft_report_rate_per_year
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ENABLE QUERY REWRITE
    AS SELECT t.year, a.aircraft_reg_code, SUM(f.RRh) AS "Report Rate per hour", SUM(f.RRc) AS "Report Rate per cycle", SUM(f.PRRh) AS "Pilot Report Rate per hour", SUM(f.PRRc) AS "Pilot Report Rate per cycle", SUM(f.MRRh) AS "Hourly Maintenance Report Rate", SUM(f.MRRc) AS "Cycle Maintenance Report Rate"
        FROM flight_service f, time_month t, aircraft a
        WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
        GROUP BY t.year, a.aircraft_reg_code
        ORDER BY t.year, a.aircraft_reg_code
;

CREATE MATERIALIZED VIEW model_report_rate_per_month
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ENABLE QUERY REWRITE
    AS SELECT t.month, a.aircraft_model, SUM(f.RRh) AS "Report Rate per hour", SUM(f.RRc) AS "Report Rate per cycle", SUM(f.PRRh) AS "Pilot Report Rate per hour", SUM(f.PRRc) AS "Pilot Report Rate per cycle", SUM(f.MRRh) AS "Hourly Maintenance Report Rate", SUM(f.MRRc) AS "Cycle Maintenance Report Rate"
        FROM flight_service f, time_month t, aircraft a
        WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
        GROUP BY t.month, a.aircraft_model
        ORDER BY t.month, a.aircraft_model
;

CREATE MATERIALIZED VIEW model_report_rate_per_year
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ENABLE QUERY REWRITE
    AS SELECT t.year, a.aircraft_model, SUM(f.RRh) AS "Report Rate per hour", SUM(f.RRc) AS "Report Rate per cycle", SUM(f.PRRh) AS "Pilot Report Rate per hour", SUM(f.PRRc) AS "Pilot Report Rate per cycle", SUM(f.MRRh) AS "Hourly Maintenance Report Rate", SUM(f.MRRc) AS "Cycle Maintenance Report Rate"
        FROM flight_service f, time_month t, aircraft a
        WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
        GROUP BY t.year, a.aircraft_model
        ORDER BY t.year, a.aircraft_model
;

CREATE MATERIALIZED VIEW manufacturer_report_rate_month
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ENABLE QUERY REWRITE
    AS SELECT t.month, a.aircraft_manufacturer, SUM(f.RRh) AS "Report Rate per hour", SUM(f.RRc) AS "Report Rate per cycle", SUM(f.PRRh) AS "Pilot Report Rate per hour", SUM(f.PRRc) AS "Pilot Report Rate per cycle", SUM(f.MRRh) AS "Hourly Maintenance Report Rate", SUM(f.MRRc) AS "Cycle Maintenance Report Rate"
        FROM flight_service f, time_month t, aircraft a
        WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
        GROUP BY t.month, a.aircraft_manufacturer
        ORDER BY t.month, a.aircraft_manufacturer
;

CREATE MATERIALIZED VIEW manufacturer_report_rate_year
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ENABLE QUERY REWRITE
    AS SELECT t.year, a.aircraft_manufacturer, SUM(f.RRh) AS "Report Rate per hour", SUM(f.RRc) AS "Report Rate per cycle", SUM(f.PRRh) AS "Pilot Report Rate per hour", SUM(f.PRRc) AS "Pilot Report Rate per cycle", SUM(f.MRRh) AS "Hourly Maintenance Report Rate", SUM(f.MRRc) AS "Cycle Maintenance Report Rate"
        FROM flight_service f, time_month t, aircraft a
        WHERE t.month = f.month AND a.aircraft_reg_code = f.aircraft_reg_code
        GROUP BY t.year, a.aircraft_manufacturer
        ORDER BY t.year, a.aircraft_manufacturer
;