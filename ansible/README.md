# BankApp Ansible Playbooks

## What each playbook does
- docker-setup.yml: installs Docker and prerequisites on all hosts
- build-image.yml: downloads the jar from Nexus, builds the image, pushes it to Docker Hub
- deploy-container.yml: pulls the image and runs the container on the Docker hosts

## Secrets
Copy group_vars/all/vault.example.yml to vault.yml, fill in the real values,
then encrypt it: ansible-vault encrypt group_vars/all/vault.yml
Never commit vault.yml or the vault password.

## Run order (from the Ansible server, inside the ansible folder)
ansible all -m ping --ask-vault-pass
ansible-playbook playbooks/docker-setup.yml --ask-vault-pass
ansible-playbook playbooks/build-image.yml -e image_tag=v1.0.0 --ask-vault-pass
ansible-playbook playbooks/deploy-container.yml -e image_tag=v1.0.0 --ask-vault-pass

Running deploy-container.yml twice should report changed=0 the second time.

## Rollback
Re-run deploy-container.yml with the previous version:
ansible-playbook playbooks/deploy-container.yml -e image_tag=<previous tag> --ask-vault-pass