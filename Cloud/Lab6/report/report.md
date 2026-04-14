---
title: "Laboratory Work 06 — Site-to-Site VPN on Azure"
subtitle: "Integrated Services Networks and Cloud Technologies"
author: "Mark"
date: "2026-04-14"
---

# Objective

The objective of this laboratory work was to simulate a **site-to-site VPN** connection between two Azure virtual networks in different regions and to verify private connectivity between virtual machines over an **IPsec/IKEv2** tunnel.

> **Note:** The original lab instructions describe carrying out the work in the Azure portal. In this implementation, the same environment was created with **OpenTofu/Terraform** and verified with **Azure CLI** so that the whole lab could be reproduced automatically.

# 1. Infrastructure Deployment

Two independent Azure environments were created in different regions:

| Site | Resource Group | Region | Address Space |
|---|---|---|---|
| Site A | `VPN_site_a_group_lab6` | `swedencentral` | `10.60.0.0/16` |
| Site B | `VPN_site_b_group_lab6` | `italynorth` | `10.70.0.0/16` |

Each site contains:

- one virtual network;
- one `GatewaySubnet`;
- one Linux virtual machine without a public IP;
- one public IP for the VPN gateway;
- one local network gateway describing the remote site;
- one virtual network gateway;
- one site-to-site VPN connection.

Subnet layout:

| Site | VM Subnet | Gateway Subnet |
|---|---|---|
| Site A | `10.60.1.0/24` | `10.60.255.0/27` |
| Site B | `10.70.1.0/24` | `10.70.255.0/27` |

Important implementation details:

- VPN gateway type: **Route-based**
- Connection type: **Site-to-site (IPsec)**
- IKE version: **IKEv2**
- Active-active mode: **disabled**
- Shared key: the same pre-shared key was configured on both connections
- VM public IPs: **not created**

Platform note:

- The lab sheet suggests `VpnGw1`, but Azure currently requires the **AZ variant** for new deployments in these regions. Therefore `VpnGw1AZ` was used.
- The gateway public IPs were created as **Standard zone-redundant** public IPs because Azure requires zone-aware public IP configuration for AZ VPN gateway SKUs.

# 2. Work Progress

## 2.1 Resource Groups and Virtual Networks

Two resource groups were created in different regions:

- `VPN_site_a_group_lab6` in `swedencentral`
- `VPN_site_b_group_lab6` in `italynorth`

Inside them, two virtual networks were deployed:

- `mark-vpn-a-vnet`
- `mark-vpn-b-vnet`

This satisfied the lab requirement to simulate two different cloud sites with separate address spaces.

## 2.2 Gateway Subnets

Each virtual network contains a dedicated `GatewaySubnet`, which is required before a virtual network gateway can be attached:

- Site A: `10.60.255.0/27`
- Site B: `10.70.255.0/27`

## 2.3 Virtual Machines

Two Ubuntu 22.04 LTS virtual machines were created:

- `mark-vpn-a-vm`
- `mark-vpn-b-vm`

The VMs were attached only to the internal subnets and **no public IP addresses** were assigned to them, exactly as required by the task.

To support the connectivity checks inside the guest OS, cloud-init installed:

- `iputils-ping`
- `traceroute`
- `net-tools`
- `dnsutils`
- `curl`

## 2.4 VPN Gateways and Local Network Gateways

Each site received:

- one Azure virtual network gateway;
- one local network gateway describing the remote site.

The local network gateway objects were configured with:

- the remote VPN gateway public IP address;
- the remote virtual network address space.

## 2.5 Site-to-Site Connections

Two connections were created:

- `mark-vpn-a-to-b`
- `mark-vpn-b-to-a`

Configured settings:

- type: `IPsec`
- protocol: `IKEv2`
- shared key: identical on both sides

This matches the lab instruction to build the tunnel from both sites and use the same pre-shared key.

## 2.6 Verification Results

The following runtime checks were performed after deployment:

1. VPN connection status was checked from Azure.
2. Connectivity between the two VMs was tested using their **private IP addresses**.
3. Logs and metrics were collected from Azure resources.

Observed deployment values:

- Site A gateway public IP: `4.225.133.180`
- Site B gateway public IP: `72.146.240.111`
- Site A VM private IP: `10.60.1.4`
- Site B VM private IP: `10.70.1.4`

Observed connection status:

- Site A connection: `Connected`
- Site B connection: `Connected`

Observed VM-to-VM connectivity:

```text
Site A VM -> Site B VM:
4 packets transmitted, 4 received, 0% packet loss
rtt min/avg/max/mdev = 38.271/62.338/107.478/27.999 ms

Site B VM -> Site A VM:
4 packets transmitted, 4 received, 0% packet loss
rtt min/avg/max/mdev = 36.230/41.107/46.582/4.301 ms
```

Observed monitoring details:

