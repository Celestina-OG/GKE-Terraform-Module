module "gke_cluster" {
  source = "./modules/gke_cluster"

  region                   = var.region
  clusterName              = var.clusterName
  diskSize                 = var.diskSize
  minNode                  = var.minNode
  maxNode                  = var.maxNode
  machineType              = var.machineType
  network_name             = module.vpc.network_name
  private_subnet_name      = module.vpc.private_subnet_name
}

module "vpc" {
  source = "./modules/vpc"

  region             = var.region
  project           = var.project_id
  env                = var.env
  company            = var.company
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_name        = var.private_name
  public_name         = var.public_name
}


