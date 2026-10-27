#!/bin/bash

mkdir -p /home/ec2-user/.ssh

cat > /home/ec2-user/.ssh/19thoct_private_key.pem <<'KEY'
${private_key}
KEY

chown ec2-user:ec2-user /home/ec2-user/.ssh/19thoct_private_key.pem

chmod 700 /home/ec2-user/.ssh
chmod 600 /home/ec2-user/.ssh/19thoct_private_key.pem