local k = import 'ksonnet/ksonnet.beta.3/k.libsonnet';
local service = k.core.v1.service;

{
  prometheus+: {
    service+:
      service.mixin.spec.withType('LoadBalancer'),
  },
  alertmanager+: {
    service+:
      service.mixin.spec.withType('LoadBalancer'),
  },
  grafana+: {
    service+:
      service.mixin.spec.withType('LoadBalancer'),
  },
}
