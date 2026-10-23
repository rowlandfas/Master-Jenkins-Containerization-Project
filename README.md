# 19th-Oct-2026-Jenkins-Containerization-Project

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

## BankApp DNS (Route 53)

### How traffic reaches the app

```
User -> bankapp.everythingops.io (Route 53) -> public ALB (HTTPS 443) -> Docker hosts (port 8080)
```

Defined in `bankapp-alb.tf`.

| Item | Value |
|---|---|
| Domain | `everythingops.io` |
| Hosted zone | Public, ID `Z03461702SMK35VTE8B67` (existing, looked up with `data.aws_route53_zone.everythingops`, not created by this project) |
| App record | `bankapp.everythingops.io`, type **A (alias)** to the BankApp ALB. Change with the `app_subdomain` variable. |
| Certificate | ACM, DNS-validated through validation records in the same zone |
| HTTP | Port 80 redirects to HTTPS (301) |
| HTTPS | Port 443, policy `ELBSecurityPolicy-TLS13-1-2-2021-06` |
| Health check | Target group calls `app_health_check_path` (default `/`) on port 8080 |

An alias record is used instead of a CNAME because it follows the ALB's changing IP addresses automatically, Route 53 does not charge for alias queries to AWS resources, and `evaluate_target_health` stops Route 53 answering if the ALB has no healthy hosts.

### Domain ownership requirements

- The hosted zone only works if the domain's registrar points to its name servers. Verified on 23 Oct 2026; the registrar and the hosted zone both list:
  - `ns-3.awsdns-00.com`
  - `ns-527.awsdns-01.net`
  - `ns-1384.awsdns-45.org`
  - `ns-1869.awsdns-41.co.uk`
- Do **not** delete and recreate the hosted zone. A new zone gets new name servers, and every record would stop resolving until the registrar is updated.
- The zone is shared with other projects in this AWS account. Only add or change records for this project.

To re-check the delegation:

```bash
aws route53 get-hosted-zone --id Z03461702SMK35VTE8B67 --query 'DelegationSet.NameServers' --output table
dig NS everythingops.io +short
```

### Verifying after `terraform apply`

```bash
# The record exists and resolves to the ALB's IP addresses
dig bankapp.everythingops.io +short
nslookup bankapp.everythingops.io

# Ask Route 53 directly, before propagation finishes
dig @ns-3.awsdns-00.com bankapp.everythingops.io +short

# HTTP redirects to HTTPS, and HTTPS reaches the app
curl -I http://bankapp.everythingops.io
curl -I https://bankapp.everythingops.io
```

New records usually resolve within a few minutes. If `dig` returns nothing, query the AWS name server directly (as above) to confirm the record exists, then wait for propagation.
