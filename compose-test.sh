#!/usr/bin/env bash

if [[ -z "${TRAVIS_PULL_REQUEST_BRANCH}" ]]; then
  echo "BRANCH_NAME=${TRAVIS_BRANCH}" > .env
else
  echo "BRANCH_NAME=${TRAVIS_PULL_REQUEST_BRANCH}" > .env
fi
docker-compose -f api-tests/docker-compose.yml up -d || exit 1
sleep 10
curl --fail http://localhost:8080/echo/hello || exit 1
curl --fail http://localhost:8500/v1/agent/services || exit 1
curl --fail http://localhost:8500/v1/health/checks/echo || exit 1
docker-compose -f api-tests/docker-compose.yml down
