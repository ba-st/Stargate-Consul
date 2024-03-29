#!/usr/bin/env bash

set -e

echo "Building API"
docker compose -f api-tests/gs64/docker-compose.yml build api
echo "Starting Stone"
docker compose -f api-tests/gs64/docker-compose.yml up -d stone
echo "Starting Consul Agent"
docker compose -f api-tests/gs64/docker-compose.yml up -d consul-agent
sleep 2
echo "Installing support code"
docker exec -i -u gemstone gs64-stone-1 ./load-rowan-project.sh Stargate-Consul Stargate-Consul-Examples
echo "Starting API"
docker compose -f api-tests/gs64/docker-compose.yml up -d api
sleep 10
echo "Testing API"
curl --fail http://localhost:8080/echo/hello
curl --fail http://localhost:8500/v1/agent/services
curl --fail http://localhost:8500/v1/health/checks/echo
HEALTH_STATUS=$(curl -s http://localhost:8500/v1/health/checks/echo | jq '.[0].Status')
echo "$HEALTH_STATUS"
if [ "$HEALTH_STATUS" != '"passing"' ]; then
  echo "Error: Echo service is unhealthy" >&2
  docker compose -f api-tests/gs64/docker-compose.yml down
  exit 1
fi
docker compose -f api-tests/gs64/docker-compose.yml down
