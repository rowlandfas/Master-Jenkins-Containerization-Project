# =========================================================
# Jenkins HTTPS certificate
# =========================================================

resource "aws_acm_certificate" "jenkins_19thoct" {
  domain_name       = "jenkins.everythingops.io"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name    = "19thoct-jenkins-certificate"
    Project = "19thoct"
  }
}

# DNS records proving domain ownership to ACM.
resource "aws_route53_record" "jenkins_certificate_validation" {
  for_each = {
    for option in aws_acm_certificate.jenkins_19thoct.domain_validation_options :
    option.domain_name => {
      name  = option.resource_record_name
      type  = option.resource_record_type
      value = option.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.everythingops.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "jenkins_19thoct" {
  certificate_arn = aws_acm_certificate.jenkins_19thoct.arn

  validation_record_fqdns = [
    for record in aws_route53_record.jenkins_certificate_validation :
    record.fqdn
  ]
}

# =========================================================
# Dedicated public ALB security group
# =========================================================

resource "aws_security_group" "jenkins_alb_19thoct" {
  name        = "19thoct-jenkins-alb-sg"
  description = "Public HTTPS access to Jenkins"
  vpc_id      = aws_vpc.vpc_19thoct.id

  ingress {
    description = "HTTPS access to Jenkins"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Application traffic and health checks to Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc_19thoct.cidr_block]
  }

  tags = {
    Name    = "19thoct-jenkins-alb-sg"
    Project = "19thoct"
  }
}

# =========================================================
# Public Application Load Balancer
# =========================================================

resource "aws_lb" "jenkins_19thoct" {
  name               = "19thoct-jenkins-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.jenkins_alb_19thoct.id
  ]

  subnets = [
    aws_subnet.public_subnet_1_19thoct.id,
    aws_subnet.public_subnet_2_19thoct.id
  ]

  idle_timeout               = 300
  drop_invalid_header_fields = true

  depends_on = [
    aws_route_table_association.public_rta_1_19thoct,
    aws_route_table_association.public_rta_2_19thoct
  ]

  tags = {
    Name    = "19thoct-jenkins-alb"
    Project = "19thoct"
  }
}

# =========================================================
# Target group — forwards requests to Jenkins port 8080
# =========================================================

resource "aws_lb_target_group" "jenkins_19thoct" {
  name        = "19thoct-jenkins-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc_19thoct.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/login"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "19thoct-jenkins-tg"
    Project = "19thoct"
  }
}

resource "aws_lb_target_group_attachment" "jenkins_19thoct" {
  target_group_arn = aws_lb_target_group.jenkins_19thoct.arn
  target_id        = aws_instance.jenkins_19thoct.id
  port             = 8080
}

# =========================================================
# HTTPS listener — decrypts HTTPS and forwards HTTP internally
# =========================================================

resource "aws_lb_listener" "jenkins_https_19thoct" {
  load_balancer_arn = aws_lb.jenkins_19thoct.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  certificate_arn = aws_acm_certificate_validation.jenkins_19thoct.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_19thoct.arn
  }
}

# =========================================================
# Jenkins application DNS record
# =========================================================

resource "aws_route53_record" "jenkins_19thoct" {
  zone_id = data.aws_route53_zone.everythingops.zone_id
  name    = "jenkins.everythingops.io"
  type    = "A"

  alias {
    name                   = aws_lb.jenkins_19thoct.dns_name
    zone_id                = aws_lb.jenkins_19thoct.zone_id
    evaluate_target_health = true
  }
}