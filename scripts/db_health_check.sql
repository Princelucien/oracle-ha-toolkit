/*
============================================================
 db_health_check.sql
 Quick health-check for an Oracle primary/standby environment.
 Run as SYSDBA on the primary, or against the standby to check
 apply lag from that side.

 Usage:
   sqlplus / as sysdba @scripts/db_health_check.sql
============================================================
*/

SET LINESIZE 150
SET PAGESIZE 100
SET FEEDBACK OFF

PROMPT
PROMPT ==================== TABLESPACE USAGE ====================
SELECT
    df.tablespace_name,
    ROUND(df.bytes / 1024 / 1024, 0)                          AS size_mb,
    ROUND((df.bytes - NVL(fs.bytes, 0)) / 1024 / 1024, 0)     AS used_mb,
    ROUND(((df.bytes - NVL(fs.bytes, 0)) / df.bytes) * 100, 1) AS pct_used
FROM
    (SELECT tablespace_name, SUM(bytes) bytes
     FROM dba_data_files GROUP BY tablespace_name) df,
    (SELECT tablespace_name, SUM(bytes) bytes
     FROM dba_free_space GROUP BY tablespace_name) fs
WHERE df.tablespace_name = fs.tablespace_name(+)
ORDER BY pct_used DESC;

PROMPT
PROMPT ==================== INVALID OBJECTS ====================
SELECT owner, object_type, object_name, status
FROM dba_objects
WHERE status = 'INVALID'
ORDER BY owner, object_type;

PROMPT
PROMPT ==================== ARCHIVE LOG GAP (last 24h) ====================
SELECT thread#, MAX(sequence#) AS last_archived_seq
FROM v$archived_log
WHERE completion_time > SYSDATE - 1
GROUP BY thread#
ORDER BY thread#;

PROMPT
PROMPT ==================== DATA GUARD APPLY LAG ====================
SELECT name, value, unit, time_computed
FROM v$dataguard_stats
WHERE name IN ('apply lag', 'transport lag');

PROMPT
PROMPT ==================== DONE ====================
