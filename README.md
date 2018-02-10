# Docker Registry on Kubernetes

Since by Kubernetes cluster is running on bare metal in house, it makes sense to have a private Docker Registry so images can be pulled locally instead of having to reach out to the internet every time.

I'm using HAProxy on an external pfSense box to handle the DNS, load balancing to the Ingress ports, and SSL offloading via LetsEncrypt.

For the auth secret, save to a file named `registry.htpasswd`, and create a secret via `kubectl create secret generic registry-auth --from-file=registry.htpasswd`.


