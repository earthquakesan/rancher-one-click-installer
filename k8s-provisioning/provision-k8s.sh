#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

CURDIR=$(dirname $(realpath $0))
KUBECONFIG="${CURDIR}/../rke/kube_config_cluster.yml"

# Install Hetzner CSI driver
# https://github.com/hetznercloud/csi-driver
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: hcloud-csi
  namespace: kube-system
stringData:
  token: ${HETZNER_API_TOKEN}
EOF

kubectl apply -f https://raw.githubusercontent.com/hetznercloud/csi-driver/master/deploy/kubernetes/hcloud-csi.yml

kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.crds.yaml
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.3.1

# wait until cert-manager is ready
kubectl -n cert-manager rollout status deployment cert-manager
kubectl -n cert-manager rollout status deployment cert-manager-cainjector
kubectl -n cert-manager rollout status deployment cert-manager-webhook

cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${EMAIL}
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${EMAIL}
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
# Install rancher

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update

kubectl create namespace cattle-system

helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.${DOMAIN} \
  --set ingress.tls.source=letsEncrypt \
  --set letsEncrypt.email=${EMAIL}

kubectl -n cattle-system rollout status deployment rancher
echo "Resetting the password..."
kubectl -n cattle-system exec $(kubectl -n cattle-system get pods -l app=rancher | grep '1/1' | head -1 | awk '{ print $1 }') -- reset-password

echo "Navigate to https://rancher.${DOMAIN} to your Rancher Instance."
