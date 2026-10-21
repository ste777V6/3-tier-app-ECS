# Frontend tier: React app served by Node/Express, behind the public ALB.
# Express proxies /api/* to the backend over Service Connect.
module "frontend" {
  source = "./modules/ecs_service"

  name           = "${var.name}-frontend"
  container_name = "frontend"
  image          = var.frontend_image
  container_port = var.frontend_port
  cpu            = var.frontend_cpu
  memory         = var.frontend_memory

  environment = {
    PORT        = tostring(var.frontend_port)
    BACKEND_URL = module.backend.service_connect_url # http://backend:8000
  }

  cluster_id                    = module.ecs_cluster.cluster_id
  cluster_name                  = module.ecs_cluster.cluster_name
  subnet_ids                    = module.networking.private_subnet_ids
  security_group_ids            = [module.security.frontend_sg_id]
  service_connect_namespace_arn = module.ecs_cluster.service_connect_namespace_arn

  load_balancer = {
    target_group_arn = module.alb.blue_target_group_arn
    resource_label   = module.alb.blue_target_group_resource_label
  }

  desired_count   = var.frontend_desired_count
  autoscaling_min = var.frontend_autoscaling_min
  autoscaling_max = var.frontend_autoscaling_max
}
