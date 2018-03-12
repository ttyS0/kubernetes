# kubernetes
Kubernetes configs for my home lab

## Ceph
- kubectl create namespace ceph

- kubectl create secret generic ceph-rbd-kube --type="kubernetes.io/rbd" --namespace=ceph --from-literal=key='XXXXX'

- kubectl create secret generic ceph-secret-admin --type="kubernetes.io/rbd" --namespace=ceph --from-literal=key='XXXXX'

## Docker Registry

Since by Kubernetes cluster is running on bare metal in house, it makes sense to have a private Docker Registry so images can be pulled locally instead of having to reach out to the internet every time.

I'm using HAProxy on an external pfSense box to handle the DNS, load balancing to the Ingress ports, and SSL offloading via LetsEncrypt.

For the auth secret, save to a file named `registry.htpasswd`, and create a secret via `kubectl create secret generic registry-auth --from-file=registry.htpasswd`.

The images directory has Docker configs for images being stored in the private repository.

## Hashicorp Vault

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


