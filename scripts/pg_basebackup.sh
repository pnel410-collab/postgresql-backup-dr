#!/bin/bash
set -euo pipefail

##############################################
# PostgreSQL pg_basebackup Script
##############################################

#----Config----
BACKUP_ROOT="/var/lib/pgsql/backup"
BASEBACKUP_DIR="${BACKUP_ROOT}/basebackup"
WAL_DIR="${BACKUP_ROOT}/wal"
LOG_DIR="${BACKUP_ROOT}/log"

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="${BASEBACKUP_DIR}/${DATE}"
LOGFILE="${LOG_DIR}/pg_basebackup_${DATE}.log"

PGHOST="127.0.0.1"
PGPORT="5432"
PGUSER="pgbackup"

RETENTION_DAYS=7

#----Utilities----
PG_BASEBACKUP=$(command -v pg_basebackup)

#----Prepare----
mkdir -p "$BACKUP_DIR" "$WAL_DIR" "$LOG_DIR"

START_TIME=$(date +%s)
HOSTNAME=$(hostname -f)

##############################################
# Logging Header
##############################################
{
echo "##############################################"
echo "# PostgreSQL Physical Backup (pg_basebackup)"
echo "# Host: ${HOSTNAME}"
echo "# Backup Directory: ${BACKUP_DIR}"
echo "# Start Time: $(date)"
echo "##############################################"
} >> "$LOGFILE"

##############################################
# Run pg_basebackup
##############################################
echo "[INFO] Starting pg_basebackup..." >> "$LOGFILE"

$PG_BASEBACKUP \
  -h "$PGHOST" \
  -p "$PGPORT" \
  -U "$PGUSER" \
  -D "$BACKUP_DIR" \
  -Fp \
  -Xs \
  -P \
  -R \
  --checkpoint=fast \
  >> "$LOGFILE" 2>&1

##############################################
# Retention Cleanup
##############################################
echo "[INFO] Applying ${RETENTION_DAYS}-day retention policy..." >> "$LOGFILE"

find "$BASEBACKUP_DIR" -maxdepth 1 -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \;

##############################################
# Completion
##############################################
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "[INFO] Backup completed successfully" >> "$LOGFILE"
echo "[INFO] Duration: ${DURATION} seconds" >> "$LOGFILE"
echo "[INFO] End Time: $(date)" >> "$LOGFILE"
echo "##############################################" >> "$LOGFILE"

exit 0
