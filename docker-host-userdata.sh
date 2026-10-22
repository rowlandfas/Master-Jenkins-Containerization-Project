#!/bin/bash
set -euo pipefail

# Save all output to a log file so failed boots can be investigated
exec > >(tee -a /var/log/docker-host-setup.log) 2>&1

# Retry a command up to 5 times, 15 seconds apart,
# so a short network blip doesn't leave a host without Docker
retry() {
  local attempt=1
  until "$@"; do
    if [ "$attempt" -ge 5 ]; then
      echo "FAILED after $attempt attempts: $*"
      return 1
    fi
    echo "Attempt $attempt failed: $*. Retrying in 15 seconds..."
    attempt=$((attempt + 1))
    sleep 15
  done
}

# Install the SSM agent (Red Hat images don't include it) so the team
# can open a session through Session Manager without SSH
retry dnf install -y https://s3.eu-west-3.amazonaws.com/amazon-ssm-eu-west-3/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable --now amazon-ssm-agent

# Remove Red Hat's own container tools so they don't clash with Docker
dnf remove -y podman buildah runc || true

# Install Docker Engine from Docker's official Red Hat repository
retry dnf install -y dnf-plugins-core
retry dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
retry dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Docker daemon settings:
# - rotate container logs so the disk never fills up
# - keep containers running if the Docker daemon restarts
# The daemon only listens on the local socket, never on a network port
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<'JSON'
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" },
  "live-restore": true
}
JSON

# Folder for any persistent application data.
# SELinux stays enforcing; mount this folder into containers with :Z
# (for example -v /opt/bankapp/data:/data:Z) so SELinux allows access
mkdir -p /opt/bankapp/data
chown ec2-user:ec2-user /opt/bankapp/data

# Only root and ec2-user (used by Ansible) can control Docker
usermod -aG docker ec2-user

# Start Docker now and on every boot
systemctl enable docker
systemctl restart docker

# Confirm Docker is actually running before marking setup complete
systemctl is-active --quiet docker
echo "Docker host setup completed successfully"
