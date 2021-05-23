# Rancher One Click Installer

Install Rancher in Hetzner Cloud with one command.

## Prerequisites

The following software has to be installed on your machine:

* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* [RKE](https://github.com/rancher/rke/releases)
* [hetznerdns](https://github.com/earthquakesan/hetznerdns-py)

I assume, that you have created a project inside Hetzner cloud account and an API token for that project.
I also assume that you are using Hetzner DNS and have a token for it.

## Defaults and Costs

To modify the defaults, see playbooks/values.yml file.

* Default Hetzner instance type cx31 (2vCPU/8GB RAM) - cost per instance: 10.59 Euros/month
* Debian 10
* SSH key from: ~/.ssh/id_rsa.pub (use `ssh-keygen` to generate one if you don't have it)
* [Hetzner CSI driver](https://github.com/hetznercloud/csi-driver) is installed in the k8s cluster

Total Costs: (number of instances) * (cost per instance) = 3 * 10.59 Euros/month = 31.77 Euros/month

## TL;DR

```
# Deploy Rancher Cluster
export HETZNER_API_TOKEN=yourapitoken
export HETZNER_DNS_TOKEN=yourdnstoken
# for example DOMAIN=example.com
export DOMAIN=yourdomain
# EMAIL is necessary for letsencrypt certificate provisioning
export EMAIL=youremail@example.com
make rancher-create

# Delete Hetzner VMs and DNS entry
# Also delete everything from inventory/ and rke/ directories
# NOTE: this will not delete any of the clusters created with Rancher
make clean
```
