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
