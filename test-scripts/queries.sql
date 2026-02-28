-- ============================================================================
-- TEST-SKRIPT FOR OBLIG 1
-- ============================================================================

-- Kjør med: docker-compose exec postgres psql -h -U admin -d data1500_db -f test-scripts/queries.sql

-- En test med en SQL-spørring mot metadata i PostgreSQL (kan slettes fra din script)

SELECT * FROM sykkel;

SELECT etternavn, fornavn, mobilnummer FROM kunde ORDER BY etternavn ASC;

SELECT DISTINCT s.* FROM sykkel s JOIN utleie u ON s.sykkel_id = u.sykkel_id WHERE u.starttid > '2023-04-01';

SELECT COUNT(*) AS antall_kunder FROM kunde;

SELECT k.kunde_id, k.fornavn, k.etternavn, COUNT(u.utleie_id) AS antall_utleie FROM kunde k LEFT JOIN utleie u ON k.kunde_id = u.kunde_id GROUP BY k.kunde_id, k.fornavn, k.etternavn ORDER BY k.kunde_id;

SELECT k.* FROM kunde k LEFT JOIN utleie u ON k.kunde_id = u.kunde_id WHERE u.utleie_id IS NULL;

SELECT s.* FROM sykkel s LEFT JOIN utleie u ON s.sykkel_id = u.sykkel_id WHERE u.utleie_id IS NULL;

SELECT s.sykkel_id, k.fornavn, k.etternavn, u.starttid FROM utleie u JOIN sykkel s ON u.sykkel_id = s.sykkel_id JOIN kunde k ON u.kunde_id = k.kunde_id WHERE u.sluttid IS NULL AND u.starttid < NOW() - INTERVAL '1 day';

select nspname as schema_name from pg_catalog.pg_namespace;
