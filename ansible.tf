# ===============================================
# Ansible Server (public subnet 2)
# Installs Ansible and Docker, and writes the playbooks
# ===============================================
resource "aws_instance" "ansible_19thoct" {
  ami                         = data.aws_ami.redhat_19thoct.id
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public_subnet_2_19thoct.id
  vpc_security_group_ids      = [aws_security_group.ansible_sg_19thoct.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_pair_19thoct.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y ansible-core git python3-pip
    curl -fsSL https://download.docker.com/linux/rhel/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
    dnf install -y docker-ce docker-ce-cli containerd.io
    pip3 install docker
    systemctl enable --now docker
    hostnamectl set-hostname ansible-19thoct
    echo "preserve_hostname: true" > /etc/cloud/cloud.cfg.d/99_hostname.cfg

    mkdir -p /home/ec2-user/ansible /opt/19thoct/build
    sudo -u ec2-user ansible-galaxy collection install community.docker

    # CT-6: the Dockerfile from this repo
    cat > /opt/19thoct/build/Dockerfile <<'DOCKERFILE'
    ${file("${path.module}/docker/Dockerfile")}
    DOCKERFILE

    # Playbook 1: install Docker on the Docker hosts
    cat > /home/ec2-user/ansible/docker-setup.yml <<'PLAY'
    - name: Prepare Docker hosts
      hosts: all
      remote_user: ec2-user
      become: true
      tasks:
        - name: Add Docker repository
          ansible.builtin.get_url:
            url: https://download.docker.com/linux/rhel/docker-ce.repo
            dest: /etc/yum.repos.d/docker-ce.repo

        - name: Install Docker and pip
          ansible.builtin.dnf:
            name: [docker-ce, docker-ce-cli, containerd.io, python3-pip]
            state: present

        - name: Install Docker SDK for Python
          ansible.builtin.pip:
            name: docker
            state: present

        - name: Start and enable Docker
          ansible.builtin.service:
            name: docker
            state: started
            enabled: true

        - name: Let ec2-user use Docker
          ansible.builtin.user:
            name: ec2-user
            groups: docker
            append: true
    PLAY

    # Playbook 2 (CT-7): build the image and push it to Docker Hub
    cat > /home/ec2-user/ansible/build-image.yml <<'PLAY'
    - name: Build and push 19thoct image
      hosts: localhost
      connection: local
      become: true
      vars:
        dockerhub_username: "YOUR_DOCKERHUB_USER"
        image_tag: "latest"
        nexus_jar_url: "http://NEXUS-PRIVATE-IP:8081/repository/maven-releases/PATH/TO/19thoct.jar"
      vars_prompt:
        - name: nexus_user
          prompt: "Nexus username"
          private: false
        - name: nexus_password
          prompt: "Nexus password"
        - name: dockerhub_token
          prompt: "Docker Hub access token"
      tasks:
        - name: Download the app jar from Nexus
          ansible.builtin.get_url:
            url: "{{ nexus_jar_url }}"
            dest: /opt/19thoct/build/app.jar
            url_username: "{{ nexus_user }}"
            url_password: "{{ nexus_password }}"
            force: true
          no_log: true

        - name: Log in to Docker Hub
          community.docker.docker_login:
            username: "{{ dockerhub_username }}"
            password: "{{ dockerhub_token }}"
          no_log: true

        - name: Build and push the image
          community.docker.docker_image:
            name: "{{ dockerhub_username }}/19thoct"
            tag: "{{ image_tag }}"
            source: build
            build:
              path: /opt/19thoct/build
            push: true
    PLAY

    # Playbook 3 (CT-8): run the container on the Docker hosts
    cat > /home/ec2-user/ansible/deploy-container.yml <<'PLAY'
    - name: Deploy 19thoct Container
      hosts: all
      remote_user: ec2-user
      become: true
      vars:
        dockerhub_username: "YOUR_DOCKERHUB_USER"
        image_tag: "latest"
        app_port: 8080
        rds_endpoint: "YOUR-RDS-ENDPOINT"
        db_name: "19thoctdb"
      vars_prompt:
        - name: dockerhub_token
          prompt: "Docker Hub access token"
        - name: db_user
          prompt: "Database username"
          private: false
        - name: db_password
          prompt: "Database password"
      tasks:
        - name: Log in to Docker Hub
          community.docker.docker_login:
            username: "{{ dockerhub_username }}"
            password: "{{ dockerhub_token }}"
          no_log: true

        - name: Pull the image from Docker Hub
          community.docker.docker_image:
            name: "{{ dockerhub_username }}/19thoct"
            tag: "{{ image_tag }}"
            source: pull
            force_source: true

        - name: Run the 19thoct container
          community.docker.docker_container:
            name: 19thoct
            image: "{{ dockerhub_username }}/19thoct:{{ image_tag }}"
            state: started
            restart_policy: unless-stopped
            ports:
              - "{{ app_port }}:8080"
            env:
              SPRING_DATASOURCE_URL: "jdbc:mysql://{{ rds_endpoint }}:3306/{{ db_name }}"
              SPRING_DATASOURCE_USERNAME: "{{ db_user }}"
              SPRING_DATASOURCE_PASSWORD: "{{ db_password }}"
          no_log: true

        - name: Wait for the app port
          ansible.builtin.wait_for:
            port: "{{ app_port }}"
            timeout: 60
    PLAY

    chown -R ec2-user:ec2-user /home/ec2-user/ansible
  EOF

  tags = {
    Name    = "19thoct-ansible"
    Project = "19thoct"
  }
}

