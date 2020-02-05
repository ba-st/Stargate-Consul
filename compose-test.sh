#!/usr/bin/env bash

echo "TRAVIS_BRANCH=${TRAVIS_BRANCH}" > .env
docker-compose -f api-tests/docker-compose.yml up -d
sleep 10
curl --fail http://localhost:8080/echo/hello
curl --fail http://localhost:8500/v1/agent/services
curl --fail http://localhost:8500/v1/health/checks/echo
docker-compose -f api-tests/docker-compose.yml down
