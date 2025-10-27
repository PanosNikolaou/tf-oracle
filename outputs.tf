output "vcn_id" {
  value = module.vcn.vcn_id
}

output "subnet_id" {
  value = module.vcn.subnet_id
}

output "instance_id" {
  value = module.compute.instance_id
}

output "instance_public_ip" {
  value = module.compute.instance_public_ip
}

# Expose private IP from compute module for internal usage (Ansible, clustering)
output "instance_private_ip" {
  value = module.compute.instance_private_ip
}
