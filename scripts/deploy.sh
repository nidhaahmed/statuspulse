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
    log "Deployment failed. Starting rollback..."

    docker compose down

    docker tag $IMAGE_NAME:previous $IMAGE_NAME:latest

    docker compose up -d

    log "Rollback completed successfully."
}

log "Starting deployment..."

CURRENT_IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" \
    | grep "$IMAGE_NAME" \
    | head -n 1 || true)

if [ ! -z "$CURRENT_IMAGE" ]; then
    log "Saving current image as rollback target..."
    docker tag $CURRENT_IMAGE $IMAGE_NAME:previous
fi

log "Pulling new image..."
docker pull $IMAGE_NAME:$NEW_TAG

log "Stopping existing stack..."
docker compose down

log "Starting updated stack..."
docker compose up -d

log "Waiting for services..."
sleep 20

log "Running health check..."

if curl -f https://localhost/health -k > /dev/null 2>&1; then
    log "Health check passed."
    log "Deployment completed successfully."
else
    rollback
    exit 1
fi