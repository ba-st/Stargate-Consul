#!/usr/bin/env bash

set -e

if [[ -z "${GITHUB_HEAD_REF##*/}" ]]; then
  echo "BRANCH_NAME=${GITHUB_REF##*/}" > .env
else
  echo "BRANCH_NAME=${GITHUB_HEAD_REF##*/}" > .env
fi
docker-compose -f api-tests/docker-compose.yml up -d
sleep 10
curl --fail http://localhost:8080/echo/hello
curl --fail http://localhost:8500/v1/agent/services
curl --fail http://localhost:8500/v1/health/checks/echo
HEALTH_STATUS=$(curl -s http://localhost:8500/v1/health/checks/echo | jq '.[0].Status')
if [ "$HEALTH_STATUS" != "passing" ]; then
  echo "ERROR: Echo service is unhealthy"
  docker-compose -f api-tests/docker-compose.yml down
  exit 1
fi
docker-compose -f api-tests/docker-compose.yml down
