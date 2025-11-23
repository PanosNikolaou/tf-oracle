# OCI Terraform Infrastructure

This Terraform configuration provisions a Virtual Cloud Network (VCN), subnet, and compute instance on Oracle Cloud Infrastructure (OCI). It also supports optional configuration for Docker Swarm by attaching appropriate Network Security Groups (NSGs) and ports.

---

## Overview

The setup consists of two main modules:

- **`vcn` module** – Creates the networking layer (VCN, subnet, NSG).
- **`compute` module** – Provisions the compute instance within the VCN.

It also supports enabling Docker Swarm networking rules through the variable `enable_swarm`.

---

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

---

## Prerequisites

Before using this configuration, ensure:

- Terraform version **1.5.0 or later**
- OCI CLI configured or access to the necessary OCIDs
- A valid OCI private key or local key file
- Correct OCIDs for tenancy, compartment, user, and image

---

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

---

## Outputs

| Output Name | Description |
| :-- | :-- |
| `vcn_id` | ID of the created VCN |
| `subnet_id` | ID of the created subnet |
| `instance_id` | OCID of the compute instance |
| `instance_public_ip` | Public IP for SSH and access |
| `instance_private_ip` | Private IP used for internal communication (Ansible, clustering) |

---

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

---

## Enabling Docker Swarm Mode

To open Docker Swarm-related ports (5000, 2377, 7946, etc.) and attach the Swarm NSG automatically, set the following variable:

```bash
terraform apply -var="enable_swarm=true"
```

This will attach both SSH and Swarm NSGs to the compute instance through the `nsg_ids` configuration.

---

## Security: Removing tfvars and Rewriting Git History

If a `*.tfvars` file containing secrets (API keys, private key paths, passwords) is accidentally committed and pushed, you **must remove it and rewrite Git history** to prevent credential exposure.

### 1. Remove tfvars from tracking

```bash
git rm --cached terraform.tfvars
```

Add to `.gitignore`:
```bash
echo "*.tfvars" >> .gitignore
echo "terraform.tfvars" >> .gitignore
```

Commit the change:
```bash
git add .gitignore
git commit -m "Remove tfvars and ignore sensitive files"
```

### 2. Rewrite Git history (purge secrets)

Install git-filter-repo:
```bash
pip install git-filter-repo
```

Then run:
```bash
git filter-repo --path terraform.tfvars --invert-paths --force
```

This completely removes the file from all Git history.

### 3. Re-add remote and force push

After history rewrite, re-add the remote:
```bash
git remote add origin https://github.com/<your-username>/<your-repo>.git
```

Then force push cleaned history:
```bash
git push --force --all origin
git push --force --tags origin
```

### 4. Rotate compromised credentials

Even after removal, assume secrets were exposed. Immediately rotate:
- OCI API Keys
- SSH Keys
- Database passwords
- Tokens or private keys

---

## Best Practices

- Never commit `.tfvars` files
- Use `.tfvars.example` as a template
- Store secrets in:
  - OCI Vault
  - Environment variables (`TF_VAR_...`)
  - Secret managers

Recommended `.gitignore` for Terraform:
```
*.tfvars
*.tfstate
*.tfstate.backup
.terraform/
.crash.log
override.tf
override.tf.json
```

---

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

---

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
