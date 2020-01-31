# Consul Service Discovery

One of the operational plugins. When enabled interacts with the [Consul Agent HTTP API](https://www.consul.io/api/index.html) to register the running service when the API starts and to deregister it when the API shuts down.

This plugin is disabled by default and allows configuring the services to register. This configuration is made via the `#operations` config.

For example:

```smalltalk
Dictionary new
  at: #operations put: (
    Dictionary new
      at: 'consul-service-discovery'
      put: {
        #enabled -> true.
        #consulAgentLocation -> 'http://localhost:8500' asUrl.
        #definitions -> (Array with: self serviceDefinition)
        } asDictionary;
      yourself
    );
  yourself
```

To create service definitions you can use `ConsulServiceDefinitionBuilder` instances to build the service definitions. Two type of checks are implemented and can be attached to a service definition by sending `addCheck:` to the builder:
- `ConsulAgentDockerBasedCheck` models a health check using the docker infrastructure and can be used when the services are run in docker containers.
- `ConsulAgentHTTPBasedCheck` models a health check performing an HTTP request and can be combined with the `HealthCheckPlugin` in Stargate.

For more details review the [official Consul documentation on Services](https://www.consul.io/api/agent/service.html) and [Checks](https://www.consul.io/api/agent/check.html).

This plugin does not add any new resources to the `/operations` endpoint available in [Stargate](https://github.com/ba-st/Stargate).
