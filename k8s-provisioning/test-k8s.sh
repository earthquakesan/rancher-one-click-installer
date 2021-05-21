#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

CURDIR=$(dirname $(realpath $0))
KUBECONFIG="${CURDIR}/../rke/kube_config_cluster.yml"

# Test Hetzner CSI
cat <<EOF > hetzner-csi-test.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: csi-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: hcloud-volumes
---
kind: Pod
apiVersion: v1
metadata:
  name: my-csi-app
spec:
  containers:
    - name: my-frontend
      image: busybox
      volumeMounts:
      - mountPath: "/data"
        name: my-csi-volume
      command: [ "sleep", "1000000" ]
  volumes:
    - name: my-csi-volume
      persistentVolumeClaim:
        claimName: csi-pvc
EOF

kubectl create -f hetzner-csi-test.yml

# test cert-manager installation

cat <<EOF > test-resources.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager-test
---
apiVersion: cert-manager.io/v1alpha2
kind: Issuer
metadata:
  name: test-selfsigned
  namespace: cert-manager-test
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: selfsigned-cert
  namespace: cert-manager-test
spec:
  dnsNames:
    - example.com
  secretName: selfsigned-cert-tls
  issuerRef:
    name: test-selfsigned
EOF

k apply -f test-resources.yaml
k delete -f test-resources.yaml

# Test letsencrypt provisioning
cat <<EOF | k apply -f -
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: ${SERVER}-cert
spec:
  secretName: tls-cert
  duration: 24h
  renewBefore: 12h
  commonName: ${SERVER}
  dnsNames:
  - ${SERVER}
  issuerRef:
    name: letsencrypt-staging
    kind: ClusterIssuer
EOF