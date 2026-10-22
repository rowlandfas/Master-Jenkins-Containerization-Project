#!/bin/bash
# CT-12: Nexus install script
# Runs ONE TIME when the Nexus server first starts.

# Update the server and install wget and tar
yum update -y
yum install -y wget tar

# Change the server's hostname so we know which server we're on
hostnamectl set-hostname nexus-19thoct

# Stop AWS's startup tool (cloud-init) changing the hostname back on reboot
echo "preserve_hostname: true" > /etc/cloud/cloud.cfg.d/99_hostname.cfg

# Create a user called nexus - Nexus should not run as root
useradd --system --create-home --shell /bin/bash nexus

# Download Nexus into /opt and unzip it
# (Nexus now comes with its own Java, so we don't install Java separately)
cd /opt
wget -O nexus.tar.gz https://download.sonatype.com/nexus/3/nexus-3.87.1-01-linux-x86_64.tar.gz
tar -xzf nexus.tar.gz
rm nexus.tar.gz

# Rename the folder to just "nexus" so the path is simple
mv nexus-3* nexus

# Give the nexus user ownership of the Nexus files and data folder
chown -R nexus:nexus /opt/nexus /opt/sonatype-work

# Tell Nexus to run as the nexus user
echo 'run_as_user="nexus"' > /opt/nexus/bin/nexus.rc

# Red Hat has SELinux switched on, which blocks services from running
# programs stored in /opt. This marks the Nexus start script as allowed.
chcon -R -t bin_t /opt/nexus/bin

# Create a service so Nexus starts automatically when the server reboots
cat > /etc/systemd/system/nexus.service <<'SVC'
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
SVC

# Start Nexus now and enable it on every boot
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus