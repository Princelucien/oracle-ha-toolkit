# Oracle High-Availability Toolkit

Health-check scripts and a failover runbook for an Oracle primary/standby
(Data Guard) environment. Built against a demo setup with synthetic data —
not tied to any employer system.

## What's here

- `scripts/db_health_check.sql` — single-pass PL/SQL report covering
  tablespace usage, invalid objects, archive log gaps, and Data Guard
  apply/transport lag.
- `docs/failover-runbook.md` — step-by-step runbook for planned
  switchover and unplanned failover.

## Why

Most of this information lives in separate scripts or a DBA's head.
Consolidating it into one health check and one runbook shortens the
time to diagnose drift before it becomes an outage, and gives anyone
on-call a script to run instead of a memory to rely on.

## How to run

    sqlplus / as sysdba @scripts/db_health_check.sql

## Tech

Oracle Database, PL/SQL, Data Guard
