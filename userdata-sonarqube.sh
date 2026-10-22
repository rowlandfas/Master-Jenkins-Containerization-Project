#!/bin/bash

# Stop if a command fails, a variable is missing, or a pipeline fails.
# Do not use "set -x": it could expose passwords in startup logs.
set -euo pipefail

# Restrict permissions on files created by this script.
umask 077

# =========================================================
# 1. Set the server hostname
# =========================================================

hostnamectl set-hostname sonarqube-19thoct

# Preserve the hostname across cloud-init runs.
echo "preserve_hostname: true" \
  > /etc/cloud/cloud.cfg.d/99_hostname.cfg

# =========================================================
# 2. Install Docker on RHEL
#
# The SonarQube image includes its required Java runtime.
# PostgreSQL runs in a separate container on the same host.
# =========================================================

dnf install -y dnf-plugins-core curl openssl

dnf config-manager --add-repo \
  https://download.docker.com/linux/rhel/docker-ce.repo

dnf install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

systemctl enable --now docker

# =========================================================
# 3. Configure Linux limits for SonarQube's search engine
#
# These settings apply to the host, including its containers.
# =========================================================

cat > /etc/sysctl.d/99-sonarqube.conf <<'SYSCTL'
vm.max_map_count=524288
fs.file-max=131072
SYSCTL

sysctl --system

# =========================================================
# 4. Create a protected configuration directory
# =========================================================

install -d -m 0700 /opt/sonarqube-stack
cd /opt/sonarqube-stack

# Generate a random database password on the server.
# Preserve it if this script is run again.
# No database password is embedded in Git or EC2 user data.
if [ ! -f .env ]; then
  database_password="$(openssl rand -hex 32)"

  printf 'POSTGRES_PASSWORD=%s\n' "$database_password" > .env

  unset database_password
fi

chmod 0600 .env

# =========================================================
# 5. Define SonarQube and PostgreSQL
#
# PostgreSQL:
# - No host port is published.
# - Only containers on this Docker network can reach it.
#
# SonarQube:
# - Publishes port 9000.
# - Uses PostgreSQL rather than the evaluation H2 database.
#
# Named volumes preserve data when containers are recreated.
# They remain on the EC2 disk; they are NOT backups.
# =========================================================

cat > compose.yaml <<'COMPOSE'
services:
  database:
    image: postgres:17
    restart: unless-stopped

    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: sonarqube

    volumes:
      - postgres_data:/var/lib/postgresql/data

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U sonar -d sonarqube"]
      interval: 10s
      timeout: 5s
      retries: 30

  sonarqube:
    image: sonarqube:community
    restart: unless-stopped

    depends_on:
      database:
        condition: service_healthy

    ports:
      - "9000:9000"

    environment:
      SONAR_JDBC_URL: jdbc:postgresql://database:5432/sonarqube
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: ${POSTGRES_PASSWORD}

    volumes:
      - sonar_data:/opt/sonarqube/data
      - sonar_extensions:/opt/sonarqube/extensions
      - sonar_logs:/opt/sonarqube/logs

    ulimits:
      nofile:
        soft: 131072
        hard: 131072
      nproc: 8192

volumes:
  postgres_data:
  sonar_data:
  sonar_extensions:
  sonar_logs:
COMPOSE

# =========================================================
# 6. Download images and start the services
#
# Outbound internet access through NAT is required.
# For repeatable releases, replace image tags above with
# team-approved version tags or image digests before deploying.
# =========================================================

docker compose pull
docker compose up -d

# =========================================================
# 7. Verify SonarQube is operational
#
# A web page responding does not necessarily mean SonarQube
# is ready. Wait until the system status reports UP.
# Fail the script if it does not become ready in 15 minutes.
# =========================================================

for attempt in $(seq 1 90); do
  if curl --silent --show-error --fail \
    --connect-timeout 5 \
    --max-time 10 \
    http://127.0.0.1:9000/api/system/status \
    | grep -Eq '"status"[[:space:]]*:[[:space:]]*"UP"'; then

    echo "SonarQube is operational on private-server port 9000."
    echo "Access through your approved private network or bastion tunnel."
    echo "Change the initial administrator password immediately."
    exit 0
  fi

  sleep 10
done

echo "ERROR: SonarQube did not become operational in time." >&2
docker compose ps
exit 1

