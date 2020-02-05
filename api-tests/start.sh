#!/usr/bin/env bash

# SIGTERM-handler
termination_handler() {
  echo 'SIGTERM was received, stopping the API'
	curl --silent --fail --request POST \
	  --header "Authorization: Bearer $APPLICATION_CONTROL_TOKEN" \
		--header "Content-Type:application/json" \
	  --header "Accept: application/json" \
		--data '{"jsonrpc": "2.0" ,"method": "shutdown"}' \
	  http://localhost:"${PORT:-8080}"/operations/application-control
  exit 143; # 128 + 15 -- SIGTERM
}

trap 'kill ${!}; termination_handler' SIGTERM

/opt/pharo/pharo \
	/opt/Stargate-Consul-Example-API/Pharo.image \
	stargate-consul-example \
		"${PORT:+--port=$PORT}" \
		"${PUBLIC_URL:+--public-URL=$PUBLIC_URL}" \
		"${OPERATIONS_SECRET:+--operations-secret=$OPERATIONS_SECRET}" \
    "${CONSUL_AGENT_LOCATION:+--consul-agent-location=$CONSUL_AGENT_LOCATION}" &

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
