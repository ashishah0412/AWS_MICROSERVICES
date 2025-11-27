resource "aws_ecs_service" "ui" {
  name            = "ui-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ui.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_tasks_sg_id]  # Add security group
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.ui_alb_tg_arn
    container_name   = "ui"
    container_port   = 8080  # Match container port
  }

  depends_on = [var.ui_alb_listener_arn]
}