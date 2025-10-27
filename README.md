# module "vcn" {

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

terraform {
required_version = ">= 1.5.0"
required_providers {
oci = {
source  = "hashicorp/oci"
version = "= 7.21.0"
}
random = {
source  = "hashicorp/random"
version = "~> 3.0"
}
docker = {
source  = "kreuzwerker/docker"
version = "3.0.2"
}
}
}

provider "oci" {
tenancy_ocid = var.tenancy_ocid
user_ocid    = var.user_ocid
fingerprint  = var.fingerprint
region       = var.region

# Use null instead of empty string so the provider won't try to read an empty path.

private_key      = var.private_key != "" ? var.private_key : null
private_key_path = var.private_key_path != "" ? var.private_key_path : null
}

provider "docker" {

# Default docker host is unix:///var/run/docker.sock (local Docker daemon)

# Configure here if you want to connect to a remote Docker

}

# Provider-level authentication variables

variable "tenancy_ocid" {
description = "The OCID of the tenancy"
type        = string
}

variable "user_ocid" {
description = "The OCID of the user"
type        = string
}

variable "fingerprint" {
description = "Fingerprint of the public key registered with OCI"
type        = string
}

variable "private_key" {
description = "OCI private key content"
type        = string
sensitive   = true
default     = ""
}

variable "private_key_path" {
description = "Path to the OCI private key file used for API authentication"
type        = string
default     = ""
}

variable "region" {
description = "OCI region"
type        = string
}

variable "compartment_id" {
description = "The OCID of the compartment where resources will be created"
type        = string
sensitive   = true
}

# --- Networking ---

variable "vcn_cidr" {
description = "CIDR block for the VCN"
type        = string
default     = "10.0.0.0/16"
}

variable "vcn_name" {
description = "Name of the VCN"
type        = string
default     = "my_vcn"
}

variable "subnet_cidr" {
description = "CIDR block for the subnet"
type        = string
default     = "10.0.1.0/24"
}

variable "subnet_name" {
description = "Name of the subnet"
type        = string
default     = "my_subnet"
}

variable "dns_label" {
description = "DNS label for the subnet"
type        = string
default     = "mydns"
}

variable "cidr_block" {
description = "The CIDR block for the VCN (legacy input, used in some modules)"
type        = string
default     = "10.0.0.0/16"
}

# --- Compute ---

variable "display_name" {
description = "Name of the instance"
type        = string
default     = "my_instance"
}

variable "image_ocid" {
description = "OCID of the image to use for the instance"
type        = string
}

variable "shape" {
description = "VM shape"
type        = string
default     = "VM.Standard.E2.1.Micro"
}

# --- Features ---

variable "enable_swarm" {
description = "When true, open Docker Swarm ingress ports and attach Swarm NSG"
type        = bool
default     = false
}

provide me a README.md for these

Here is a detailed and well-structured README.md suited for your Terraform configuration:

***

# OCI Terraform Infrastructure

This Terraform configuration provisions a Virtual Cloud Network (VCN), subnet, and compute instance on Oracle Cloud Infrastructure (OCI). It also supports optional configuration for Docker Swarm by attaching appropriate Network Security Groups (NSGs) and ports.

***

## Overview

The setup consists of two main modules:

- **`vcn` module** – Creates the networking layer (VCN, subnet, NSG).
- **`compute` module** – Provisions the compute instance within the VCN.

It also supports enabling Docker Swarm networking rules through the variable `enable_swarm`.

***

## Architecture Diagram

```
 ┌───────────────────────────────┐
 │          OCI Tenancy          │
 │   ┌───────────────────────┐   │
 │   │         VCN           │   │
 │   │   CIDR: 10.0.0.0/16   │   │
 │   │     ┌──────────────┐  │   │
 │   │     │   Subnet      │  │   │
 │   │     │ 10.0.1.0/24   │  │   │
 │   │     └─────┬────────┘  │   │
 │   │           │ Instance  │   │
 │   │           │ Shape: VM.Standard.E2.1.Micro
 │   │           │ Swarm: (Optional)
 │   │           └───────────────┘
 │   └───────────────────────┘   │
 └───────────────────────────────┘
```


***

## Prerequisites

Before using this configuration, ensure:

- Terraform version **1.5.0 or later**
- OCI CLI configured or access to the necessary OCIDs
- A valid OCI private key or local key file
- Correct OCIDs for tenancy, compartment, user, and image

***

## Variables

| Name | Description | Type | Default | Required |
| :-- | :-- | :-- | :-- | :-- |
| `tenancy_ocid` | OCID of your OCI tenancy | string | n/a | yes |
| `user_ocid` | OCID of your OCI user | string | n/a | yes |
| `fingerprint` | Fingerprint of your public key | string | n/a | yes |
| `private_key` | Private key content for API auth | string | `""` | optional |
| `private_key_path` | Path to private key file | string | `""` | optional |
| `region` | OCI region | string | n/a | yes |
| `compartment_id` | Compartment OCID | string | n/a | yes |
| `vcn_cidr` | CIDR for the VCN | string | `10.0.0.0/16` | no |
| `vcn_name` | Name of the VCN | string | `my_vcn` | no |
| `subnet_cidr` | CIDR for the subnet | string | `10.0.1.0/24` | no |
| `subnet_name` | Subnet name | string | `my_subnet` | no |
| `dns_label` | DNS label for subnet | string | `mydns` | no |
| `display_name` | Name of compute instance | string | `my_instance` | no |
| `image_ocid` | OCID of image for the instance | string | n/a | yes |
| `shape` | Instance shape | string | `VM.Standard.E2.1.Micro` | no |
| `enable_swarm` | Enable Docker Swarm networking | bool | `false` | no |


***

## Outputs

| Output Name | Description |
| :-- | :-- |
| `vcn_id` | ID of the created VCN |
| `subnet_id` | ID of the created subnet |
| `instance_id` | OCID of the compute instance |
| `instance_public_ip` | Public IP for SSH and access |
| `instance_private_ip` | Private IP used for internal communication (Ansible, clustering) |


***

## Usage

```bash
# Initialize Terraform modules and providers
terraform init

# Review planned resource creation
terraform plan

# Apply configuration to create resources
terraform apply

# (Optional) Destroy resources when finished
terraform destroy
```


***

## Enabling Docker Swarm Mode

To open Docker Swarm-related ports (5000, 2377, 7946, etc.) and attach the Swarm NSG automatically, set the following variable:

```bash
terraform apply -var="enable_swarm=true"
```

This will attach both SSH and Swarm NSGs to the compute instance through the `nsg_ids` configuration.

***

## File Structure

```
.
├── main.tf                   # Root Terraform configuration
├── variables.tf              # Declares input variables
├── outputs.tf                # Exposes resource outputs
├── modules/
│   ├── vcn/                  # Contains VCN, subnet, NSG definitions
│   └── compute/              # Contains instance provisioning logic
└── README.md
```


***

## Example Command

```bash
terraform apply \
  -var="tenancy_ocid=ocid1.tenancy.oc1..." \
  -var="user_ocid=ocid1.user.oc1..." \
  -var="fingerprint=aa:bb:cc:dd:ee" \
  -var="private_key_path=~/.oci/oci_api_key.pem" \
  -var="compartment_id=ocid1.compartment.oc1..." \
  -var="region=eu-frankfurt-1" \
  -var="image_ocid=ocid1.image.oc1.eu-frankfurt-1..." \
  -var="enable_swarm=true"
```


***
