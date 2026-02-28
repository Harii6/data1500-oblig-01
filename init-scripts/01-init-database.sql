-- ============================================================================
-- ============================================================================
-- DATA1500 - Oblig 1: Arbeidskrav I våren 2026
-- Initialiserings-skript for PostgreSQL
-- ============================================================================

-- ============================================================================
-- Opprett database
-- ============================================================================
CREATE DATABASE sykkel_system;

\connect sykkel_system

-- ============================================================================
-- Opprett grunnleggende tabeller
-- ============================================================================

CREATE TABLE stasjon(
    stasjon_id SERIAL PRIMARY KEY,
    navn VARCHAR(150) NOT NULL CHECK (char_length(navn) > 0),
    sted VARCHAR(150) NOT NULL CHECK (char_length(sted) > 0)
);

CREATE TABLE låse(
    stasjon_id INT REFERENCES stasjon(stasjon_id),
    låse_nummer SMALLINT NOT NULL CHECK (låse_nummer > 0),
    PRIMARY KEY (stasjon_id, låse_nummer)
);

CREATE TABLE sykkel(
    sykkel_id SERIAL PRIMARY KEY,
    tatt_i_bruk TIMESTAMP NULL CHECK (tatt_i_bruk <= NOW()),
    stasjon_id INT,
    låse_nummer SMALLINT,
    FOREIGN KEY (stasjon_id, låse_nummer)
        REFERENCES låse(stasjon_id, låse_nummer)
);

CREATE TABLE kunde(
    kunde_id SERIAL PRIMARY KEY,
    mobilnummer VARCHAR(25) NOT NULL UNIQUE
        CHECK (char_length(mobilnummer) BETWEEN 6 AND 25),
    epost VARCHAR(150) NOT NULL UNIQUE
        CHECK (position('@' in epost) > 1),
    fornavn VARCHAR(150) NOT NULL
        CHECK (char_length(fornavn) > 0),
    etternavn VARCHAR(150) NOT NULL
        CHECK (char_length(etternavn) > 0)
);

CREATE TABLE utleie(
    utleie_id SERIAL PRIMARY KEY,
    sykkel_id INT NOT NULL REFERENCES sykkel(sykkel_id),
    kunde_id INT NOT NULL REFERENCES kunde(kunde_id),
    starttid TIMESTAMP NOT NULL,
    sluttid TIMESTAMP NULL,
    pris NUMERIC(10,2) NULL CHECK (pris >= 0),
    CHECK (sluttid IS NULL OR sluttid > starttid)
);



-- ============================================================================
-- Sett inn testdata
-- ============================================================================


INSERT INTO stasjon (navn, sted) VALUES
('Sentrum', 'Oslo'),
('Majorstuen', 'Oslo'),
('Grunerløkka', 'Oslo'),
('Blindern', 'Oslo'),
('Storo', 'Oslo');



INSERT INTO låse (stasjon_id, låse_nummer)
SELECT s, l
FROM generate_series(1,5) AS s,
     generate_series(1,20) AS l;



INSERT INTO sykkel (stasjon_id, låse_nummer)
SELECT stasjon_id, låse_nummer
FROM låse
LIMIT 100;



INSERT INTO kunde (mobilnummer, epost, fornavn, etternavn) VALUES
('90000001', 'kunde1@test.no', 'Ola', 'Nordmann'),
('90000002', 'kunde2@test.no', 'Kari', 'Hansen'),
('90000003', 'kunde3@test.no', 'Per', 'Olsen'),
('90000004', 'kunde4@test.no', 'Anne', 'Larsen'),
('90000005', 'kunde5@test.no', 'Jon', 'Johansen');



INSERT INTO utleie (sykkel_id, kunde_id, starttid, sluttid, pris)
SELECT
    (RANDOM()*99 + 1)::INT,
    (RANDOM()*4 + 1)::INT,
    start_time,
    start_time + (RANDOM()*3 || ' days')::INTERVAL,
    ROUND((RANDOM()*200)::numeric,2)
FROM (
    SELECT
        NOW() - (RANDOM()*10 || ' days')::INTERVAL AS start_time
    FROM generate_series(1,50)
) t;

-- ============================================================================
-- DBA setninger (rolle: kunde, bruker: kunde_1)
-- ============================================================================





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
