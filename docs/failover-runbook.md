# Failover Runbook — Primary/Standby (Data Guard)

Demo runbook modeled on a standard Oracle Data Guard primary/standby pair.
Environment names below are placeholders — swap in real host/DB names
before using this against an actual environment.

## Roles

| Role    | Example name | Notes                               |
|---------|--------------|--------------------------------------|
| Primary | `PRIMDB`     | Read/write, production traffic       |
| Standby | `STBYDB`     | Physical standby, managed recovery   |

## 1. Planned switchover (both nodes healthy)

1. Confirm no apply lag: run `scripts/db_health_check.sql` against the standby, confirm `apply lag` = 0.
2. On the primary: `ALTER DATABASE COMMIT TO SWITCHOVER TO STANDBY;`
3. On the (former) standby: `ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;`
4. Open the new primary: `ALTER DATABASE OPEN;`
5. Start managed recovery on the new standby:
   `ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;`
6. Re-point application connection strings / TNS aliases to the new primary.
7. Re-run the health check against both nodes to confirm sync resumed.

## 2. Unplanned failover (primary is down)

1. Verify the primary is actually unreachable (network vs. instance-down — don't fail over for a transient blip).
2. On the standby, check for unapplied redo:
   `SELECT * FROM v$dataguard_stats WHERE name = 'apply lag';`
3. Activate the standby as the new primary:
   `ALTER DATABASE ACTIVATE STANDBY DATABASE;`
4. Open it: `ALTER DATABASE OPEN;`
5. Re-point applications to the new primary.
6. Once the old primary is recoverable, rebuild it as a new standby via RMAN duplicate — don't just restart it as primary (risk of split-brain).

## 3. Post-failover checklist

- [ ] Application connection strings updated
- [ ] Monitoring/alerting re-pointed at the new primary
- [ ] New standby rebuilt and back in sync
- [ ] Incident notes written up while still fresh
