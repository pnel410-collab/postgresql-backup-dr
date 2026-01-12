#!/bin/bash
set -e

##############################################
# PostgreSQL Backup Validation Script
##############################################

BACKUP_ROOT="/var/lib/pgsql/backup/basebackup"
LATEST_BACKUP=$(ls -1dt ${BACKUP_ROOT}/* | head -n 1)

echo "Validating backup: $LATEST_BACKUP"
echo "----------------------------------"

REQUIRED_FILES=(
  "PG_VERSION"
  "global"
  "base"
)

for item in "${REQUIRED_FILES[@]}"; do
  if [ ! -e "${LATEST_BACKUP}/${item}" ]; then
    echo "[ERROR] Missing ${item}"
    exit 1
  fi
done

if [ ! -f "${LATEST_BACKUP}/postgresql.auto.conf" ]; then
  echo "[WARN] postgresql.auto.conf missing (OK if -R not used)"
fi

echo "[OK] Backup structure valid"
echo "[INFO] Backup timestamp:"
stat "${LATEST_BACKUP}" | grep Modify
