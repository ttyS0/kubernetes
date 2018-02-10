# Hashicorp Vault on Kubernetes

This config is what I'm using to run Vault on my Kubernetes cluster.


I'm using Ceph RBD for the volume storage, creating separate volumes
for the data and logs. Since I can snapshot and backup the volumes as
Ceph actions, I'm using Vault's file storage backend. The StatefulSet
will make sure that a single instance is running. Since this is my
personal Vault, if it's offline for a while in the case of a node
going offline and it getting automatically spun up on a different
node, that's not an issue.


I haven't enabled audit logging just yet, but I intend to get the logs
shuffled off to Elasticsearch. I'm currently thinking about adding a
sidecar Pod running something like a beats or fluentd agent that can
also mount the logs volume.


The Service only exposes Vault to the internal Kubernetes cluster. I'm
not bothering with trying to put TLS into the Vault Pod itself. Instead
I expose it via an Ingress configuration. The FQDN is then handled via
HAProxy that is running on pfSense. This lets me use letsencrypt for
SSL and point multiple services to the same VIP.


