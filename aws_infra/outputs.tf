output "vpc_id" { value = module.network.vpc_id }
output "private_subnets" { value = module.network.private_subnets }
output "public_subnets" { value = module.network.public_subnets }
output "ecs_cluster_id" { value = module.ecs.cluster_id }
output "ui_alb_dns" { value = module.alb.ui_alb_dns }
output "ui_alb_url" { value = "https://${module.alb.ui_alb_dns}" }
output "rds_endpoint" { 
  value = try(module.rds.db_endpoint, "RDS not enabled")
}