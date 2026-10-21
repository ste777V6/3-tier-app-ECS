module "security" {
  source = "./modules/security"

  name          = var.name
  vpc_id        = module.networking.vpc_id
  vpc_cidr      = var.vpc_cidr
  frontend_port = var.frontend_port
  backend_port  = var.backend_port
  db_port       = var.db_port
}
