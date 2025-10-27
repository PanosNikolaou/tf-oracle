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
