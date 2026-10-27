#!/bin/bash

cd /home/ec2-user/.ssh

cat > /home/ec2-user/.ssh/id_rsa <<'KEY'
${private_key}
KEY

chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa

chmod 700 /home/ec2-user/.ssh
chmod 600 /home/ec2-user/.ssh/id_rsa