#!/bin/bash
terraform plan -out=tfplan -input=false
terraform apply -input=false -auto-approve
sleep 3m
export ANSIBLE_CONFIG=/Users/ananthfrancis/Documents/test/kubernetes-test/ansible/inventories/ansible.cfg
ansible-playbook -i ansible/inventories/node_gcp.yml ansible/non-root-user.yml
ansible-playbook -i ansible/inventories/node_gcp.yml ansible/master-cluster.yml
ansible-playbook -i ansible/inventories/node_gcp.yml ansible/helm-installation.yml
sleep 1m
ansible-playbook -i ansible/inventories/node_gcp.yml ansible/monitoring.yml
ansible-playbook -i ansible/inventories/node_gcp.yml ansible/logging.yml
ansible-playbook -i ansible/inventories/node_gcp.yml ansible/Jenkins-config.yml