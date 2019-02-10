
local k = import 'ksonnet/ksonnet.beta.3/k.libsonnet';
local ingress = k.extensions.v1beta1.ingress;
local ingressTls = ingress.mixin.spec.tlsType;
local ingressRule = ingress.mixin.spec.rulesType;
local httpIngressPath = ingressRule.mixin.http.pathsType;

local kp =
  (import 'kube-prometheus/kube-prometheus.libsonnet') +
  (import 'kube-prometheus/kube-prometheus-kubeadm.libsonnet')  {
    _config+:: {
      namespace: 'monitoring',

      alertmanager+:: {
        alertmanager+: {
          spec+: {
            externalUrl: 'https://alertmanager.ttys0.net',
          },
        },
      },
      grafana+:: {
        config: { // http://docs.grafana.org/installation/configuration/
          sections: {
            "auth.anonymous": {enabled: true},
            server+: {
              root_url: 'https://grafana.ttys0.net'
            },
          },
        },
      },
      prometheus+:: {
        namespaces+: ['ceph', 'consul', 'db', 'elk', 'unifi', 'vault', 'web'],
        prometheus+: {
          spec+: {
            externalURL: 'https://prometheus.ttys0.net'
          },
        },
      },
      // Create ingress objects per application
      ingress+:: {
        'alertmanager-main':
          ingress.new() +
          ingress.mixin.metadata.withName('alertmanager-main') +
          ingress.mixin.metadata.withNamespace($._config.namespace) +
          ingress.mixin.metadata.withAnnotations({
            'kubernetes.io/ingress.class': 'traefik',
          }) +
          ingress.mixin.spec.withRules(
            ingressRule.new() +
            ingressRule.withHost('alertmanager.example.com') +
            ingressRule.mixin.http.withPaths(
              httpIngressPath.new() +
              httpIngressPath.mixin.backend.withServiceName('alertmanager-main') +
              httpIngressPath.mixin.backend.withServicePort('web')
            ),
          ) +
          ingress.mixin.spec.withTls(
            ingressTls.new() +
            ingressTls.withSecretName('ttys0-tls')
          ),
        'grafana':
          ingress.new() +
          ingress.mixin.metadata.withName('grafana') +
          ingress.mixin.metadata.withNamespace($._config.namespace) +
          ingress.mixin.metadata.withAnnotations({
            'kubernetes.io/ingress.class': 'traefik',
          }) +
          ingress.mixin.spec.withRules(
            ingressRule.new() +
            ingressRule.withHost('grafana.example.com') +
            ingressRule.mixin.http.withPaths(
              httpIngressPath.new() +
              httpIngressPath.mixin.backend.withServiceName('grafana') +
              httpIngressPath.mixin.backend.withServicePort('http')
            ),
          ),
        'prometheus-k8s':
          ingress.new() +
          ingress.mixin.metadata.withName('prometheus-k8s') +
          ingress.mixin.metadata.withNamespace($._config.namespace) +
          ingress.mixin.metadata.withAnnotations({
            'kubernetes.io/ingress.class': 'traefik',
          }) +
          ingress.mixin.spec.withRules(
            ingressRule.new() +
            ingressRule.withHost('prometheus.example.com') +
            ingressRule.mixin.http.withPaths(
              httpIngressPath.new() +
              httpIngressPath.mixin.backend.withServiceName('prometheus-k8s') +
              httpIngressPath.mixin.backend.withServicePort('web')
            ),
          ),
      },
    },
  };

k.core.v1.list.new([
  kp.ingress['prometheus-k8s'],
  kp.ingress['grafana'],
  kp.ingress['aletmanager-main'],
])

{ ['00namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
{ ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
{ ['ingress-' + name]: kp.ingress[name] for name in std.objectFields(kp.ingress) }
