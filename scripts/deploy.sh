#!/bin/bash

set -e

LOG_FILE="deploy.log"

IMAGE_NAME="ghcr.io/nidhaahmed/statuspulse"
NEW_TAG=${1:-latest}

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log() {
    echo "[$(timestamp)] $1" | tee -a $LOG_FILE
}

rollback() {
    log "Deployment failed. Rolling back..."

    docker compose down

    docker tag $IMAGE_NAME:previous statuspulse-app:rollback

    docker compose up -d

    log "Rollback completed."
}

log "Starting deployment..."

PREVIOUS_IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep statuspulse | head -n 1 || true)

if [ ! -z "$PREVIOUS_IMAGE" ]; then
    docker tag $PREVIOUS_IMAGE $IMAGE_NAME:previous
fi

log "Pulling latest image..."
docker pull $IMAGE_NAME:$NEW_TAG

log "Stopping existing containers..."
docker compose down

log "Starting updated stack..."
docker compose up -d

log "Waiting for services..."
sleep 15

log "Running health check..."

if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    log "Health check passed."
    log "Deployment successful."
else
    rollback
    exit 1
fi