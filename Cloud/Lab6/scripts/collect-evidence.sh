#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

site_a_rg="$(terraform output -raw site_a_resource_group_name 2>/dev/null || true)"
site_b_rg="$(terraform output -raw site_b_resource_group_name 2>/dev/null || true)"

if [[ -z "${site_a_rg}" || -z "${site_b_rg}" ]]; then
  site_a_rg="VPN_site_a_group_lab6"
  site_b_rg="VPN_site_b_group_lab6"
fi

site_a_vm="mark-vpn-a-vm"
site_b_vm="mark-vpn-b-vm"
site_a_conn="$(terraform output -raw site_a_connection_name)"
site_b_conn="$(terraform output -raw site_b_connection_name)"
site_a_ip="$(terraform output -raw site_a_vm_private_ip)"
site_b_ip="$(terraform output -raw site_b_vm_private_ip)"

echo "== Terraform Outputs =="
terraform output
echo

echo "== VPN Connection Status =="
az network vpn-connection show \
  -g "$site_a_rg" \
  -n "$site_a_conn" \
  --query '{name:name,status:connectionStatus,ingress:ingressBytesTransferred,egress:egressBytesTransferred}' \
  -o json
az network vpn-connection show \
  -g "$site_b_rg" \
  -n "$site_b_conn" \
  --query '{name:name,status:connectionStatus,ingress:ingressBytesTransferred,egress:egressBytesTransferred}' \
  -o json
echo

echo "== Ping From Site A VM To Site B VM =="
az vm run-command invoke \
  -g "$site_a_rg" \
  -n "$site_a_vm" \
  --command-id RunShellScript \
  --scripts "ping -c 4 $site_b_ip"
echo

echo "== Ping From Site B VM To Site A VM =="
az vm run-command invoke \
  -g "$site_b_rg" \
  -n "$site_b_vm" \
  --command-id RunShellScript \
  --scripts "ping -c 4 $site_a_ip"
