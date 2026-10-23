## Ansible server

`ansible.tf` creates the Ansible server in public subnet 2. On first boot it installs
Ansible and Docker and writes these files to `~/ansible` on the server:

- docker-setup.yml: installs Docker and prerequisites on the Docker hosts
- build-image.yml: downloads the jar from Nexus, builds the image, pushes it to Docker Hub
- deploy-container.yml: pulls the image and runs the container on the Docker hosts

The Dockerfile is in `docker/Dockerfile` and is copied onto the server by `ansible.tf`.

## Running the playbooks

SSH to the Ansible server (use `ssh -A` so your key is forwarded), then:

    cd ~/ansible
    ansible-playbook -i "HOST1_IP,HOST2_IP," docker-setup.yml
    ansible-playbook build-image.yml -e image_tag=v1.0.0
    ansible-playbook -i "HOST1_IP,HOST2_IP," deploy-container.yml -e image_tag=v1.0.0

The Docker hosts are the instances in the 19thoct-docker-hosts-asg auto scaling group.
Passwords and tokens are typed in when prompted and are never stored in files.
Running deploy-container.yml twice should report changed=0 the second time.

## Rollback

Run deploy-container.yml again with the previous version:

    ansible-playbook -i "HOST1_IP,HOST2_IP," deploy-container.yml -e image_tag=<previous tag>