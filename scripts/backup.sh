#!/bin/bash

set -e

BACKUP_DIR="./backups"

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")

BACKUP_FILE="$BACKUP_DIR/statuspulse_db_${TIMESTAMP}.sql.gz"

LOG_FILE="backup.log"

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log() {
    echo "[$(timestamp)] $1" | tee -a "$LOG_FILE"
}

log "Starting PostgreSQL backup..."

docker exec statuspulse-postgres pg_dump \
    -U statuspulse \
    statuspulse \
    | gzip > "$BACKUP_FILE"

log "Backup created: $BACKUP_FILE"

log "Rotating old backups..."

ls -tp "$BACKUP_DIR"/*.gz 2>/dev/null \
    | tail -n +8 \
    | xargs -r rm --

log "Backup rotation completed."

log "Backup process completed successfully."