resource "aws_lb" "vault" {
  name               = "vault-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.vault.id, aws_security_group.lb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "vault" {
  load_balancer_arn = aws_lb.vault.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = module.acm-cloudflare.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault.arn
  }
}

resource "aws_lb_listener" "vault-http" {
  load_balancer_arn = aws_lb.vault.arn
  port              = "80"
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

resource "aws_lb_target_group" "vault" {
  name     = "vault-tg"
  port     = 8200
  protocol = "HTTPS"
  vpc_id   = module.vpc.vpc_id

  health_check {
    protocol = "HTTPS"
    path     = "/v1/sys/health"
    matcher  = "200,429"
  }
  deregistration_delay = 60
}

resource "aws_autoscaling_attachment" "vault" {
  autoscaling_group_name = aws_autoscaling_group.vault.name
  lb_target_group_arn    = aws_lb_target_group.vault.arn
}
