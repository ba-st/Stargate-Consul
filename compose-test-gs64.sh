#!/usr/bin/env bash

set -e

if [ $# -eq 0 ]; then
  print_error "Missing GS64 version argument. Eg. 3.7.0"
  exit 1
fi

readonly GS64_VERSION="$1"
readonly GS64_COMPOSE_FILE="api-tests/gs64-$GS64_VERSION/docker-compose.yml"

echo "Building API"
docker compose -f "$GS64_COMPOSE_FILE" build api
echo "Starting Stone"
docker compose -f "$GS64_COMPOSE_FILE" up -d stone
echo "Starting Consul Agent"
docker compose -f "$GS64_COMPOSE_FILE" up -d consul-agent
sleep 2
echo "Installing support code"
docker exec -i -u gemstone gs64-stone-1 ./load-rowan-project.sh Stargate-Consul Stargate-Consul-Examples
echo "Starting API"
docker compose -f "$GS64_COMPOSE_FILE" up -d api
sleep 10
echo "Testing API"
curl --fail http://localhost:8080/echo/hello
curl --fail http://localhost:8500/v1/agent/services
curl --fail http://localhost:8500/v1/health/checks/echo
HEALTH_STATUS=$(curl -s http://localhost:8500/v1/health/checks/echo | jq '.[0].Status')
echo "$HEALTH_STATUS"
if [ "$HEALTH_STATUS" != '"passing"' ]; then
  echo "Error: Echo service is unhealthy" >&2
  docker compose -f "$GS64_COMPOSE_FILE" down
  exit 1
fi
docker compose -f "$GS64_COMPOSE_FILE" down
