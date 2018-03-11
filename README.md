# README

- kubectl create namespace ceph

- kubectl create secret generic ceph-rbd-kube --type="kubernetes.io/rbd" --namespace=ceph --from-literal=key='XXXXX'

- kubectl create secret generic ceph-secret-admin --type="kubernetes.io/rbd" --namespace=ceph --from-literal=key='XXXXX'

