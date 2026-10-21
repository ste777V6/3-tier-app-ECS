# Backend tier: Flask API. Private only: no load balancer, reachable from
# the frontend through Service Connect at http://backend:<backend_port>.
module "backend" {
  source = "./modules/ecs_service"

  name           = "${var.name}-backend"
  container_name = "backend"
  image          = var.backend_image
  container_port = var.backend_port
  cpu            = var.backend_cpu
  memory         = var.backend_memory

  # Apply database migrations (idempotent), then start the API
  command = [
    "sh", "-c",
    "flask db upgrade && exec gunicorn --bind 0.0.0.0:${var.backend_port} --workers 2 --access-logfile - run:app"
  ]

  environment = {
    FLASK_APP = "run.py"
  }

  # The secret holds the full postgresql:// connection string, which is
  # exactly what the app reads from DATABASE_URL
  secrets = {
    DATABASE_URL = module.database.secret_arn
  }

  cluster_id                    = module.ecs_cluster.cluster_id
  cluster_name                  = module.ecs_cluster.cluster_name
  subnet_ids                    = module.networking.private_subnet_ids
  security_group_ids            = [module.security.backend_sg_id]
  service_connect_namespace_arn = module.ecs_cluster.service_connect_namespace_arn

  # Publish as "backend" in the namespace
  service_connect = {
    dns_name = "backend"
  }

  desired_count   = var.backend_desired_count
  autoscaling_min = var.backend_autoscaling_min
  autoscaling_max = var.backend_autoscaling_max
}
