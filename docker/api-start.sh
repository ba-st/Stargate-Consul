#!/usr/bin/env bash

exec /opt/pharo/pharo \
	/opt/Stargate-Consul-Example-API/Pharo.image \
	stargate-consul-example \
    --public-URL="${PUBLIC_URL}" \
		"${PORT:+--port=$PORT}" \
		"${OPERATIONS_SECRET:+--operations-secret=$OPERATIONS_SECRET}" \
    --consul-agent-location="${CONSUL_AGENT_LOCATION}"
