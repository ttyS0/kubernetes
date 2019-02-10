local k = import 'ksonnet/ksonnet.beta.3/k.libsonnet';
local service = k.core.v1.service;
local servicePort = k.core.v1.service.mixin.spec.portsType;

{
  prometheus+: {
    service+:
      service.mixin.spec.withPorts(servicePort.newNamed('web', 80, 'web')) +
      service.mixin.spec.withType('LoadBalancer'),
  },
  alertmanager+: {
    service+:
      service.mixin.spec.withPorts(servicePort.newNamed('web', 80, 'web')) +
      service.mixin.spec.withType('LoadBalancer'),
  },
  grafana+: {
    service+:
      service.mixin.spec.withPorts(servicePort.newNamed('web', 80, 'web')) +
      service.mixin.spec.withType('LoadBalancer'),
  },
}
