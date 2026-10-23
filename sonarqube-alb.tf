# =========================================================
# Existing Route 53 public hosted zone
# =========================================================

data "aws_route53_zone" "everythingops" {
  name         = "everythingops.io."
  private_zone = false
}

# =========================================================
# HTTPS certificate — created in the provider's region
# =========================================================

resource "aws_acm_certificate" "sonarqube_19thoct" {
  domain_name       = "sonarqube.everythingops.io"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name    = "19thoct-sonarqube-certificate"
    Project = "19thoct"
  }
}

# Public DNS records proving domain ownership to ACM.
resource "aws_route53_record" "sonarqube_certificate_validation" {
  for_each = {
    for option in aws_acm_certificate.sonarqube_19thoct.domain_validation_options :
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

resource "aws_acm_certificate_validation" "sonarqube_19thoct" {
  certificate_arn = aws_acm_certificate.sonarqube_19thoct.arn

  validation_record_fqdns = [
    for record in aws_route53_record.sonarqube_certificate_validation :
    record.fqdn
  ]
}

# =========================================================
# Dedicated internal ALB security group
# =========================================================

resource "aws_security_group" "sonarqube_alb_19thoct" {
  name        = "19thoct-sonarqube-alb-sg"
  description = "Internal HTTPS access to SonarQube"
  vpc_id      = aws_vpc.vpc_19thoct.id

  ingress {
    description = "HTTPS from bastion and Jenkins"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    security_groups = [
      aws_security_group.bastion_sg_19thoct.id,
      aws_security_group.jenkins_sg_19thoct.id
    ]
  }

  egress {
    description     = "Application traffic and health checks to SonarQube"
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.sonarqube_sg_19thoct.id]
  }

  tags = {
    Name    = "19thoct-sonarqube-alb-sg"
    Project = "19thoct"
  }
}

# =========================================================
# Internal Application Load Balancer
# =========================================================

resource "aws_lb" "sonarqube_19thoct" {
  name               = "19thoct-sonarqube-alb"
  internal           = true
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.sonarqube_alb_19thoct.id
  ]

  subnets = [
    aws_subnet.private_subnet_1_19thoct.id,
    aws_subnet.private_subnet_2_19thoct.id
  ]

  drop_invalid_header_fields = true

  tags = {
    Name    = "19thoct-sonarqube-alb"
    Project = "19thoct"
  }
}

# =========================================================
# Target group — forwards requests to host port 9000
# =========================================================

resource "aws_lb_target_group" "sonarqube_19thoct" {
  name        = "19thoct-sonarqube-tg"
  port        = 9000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc_19thoct.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/api/system/status"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "19thoct-sonarqube-tg"
    Project = "19thoct"
  }
}

resource "aws_lb_target_group_attachment" "sonarqube_19thoct" {
  target_group_arn = aws_lb_target_group.sonarqube_19thoct.arn
  target_id        = aws_instance.sonarqube_19thoct.id
  port             = 9000
}

# =========================================================
# HTTPS listener — decrypts HTTPS and forwards HTTP internally
# =========================================================

resource "aws_lb_listener" "sonarqube_https_19thoct" {
  load_balancer_arn = aws_lb.sonarqube_19thoct.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  certificate_arn = aws_acm_certificate_validation.sonarqube_19thoct.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sonarqube_19thoct.arn
  }
}

# =========================================================
# Application DNS alias — still resolves to private addresses
# =========================================================

resource "aws_route53_record" "sonarqube_19thoct" {
  zone_id = data.aws_route53_zone.everythingops.zone_id
  name    = "sonarqube.everythingops.io"
  type    = "A"

  alias {
    name                   = aws_lb.sonarqube_19thoct.dns_name
    zone_id                = aws_lb.sonarqube_19thoct.zone_id
    evaluate_target_health = true
  }
}



