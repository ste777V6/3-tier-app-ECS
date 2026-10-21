module "ecs_cluster" {
  source = "./modules/ecs_cluster"

  name = var.name
}
