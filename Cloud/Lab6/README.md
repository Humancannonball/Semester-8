# OpenTofu VPN Lab — Azure Site-to-Site Between Two VNets

> **Laboratory Work 06** — Integrated Services Networks and Cloud Technologies (VilniusTech)

This lab simulates a site-to-site VPN connection between two separate Azure environments in different regions. Instead of configuring everything manually in the Azure portal, the network topology is provisioned with OpenTofu/Terraform and verified with Azure CLI commands.

Azure currently requires `VpnGw1AZ` for new deployments instead of the older `VpnGw1` SKU mentioned in some lab materials, so the automation uses the current supported gateway SKU.

## What Is Automated

- Two Azure resource groups in different regions
- Two virtual networks with non-overlapping address spaces
- Two `GatewaySubnet` subnets
- Two VPN gateways
- Two local network gateways pointing to the remote side
- Two site-to-site IPsec VPN connections using the same pre-shared key
- Two private-only Linux virtual machines
- VM bootstrapping for network diagnostics and ICMP testing

## Verification Approach

Because the lab requires private-only VMs, connectivity is verified with Azure Run Command instead of public SSH access. This allows end-to-end testing without assigning public VM IP addresses.

After `apply`, evidence can be collected with:

```bash
./scripts/collect-evidence.sh
```

## Cleanup

```bash
terraform destroy -auto-approve
```
