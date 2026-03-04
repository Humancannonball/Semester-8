# OpenTofu IaC Lab — Azure Virtual Machine

> **Laboratory Work 03** — Integrated Services Networks & Cloud Technologies (VilniusTech)

Deploy a Virtual Machine on Azure using Infrastructure as Code ([OpenTofu](https://opentofu.org/)). This project provisions a full networking stack (VNet, Subnet, NSG, Public IP, NIC) and a Linux VM with SSH access in the `swedencentral` region.

## Architecture

```
┌───────────────────── Resource Group: IaC_group ──────────────────────┐
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │                   Virtual Network (10.0.0.0/16)                 │  │
│  │  ┌──────────────────────────────────────────────────────────┐   │  │
│  │  │                  Subnet (10.0.1.0/24)                     │  │  │
│  │  │  ┌───────────────────────────────────────────────────┐    │  │  │
│  │  │  │              Network Interface (NIC)               │   │  │  │
│  │  │  │       Private IP (Dynamic) + Public IP (Static)    │   │  │  │
│  │  │  └────────────────────┬──────────────────────────────┘    │  │  │
│  │  └───────────────────────┼───────────────────────────────────┘  │  │
│  └──────────────────────────┼──────────────────────────────────────┘  │
│                             │                                         │
│  ┌──────────────────────────▼──────────────────────────────────────┐  │
│  │               Linux Virtual Machine (Standard_B1s)              │  │
│  │                   Ubuntu 22.04 LTS (Jammy)                      │  │
│  │                    SSH Access (Port 22)                          │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │            Network Security Group (NSG)                         │  │
│  │            Rule: Allow Inbound TCP/22 (SSH)                     │  │
│  │            Associated with NIC                                  │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  Tag: ENV = IaC                                                       │
└───────────────────────────────────────────────────────────────────────┘
                              │
                          Public IP
                              │
                              ▼
                       Internet / Users
                     (SSH on Port 22)
```

## Setup & Deployment

1. **Authenticate:** `az login`
2. **Initialize:** `tofu init`
3. **Preview:** `tofu plan`
4. **Deploy:** `tofu apply`
5. **Connect:** `ssh azureuser@<public_ip>` (see the `ssh_command` output)

## Cleanup

When finished with the lab, destroy all resources to avoid any potential charges:
```bash
tofu destroy
```
