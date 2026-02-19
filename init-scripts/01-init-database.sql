-- ============================================================================
-- ============================================================================
-- DATA1500 - Oblig 1: Arbeidskrav I våren 2026
-- Initialiserings-skript for PostgreSQL
-- ============================================================================

-- ============================================================================
-- Opprett database
-- ============================================================================
CREATE DATABASE sykkel_system
WITH
OWNER = postgres
ENCODING = 'UTF8'
LC_COLLATE = 'en_US.utf8'
LC_CTYPE = 'en_US.utf8'
TEMPLATE = template0
CONNECTION LIMIT = -1;

-- Connect to the new database
\c sykkel_system

-- ============================================================================
-- Opprett grunnleggende tabeller
-- ============================================================================

CREATE TABLE stasjon(
    stasjon_id SERIAL PRIMARY KEY,
    navn VARCHAR(150) NOT NULL,
    sted VARCHAR(150) NOT NULL
);

CREATE TABLE låse(
    stasjon_id INT REFERENCES stasjon(stasjon_id),
    låse_nummer SMALLINT NOT NULL,
    PRIMARY KEY (stasjon_id, låse_nummer)
);

CREATE TABLE sykkel(
    sykkel_id SERIAL PRIMARY KEY,
    stasjon_id INT,
    låse_nummer SMALLINT,
    FOREIGN KEY (stasjon_id, låse_nummer)
        REFERENCES låse(stasjon_id, låse_nummer)
);

CREATE TABLE kunde(
    kunde_id SERIAL PRIMARY KEY,
    mobilnummer VARCHAR(25) NOT NULL UNIQUE,
    epost VARCHAR(150) NOT NULL UNIQUE,
    fornavn VARCHAR(150) NOT NULL,
    etternavn VARCHAR(150) NOT NULL
);

CREATE TABLE utleie(
    utleie_id SERIAL PRIMARY KEY,
    sykkel_id INT NOT NULL REFERENCES sykkel(sykkel_id),
    kunde_id INT NOT NULL REFERENCES kunde(kunde_id),
    starttid TIMESTAMP NOT NULL,
    sluttid TIMESTAMP NULL,
    pris NUMERIC(10,2) NULL
);



-- ============================================================================
-- Sett inn testdata
-- ============================================================================

-- 5 Stations
INSERT INTO stasjon (navn, sted) VALUES
('Sentrum', 'Oslo'),
('Majorstuen', 'Oslo'),
('Grunerløkka', 'Oslo'),
('Blindern', 'Oslo'),
('Storo', 'Oslo');


-- 100 Locks (20 per station)
INSERT INTO låse (stasjon_id, låse_nummer)
SELECT s, l
FROM generate_series(1,5) AS s,
     generate_series(1,20) AS l;


-- 100 Bikes (assign first 100 locks)
INSERT INTO sykkel (stasjon_id, låse_nummer)
SELECT stasjon_id, låse_nummer
FROM låse
LIMIT 100;


-- 5 Customers
INSERT INTO kunde (mobilnummer, epost, fornavn, etternavn) VALUES
('90000001', 'kunde1@test.no', 'Ola', 'Nordmann'),
('90000002', 'kunde2@test.no', 'Kari', 'Hansen'),
('90000003', 'kunde3@test.no', 'Per', 'Olsen'),
('90000004', 'kunde4@test.no', 'Anne', 'Larsen'),
('90000005', 'kunde5@test.no', 'Jon', 'Johansen');


-- 50 Rentals
INSERT INTO utleie (sykkel_id, kunde_id, starttid, sluttid, pris)
SELECT
    (RANDOM()*99 + 1)::INT,
    (RANDOM()*4 + 1)::INT,
    NOW() - (RANDOM()*10 || ' days')::INTERVAL,
    NOW() - (RANDOM()*5 || ' days')::INTERVAL,
    ROUND((RANDOM()*200)::numeric,2)
FROM generate_series(1,50);

-- ============================================================================
-- DBA setninger (rolle: kunde, bruker: kunde_1)
-- ============================================================================


CREATE ROLE admin;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;


CREATE ROLE kunde NOINHERIT;


GRANT SELECT ON stasjon TO kunde;
GRANT SELECT ON sykkel TO kunde;


REVOKE ALL ON utleie FROM PUBLIC;

CREATE VIEW utleie_oversikt AS
SELECT
    u.utleie_id,
    k.fornavn,
    k.etternavn,
    k.mobilnummer,
    s.sykkel_id,
    u.starttid,
    u.sluttid,
    u.pris
FROM utleie u
JOIN kunde k ON u.kunde_id = k.kunde_id
JOIN sykkel s ON u.sykkel_id = s.sykkel_id;

GRANT SELECT ON utleie_oversikt TO kunde;


CREATE USER kunde_1 WITH PASSWORD 'passord123';

GRANT kunde TO kunde_1;




-- ============================================================================
-- Opprett indekser for ytelse
-- ============================================================================

CREATE INDEX idx_sykkel_stasjon
ON sykkel(stasjon_id);

CREATE INDEX idx_utleie_kunde
ON utleie(kunde_id);

CREATE INDEX idx_utleie_sykkel
ON utleie(sykkel_id);


-- ============================================================================
-- Ferdig
-- ============================================================================

SELECT 'Database initialisert!' as status;
