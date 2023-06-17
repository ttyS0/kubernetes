local kp =
  (import 'kube-prometheus/main.libsonnet') +
  (import 'kube-prometheus/addons/all-namespaces.libsonnet') +
  (import 'kube-prometheus/addons/networkpolicies-disabled.libsonnet') +
  // Uncomment the following imports to enable its patches
  // (import 'kube-prometheus/addons/anti-affinity.libsonnet') +
  // (import 'kube-prometheus/addons/managed-cluster.libsonnet') +
  // (import 'kube-prometheus/addons/node-ports.libsonnet') +
  // (import 'kube-prometheus/addons/static-etcd.libsonnet') +
  // (import 'kube-prometheus/addons/custom-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/external-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/pyrra.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'monitoring',
      },
      prometheus+: {
        namespaces: [],
      },
    },
    prometheus+:: {
      prometheus+: {
        spec+: {
          replicas: 1,
          retention: '60d',
          externalUrl: 'http://prometheus.skj.dev',
          storage: {
            volumeClaimTemplate: {
              apiVersion: 'v1',
              kind: 'PersistentVolumeClaim',
              spec: {
                accessModes: ['ReadWriteOnce'],
                resources: { requests: { storage: '300Gi' } },
              },
            },
          },
        },
      },
    },
    prometheusAdapter+: {
      deployment+: {
        spec+: {
          replicas: 1,
        },
      },
    },
  // Configure External URL's per application
  alertmanager+:: {
    alertmanager+: {
      spec+: {
        replicas: 1,
        externalUrl: 'https://alertmanager.skj.dev',
      },
    },
  },
  // Create ingress objects per application
    ingress+:: {
      'prometheus-k8s': {
        apiVersion: 'networking.k8s.io/v1',
        kind: 'Ingress',
        metadata: {
          name: 'prometheus',
          namespace: 'monitoring',
          annotations: {
            'kubernetes.io/tls-acme': 'true',
          },
        },
        spec: {
          rules: [{
            host: 'prometheus.skj.dev',
            http: {
              paths: [{
                path: '/',
                pathType: 'Prefix',
                backend: {
                  service: {
                    name: $.prometheus.service.metadata.name,
                    port: {
                      name: 'web',
                    },
                  },
                },
              }],
            },
          }],
          tls: [{
            hosts: ['prometheus.skj.dev'],
            secretName: 'prometheus-skj-dev-cert',
            }],
          }
        },
      'grafana': {
        apiVersion: 'networking.k8s.io/v1',
        kind: 'Ingress',
        metadata: {
          name: 'grafana',
          namespace: 'monitoring',
          annotations: {
            'kubernetes.io/tls-acme': 'true',
          },
        },
        spec: {
          rules: [{
            host: 'grafana.skj.dev',
            http: {
              paths: [{
                path: '/',
                pathType: 'Prefix',
                backend: {
                  service: {
                    name: $.grafana.service.metadata.name,
                    port: {
                      name: 'http',
                    },
                  },
                },
              }],
            },
          }],
          tls: [{
            hosts: ['grafana.skj.dev'],
            secretName: 'grafana-skj-dev-cert',
            }],
          },
        },
    },
 };


{ 'setup/0namespace-namespace': kp.kubePrometheus.namespace } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator))
} +
// { 'setup/pyrra-slo-CustomResourceDefinition': kp.pyrra.crd } +
// serviceMonitor and prometheusRule are separated so that they can be created after the CRDs are ready
{ 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ 'prometheus-operator-prometheusRule': kp.prometheusOperator.prometheusRule } +
{ 'kube-prometheus-prometheusRule': kp.kubePrometheus.prometheusRule } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['blackbox-exporter-' + name]: kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
// { ['pyrra-' + name]: kp.pyrra[name] for name in std.objectFields(kp.pyrra) if name != 'crd' } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['kubernetes-' + name]: kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane) }
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
{ [name + '-ingress']: kp.ingress[name] for name in std.objectFields(kp.ingress) }

