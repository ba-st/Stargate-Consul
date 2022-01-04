# API Skeletons

Since v3, Stargate-Consul brings support on top of [API Skeletons](https://github.com/ba-st/Stargate/blob/release-candidate/docs/reference/Skeleton.md).

To use it, subclass `ConsulAwareStargateApplication` instead of `StargateApplication`
and implement the additionally required subclass responsibilities:

```smalltalk
serviceDefinitions

  ^Array with:
    (self
      buildServiceDefinitionNamed: 'service'
      configuredBy: [ :builder | builder addTag: 'example' ])
```

By using this support the application will enable the Consul Service Discovery plugin
and will use the Consul API to register itself on startup and deregister on shutdown.
