module "vcn" {
  source         = "./modules/vcn"
  cidr_block     = var.vcn_cidr
  display_name   = var.vcn_name
  subnet_cidr    = var.subnet_cidr
  subnet_name    = var.subnet_name
  dns_label      = var.dns_label
  compartment_id = var.compartment_id
  enable_swarm   = var.enable_swarm
}

module "compute" {
  source         = "./modules/compute"
  compartment_id = var.compartment_id
  subnet_id      = module.vcn.subnet_id
  display_name   = var.display_name
  image_ocid     = var.image_ocid
  shape          = var.shape
  region         = var.region
  nsg_ids        = var.enable_swarm ? [module.vcn.ssh_nsg_id, module.vcn.swarm_nsg_id] : [module.vcn.ssh_nsg_id]
  enable_swarm   = var.enable_swarm
}
