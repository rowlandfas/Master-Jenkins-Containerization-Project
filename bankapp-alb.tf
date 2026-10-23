# =========================================================
# BankApp public entry point (Kenneth)
# Route 53 record -> public ALB -> Docker hosts on port 8080
#
# Uses the existing everythingops.io hosted zone, looked up in
# sonarqube-alb.tf as data.aws_route53_zone.everythingops
# =========================================================

locals {
  bankapp_domain = "${var.app_subdomain}.everythingops.io"
}

# HTTPS uses the project's shared certificate (everythingops.io and
# *.everythingops.io), defined in main.tf as aws_acm_certificate.bankapp_ssl

# =========================================================
# Public Application Load Balancer
# =========================================================

resource "aws_lb" "bankapp_19thoct" {
  name               = "19thoct-bankapp-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb_19thoct.id]

  # Public subnets in both availability zones
  subnets = [
    aws_subnet.public_subnet_1_19thoct.id,
    aws_subnet.public_subnet_2_19thoct.id
  ]

  drop_invalid_header_fields = true

  tags = {
    Name    = "19thoct-bankapp-alb"
    Project = "19thoct"
  }
}

# =========================================================
# Target group: the Docker hosts on port 8080
# =========================================================

resource "aws_lb_target_group" "bankapp_19thoct" {
  name        = "19thoct-bankapp-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc_19thoct.id

  # Give in-flight requests 30 seconds to finish when a host is removed
  deregistration_delay = 30

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = var.app_health_check_path
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "19thoct-bankapp-tg"
    Project = "19thoct"
  }
}

# Every Docker host the auto scaling group launches joins the target group
resource "aws_autoscaling_attachment" "bankapp_19thoct" {
  autoscaling_group_name = aws_autoscaling_group.docker_hosts_asg_19thoct.name
  lb_target_group_arn    = aws_lb_target_group.bankapp_19thoct.arn
}

# =========================================================
# Listeners
# =========================================================

# HTTP: redirect every request to HTTPS
resource "aws_lb_listener" "bankapp_http_19thoct" {
  load_balancer_arn = aws_lb.bankapp_19thoct.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS: decrypt with the shared ACM certificate and forward to the Docker hosts
resource "aws_lb_listener" "bankapp_https_19thoct" {
  load_balancer_arn = aws_lb.bankapp_19thoct.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  certificate_arn = aws_acm_certificate_validation.bankapp_ssl_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bankapp_19thoct.arn
  }
}

# =========================================================
# Route 53 alias record: the BankApp domain -> the ALB
# =========================================================

resource "aws_route53_record" "bankapp_19thoct" {
  zone_id = data.aws_route53_zone.everythingops.zone_id
  name    = local.bankapp_domain
  type    = "A"

  alias {
    name                   = aws_lb.bankapp_19thoct.dns_name
    zone_id                = aws_lb.bankapp_19thoct.zone_id
    evaluate_target_health = true
  }
}
