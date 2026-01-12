#!/bin/bash
set -e

##############################################
# PostgreSQL Backup Compression Script
##############################################

BASEBACKUP_DIR="/var/lib/pgsql/backup/basebackup"
COMPRESSED_DIR="/var/lib/pgsql/backup/compressed"
LOG_DIR="/var/lib/pgsql/backup/log"

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
LOGFILE="${LOG_DIR}/pg_backup_compress_${DATE}.log"

mkdir -p "$COMPRESSED_DIR"

echo "[INFO] Starting compression: $(date)" >> "$LOGFILE"

for backup in $(find "$BASEBACKUP_DIR" -maxdepth 1 -type d -mtime +0); do
  BASENAME=$(basename "$backup")
  ARCHIVE="${COMPRESSED_DIR}/${BASENAME}.tar.gz"

  if [ ! -f "$ARCHIVE" ]; then
    echo "[INFO] Compressing $backup" >> "$LOGFILE"
    tar -czf "$ARCHIVE" -C "$BASEBACKUP_DIR" "$BASENAME"
  fi
done

echo "[INFO] Compression completed" >> "$LOGFILE"
