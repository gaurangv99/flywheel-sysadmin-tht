resource "aws_lb" "employee_registry" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnets_ids

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "employee_registry" {
  vpc_id      = var.vpc_id
  name        = "${var.environment}-employee-registry-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
    matcher             = "200"
    port                = var.container_port
  }
}

resource "aws_lb_listener" "employee_registry" {
  load_balancer_arn = aws_lb.employee_registry.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.employee_registry.arn
  }
}
