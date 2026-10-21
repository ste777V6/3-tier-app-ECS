# --- Networking -------------------------------------------------------------

output "vpc_id" {
  value = module.networking.vpc_id
}

output "nat_gateway_public_ips" {
  value = module.networking.nat_gateway_public_ips
}

# --- Load balancer ----------------------------------------------------------

output "load_balancer_dns_name" {
  description = "Point the app CNAME at your DNS provider to this"
  value       = module.alb.alb_dns_name
}

output "acm_validation_cname_name" {
  description = "Create this CNAME at the external DNS provider to validate the certificate"
  value       = module.alb.acm_validation_cname_name
}

output "acm_validation_cname_value" {
  value = module.alb.acm_validation_cname_value
}

output "target_group_names" {
  description = "Blue/green target groups (for the deployment pipeline)"
  value       = module.alb.target_group_names
}

# --- Application ------------------------------------------------------------

output "ecs_cluster_name" {
  value = module.ecs_cluster.cluster_name
}

output "frontend_ecr_repository_url" {
  value = module.frontend.ecr_repository_url
}

output "backend_ecr_repository_url" {
  value = module.backend.ecr_repository_url
}

output "frontend_service_name" {
  value = module.frontend.service_name
}

output "backend_service_name" {
  value = module.backend.service_name
}

output "frontend_task_definition_family" {
  value = module.frontend.task_definition_family
}

output "backend_task_definition_family" {
  value = module.backend.task_definition_family
}

output "backend_service_connect_url" {
  description = "Private URL the frontend uses to reach the backend"
  value       = module.backend.service_connect_url
}

# --- Database ---------------------------------------------------------------

output "db_address" {
  value = module.database.address
}

# --- Used by scripts/seed-db.ps1 (one-off tasks) ----------------------------

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "backend_sg_id" {
  value = module.security.backend_sg_id
}
