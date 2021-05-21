rancher-create:
	ansible-playbook -e @playbooks/values.yml playbooks/render_inventory.yml
	ansible-playbook -e @playbooks/values.yml playbooks/main.yml
	# Wait until VMs are provisioned
	sleep 30
	ansible-playbook -e @playbooks/values.yml -i inventory/hosts.hcloud.yml playbooks/provision_vms.yml
	ansible-playbook -e @playbooks/values.yml -i inventory/hosts.hcloud.yml playbooks/render_rke_config.yml
	cd rke/ && rke up
	./k8s-provisioning/create-dns-entry.sh
	./k8s-provisioning/provision-k8s.sh

rancher-destroy:
	ansible-playbook -e @playbooks/values.yml playbooks/destroy_vms.yml
	./k8s-provisioning/delete-dns-entry.sh

clean: rancher-destroy
	rm -rf inventory/*
	rm -rf rke/*
