#!/bin/bash

LOG_FILE="./statuspulse-monitor.log"

HEALTH_URL="https://localhost/health"

DISK_THRESHOLD=80
MEMORY_THRESHOLD=90

EXPECTED_CONTAINERS=(
  "statuspulse-app"
  "statuspulse-postgres"
  "statuspulse-redis"
  "statuspulse-caddy"
  "statuspulse-uptime-kuma"
)

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log() {
    echo "[$(timestamp)] $1" | tee -a "$LOG_FILE"
}

send_alert() {
    MESSAGE="$1"

    log "ALERT: $MESSAGE"

    if [ ! -z "$ALERT_WEBHOOK_URL" ]; then
        curl -s -X POST \
            -H "Content-Type: application/json" \
            -d "{\"content\":\"🚨 $MESSAGE\"}" \
            "$ALERT_WEBHOOK_URL" > /dev/null 2>&1 || true
    fi
}

log "Starting health monitor run..."

# Health endpoint check
health_response=$(curl -k -s -o /dev/null -w "%{http_code}" \
    --max-time 10 \
    "$HEALTH_URL" || echo "000")

if [ "$health_response" != "200" ]; then
    send_alert "Health endpoint check failed"
else
    log "Health endpoint OK"
fi

# Disk usage check
disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
    send_alert "Disk usage critical: ${disk_usage}%"
else
    log "Disk usage OK: ${disk_usage}%"
fi

# Memory usage check
memory_usage=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')

if [ "$memory_usage" -gt "$MEMORY_THRESHOLD" ]; then
    send_alert "Memory usage critical: ${memory_usage}%"
else
    log "Memory usage OK: ${memory_usage}%"
fi

# Docker container checks
for container in "${EXPECTED_CONTAINERS[@]}"; do

    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        log "Container running: $container"
    else
        send_alert "Container not running: $container"
    fi

done

# TLS certificate expiry check
tls_expiry=$(echo | openssl s_client \
    -connect localhost:443 \
    -servername localhost 2>/dev/null \
    | openssl x509 -noout -dates 2>/dev/null \
    | grep notAfter \
    | cut -d= -f2)

if [ ! -z "$tls_expiry" ]; then
    log "TLS certificate expiry: $tls_expiry"
else
    send_alert "Unable to read TLS certificate"
fi

log "Health monitor run completed."
echo