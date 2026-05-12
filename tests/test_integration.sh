#!/bin/bash

set -e

BASE_URL="http://localhost:8000"

SERVICE_NAME="google-$(date +%s)"

echo "==================================="
echo "Starting StatusPulse Integration Tests"
echo "==================================="

pass() {
    echo "[PASS] $1"
}

fail() {
    echo "[FAIL] $1"
    exit 1
}

echo
echo "Checking health endpoint..."

health_response=$(curl -s $BASE_URL/health)

echo "$health_response" | grep -q '"status":"healthy"' \
    && pass "Health endpoint working" \
    || fail "Health endpoint failed"

echo
echo "Creating service..."

service_response=$(curl -s -X POST $BASE_URL/services \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"$SERVICE_NAME\",\"url\":\"https://google.com\"}")

echo "$service_response" | grep -q "\"name\":\"$SERVICE_NAME\"" \
    && pass "Service creation working" \
    || fail "Service creation failed"

echo
echo "Testing duplicate service handling..."

duplicate_status=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST $BASE_URL/services \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"$SERVICE_NAME\",\"url\":\"https://google.com\"}")

[ "$duplicate_status" = "409" ] \
    && pass "Duplicate service validation working" \
    || fail "Duplicate service validation failed"

echo
echo "Listing services..."

services_response=$(curl -s $BASE_URL/services)

echo "$services_response" | grep -q "$SERVICE_NAME" \
    && pass "Service listing working" \
    || fail "Service listing failed"

echo
echo "Creating incident..."

incident_response=$(curl -s -X POST $BASE_URL/incidents \
    -H "Content-Type: application/json" \
    -d "{\"service_name\":\"$SERVICE_NAME\",\"title\":\"API Down\"}")

echo "$incident_response" | grep -q '"status":"investigating"' \
    && pass "Incident creation working" \
    || fail "Incident creation failed"

echo
echo "Listing incidents..."

incidents_response=$(curl -s $BASE_URL/incidents)

echo "$incidents_response" | grep -q '"API Down"' \
    && pass "Incident listing working" \
    || fail "Incident listing failed"

echo
echo "==================================="
echo "ALL INTEGRATION TESTS PASSED"
echo "==================================="