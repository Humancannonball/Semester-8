# OpenTofu IaaS Lab — Azure Virtual Machine

> **Laboratory Work 01** — Integrated Services Networks & Cloud Technologies (VilniusTech)

Deploy a single Ubuntu 22.04 VM on Azure with Nginx, UFW firewall, and a custom landing page — all defined as Infrastructure as Code using [OpenTofu](https://opentofu.org/).

## Architecture

```
Internet
   │
   ▼
┌──────────────────── Resource Group: IaaS_group ─────────────────────┐
│                                                                      │
│  Public IP (pip-iaas)  ──▶  NIC (nic-iaas)  ──▶  VM (vm-iaas)      │
│       + DNS label            │                   Ubuntu 22.04        │
│                              │                   Standard_B1s        │
│                              ▼                   cloud-init:         │
│                       Subnet 10.0.1.0/24           • Nginx           │
│                       VNet   10.0.0.0/16           • UFW             │
│                              │                     • index.html      │
│                              ▼                                       │
│                       NSG (nsg-iaas)                                  │
│                        Allow: 22, 80                                 │
│                                                                      │
│  Tag: ENV = IaaS                                                     │
└──────────────────────────────────────────────────────────────────────┘
```

## Prerequisites

| Tool | Purpose |
|------|---------|
| [OpenTofu](https://opentofu.org/docs/intro/install/) ≥ 1.6 | IaC engine |
| [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) | Authentication |
| SSH client | Connect to the VM |

## Project Structure

```
tofu-lab/
├── versions.tf          # Required OpenTofu & provider versions
├── providers.tf         # Azure provider configuration
├── variables.tf         # Input variables (region, VM size, credentials)
├── resource_group.tf    # Resource Group
├── network.tf           # VNet, Subnet, Public IP, NSG, associations
├── compute.tf           # NIC, SSH key, VM (Ubuntu 22.04)
├── outputs.tf           # Useful post-deploy outputs (IP, DNS, SSH cmd)
├── cloud-init.yaml      # First-boot script (Nginx + UFW + HTML page)
└── .gitignore           # Excludes secrets & state from version control
```

## Quick Start

### 1. Authenticate with Azure

```bash
az login
```

### 2. Initialize OpenTofu

```bash
tofu init
```

### 3. Review the plan

```bash
tofu plan -var 'admin_password=YourSecurePassword123!'
```

### 4. Deploy

```bash
tofu apply -var 'admin_password=YourSecurePassword123!'
```

> **Tip:** To avoid typing the password each time, create a `terraform.tfvars` file:
> ```hcl
> admin_password = "YourSecurePassword123!"
> ```
> This file is already in `.gitignore` and won't be committed.

### 5. Connect

```bash
# SSH with the generated key
ssh -i id_rsa azureuser@<DNS_NAME>

# Or SSH with password
ssh azureuser@<DNS_NAME>
```

### 6. Visit your site

Open `http://<DNS_NAME>` in a browser to see the Nginx landing page.

### 7. Cleanup (when done)

```bash
tofu destroy -var 'admin_password=YourSecurePassword123!'
```

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Resource** | A single piece of infrastructure (e.g., `azurerm_virtual_network`) |
| **Variable** | Input parameter that makes the config reusable |
| **Output** | Value shown after deployment (IP address, DNS name, etc.) |
| **State** | `terraform.tfstate` — maps your code to real Azure resources. **Never delete manually!** |
| **Cloud-init** | Script that runs once on first VM boot to install packages and configure the system |

## Customisation

| What | Where | Default |
|------|-------|---------|
| Azure region | `variables.tf` → `location` | `swedencentral` |
| VM size | `variables.tf` → `vm_size` | `Standard_B1s` |
| DNS label | `variables.tf` → `domain_name_label` | `mark-iaas` |
| Landing page | `cloud-init.yaml` | VilniusTech styled page |

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| **403 RequestDisallowedByAzure** | Region not allowed by subscription policy | Change `location` in `variables.tf` to an allowed region |
| **AuthorizationFailed** | Insufficient permissions | Run `az login` again; verify subscription |
| **PublicIPAddressCannotBeDeleted** | Resource still in use | Run `tofu destroy` to remove all resources in order |
| **DNS label already taken** | Global uniqueness conflict | Change `domain_name_label` in `variables.tf` |
