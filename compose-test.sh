#!/usr/bin/env bash

echo "TRAVIS_BRANCH=${TRAVIS_BRANCH}" > .env
docker-compose -f api-tests/docker-compose.yml up -d || exit 1
sleep 10
curl --fail http://localhost:8080/echo/hello || exit 1
curl --fail http://localhost:8500/v1/agent/services || exit 1
curl --fail http://localhost:8500/v1/health/checks/echo || exit 1
docker-compose -f api-tests/docker-compose.yml down
