######################################
# UI ALB (Public-facing with HTTPS)
######################################

resource "aws_lb" "ui_alb" {
  name               = "ui-public-alb"
  internal           = false  # PUBLIC ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ui_alb_sg.id]
  subnets            = var.public_subnets  # Use public subnets

  enable_deletion_protection = false
  idle_timeout               = 60

  tags = {
    Name = "ui-public-alb"
  }
}

######################################
# Security Groups
######################################

resource "aws_security_group" "ui_alb_sg" {
  name        = "ui-alb-sg"
  description = "Security group for UI ALB - allow HTTP/HTTPS from internet"
  vpc_id      = var.vpc_id

  # HTTP - redirect to HTTPS
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # # HTTPS - allow from internet
  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ui-alb-sg"
  }
}

# ECS tasks security group (allow from ALB only)
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "ecs-tasks-sg"
  description = "Security group for ECS tasks - allow from ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.ui_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-tasks-sg"
  }
}

######################################
# Target Groups
######################################

resource "aws_lb_target_group" "ui_tg" {
  name        = "ui-tg"
  port        = 8080  # Match container port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "8080"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "ui-tg"
  }
}

######################################
# Listeners
######################################

# # HTTP listener - redirect to HTTPS
# resource "aws_lb_listener" "ui_http" {
#   load_balancer_arn = aws_lb.ui_alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

# HTTP listener to FORWARD traffic to Target group
resource "aws_lb_listener" "ui_http" {
  load_balancer_arn = aws_lb.ui_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ui_tg.arn
  }
}

# # HTTPS listener
# resource "aws_lb_listener" "ui_https" {
#   load_balancer_arn = aws_lb.ui_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
#   certificate_arn   = var.ui_cert_arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ui_tg.arn
#   }
# }