```text
VPN connections:
- mark-vpn-a-to-b -> Connected, ingress 672 B, egress 672 B
- mark-vpn-b-to-a -> Connected, ingress 672 B, egress 672 B

Azure Monitor metrics on mark-vpn-a-gateway (5-minute grain):
- TunnelIngressBytes: 672 B at 2026-04-14T08:10:00Z
- TunnelEgressBytes: 672 B at 2026-04-14T08:10:00Z
- TunnelAverageBandwidth: 4 B/s at 2026-04-14T08:10:00Z

Activity log sample:
- Microsoft.Network/connections/write -> Succeeded at 2026-04-14T08:10:44.2101892Z
```

## 2.7 Cleanup

After verification, cleanup was initiated for all VPN lab resource groups:

```bash
az group delete -n VPN_site_a_group --yes --no-wait
az group delete -n VPN_site_a_group_lab6 --yes --no-wait
az group delete -n VPN_site_b_group_lab6 --yes --no-wait
```

Final Azure cleanup status:

```text
Cleanup completed successfully.
Verified at 2026-04-14T08:40:58Z:
- Resource groups remaining in the subscription: 0
- Resources remaining in the subscription: 0
```

# 3. Answers to the Questions

## 3.1 Purpose of a Site-to-Site VPN Gateway

A site-to-site VPN gateway in Azure creates an encrypted tunnel between two separate networks. This allows organizations to securely connect branch offices, datacenters, or isolated cloud networks over the public internet without exposing internal traffic directly. The main benefits are secure communication, reduced need for public exposure, and the ability to extend private network addressing across different environments.

## 3.2 Key Components Needed for a Site-to-Site VPN

The main components are:

- a virtual network on each side;
- a `GatewaySubnet` in each Azure VNet;
- a virtual network gateway;
- a local network gateway describing the remote site;
- a site-to-site VPN connection object;
- a shared key used by both peers;
- compatible addressing so the routes for both networks are known.

## 3.3 Why a Virtual Network Is Required First

The virtual network is the logical network boundary that the VPN gateway attaches to. Without a VNet, Azure has nowhere to route private traffic and no address space to advertise across the tunnel. The VPN gateway does not exist independently; it is deployed into a specific virtual network through the `GatewaySubnet`.

## 3.4 Types of Azure VPN Gateways

Azure VPN deployments are usually discussed in terms of two routing models:

- **Route-based VPN gateways** use routes in the IP forwarding table and are the recommended choice for most modern Azure VPN scenarios, including site-to-site tunnels.
- **Policy-based VPN gateways** match traffic with static traffic selectors and are more limited in features and interoperability.

In practice, Azure also offers different gateway SKUs and availability options, such as standard and zone-aware variants. The SKU determines performance, throughput, tunnel limits, and resiliency characteristics.

## 3.5 Role of the Shared Key

The shared key is a secret value known to both VPN peers. During tunnel establishment, it is used as part of the authentication and key-exchange process so that both sides can prove they are authorized to form the connection. If the shared keys do not match, the VPN tunnel will not establish successfully.

## 3.6 Troubleshooting Steps if the VPN Does Not Establish

If a site-to-site VPN connection fails, the main troubleshooting steps are:

- verify that both gateways are fully provisioned;
- check that both local network gateways point to the correct remote public IP and remote address space;
- confirm that the same shared key is configured on both sides;
- confirm that the VPN type and IKE settings match on both sides;
- review connection status and logs in Azure;
- confirm that the address spaces do not overlap;
- verify that NSG rules or guest OS firewalls are not blocking the required traffic.

Common issues include:

- incorrect public IP address for the remote side;
- mismatched shared key;
- overlapping IP ranges;
- unsupported VPN/IKE settings;
- incomplete gateway deployment;
- guest firewall or NSG rules blocking ICMP or application traffic.

## 3.7 Monitoring Performance and Health

Azure VPN connectivity can be monitored by checking:

- connection state in the virtual network gateway;
- Azure Monitor metrics for the VPN gateway or connection;
- diagnostic logs and resource-level activity;
- guest-side connectivity tests such as `ping` and route checks.

Useful indicators include:

- tunnel connection state;
- bytes in/out;
- tunnel ingress and egress traffic;
- failed connection attempts or gateway errors;
- guest OS ping results between private IP addresses.

# 4. Conclusion

This lab successfully demonstrated how to connect two isolated Azure virtual networks through a secure site-to-site VPN tunnel. The whole environment was deployed with Infrastructure as Code instead of manual portal steps, while still following the required architecture: two regions, two VNets, two gateways, two private-only VMs, and two IPsec/IKEv2 connections. After deployment, the tunnel status, VM-to-VM private connectivity, and monitoring data were verified. The cleanup phase was completed as well, leaving `0` resource groups and `0` resources in the subscription.
