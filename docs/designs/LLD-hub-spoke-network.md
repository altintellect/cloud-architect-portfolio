# Low Level Design: Hub-Spoke Network

**Document Type:** Low Level Design (LLD)
**Version:** 1.0
**Date:** 2026-04-02
**Status:** Approved
**Author:** Senior Cloud Architect
**Reviewed By:** Architecture Review Board
**Parent Document:** HLD-azure-landing-zone.md

---

## 1. Purpose

This Low Level Design provides detailed technical specifications for the
hub-spoke network architecture deployed across the Azure Landing Zone.
It covers exact subnet ranges, NSG rules, routing tables, firewall policies,
DNS configuration, and Private Endpoint design.

---

## 2. Network Address Plan

### 2.1 VNet Address Spaces

| VNet | Address Space | Region | Subscription |
|---|---|---|---|
| vnet-hub-prod | 10.0.0.0/16 | Canada Central | sub-connectivity |
| vnet-hub-dr | 10.10.0.0/16 | Canada East | sub-connectivity |
| vnet-spoke-corp-prod | 10.1.0.0/16 | Canada Central | sub-corp-prod |
| vnet-spoke-corp-nonprod | 10.2.0.0/16 | Canada Central | sub-corp-nonprod |
| vnet-spoke-online-prod | 10.3.0.0/16 | Canada Central | sub-online-prod |
| vnet-spoke-data-prod | 10.4.0.0/16 | Canada Central | sub-data-prod |
| vnet-spoke-aks-prod | 10.5.0.0/16 | Canada Central | sub-corp-prod |

### 2.2 Hub VNet Subnets (vnet-hub-prod 10.0.0.0/16)

| Subnet | CIDR | Purpose | NSG |
|---|---|---|---|
| GatewaySubnet | 10.0.0.0/27 | VPN/ExpressRoute Gateway | None (required) |
| AzureFirewallSubnet | 10.0.1.0/26 | Azure Firewall Premium | None (required) |
| AzureFirewallManagementSubnet | 10.0.1.64/26 | Firewall management | None (required) |
| AzureBastionSubnet | 10.0.2.0/27 | Azure Bastion | nsg-bastion |
| snet-dns-resolvers | 10.0.3.0/28 | Azure DNS Private Resolver | nsg-dns |
| snet-hub-mgmt | 10.0.4.0/27 | Management jump servers | nsg-mgmt |

### 2.3 Corp Prod Spoke Subnets (vnet-spoke-corp-prod 10.1.0.0/16)

| Subnet | CIDR | Purpose | NSG |
|---|---|---|---|
| snet-app-frontend | 10.1.0.0/24 | Frontend application tier | nsg-app-frontend |
| snet-app-backend | 10.1.1.0/24 | Backend application tier | nsg-app-backend |
| snet-app-integration | 10.1.2.0/24 | Integration services | nsg-app-integration |
| snet-data-sql | 10.1.10.0/24 | Azure SQL private endpoints | nsg-data |
| snet-data-storage | 10.1.11.0/24 | Storage private endpoints | nsg-data |
| snet-data-redis | 10.1.12.0/24 | Redis Cache private endpoints | nsg-data |
| snet-mgmt | 10.1.20.0/27 | Management and monitoring | nsg-mgmt |
| snet-privatelink | 10.1.30.0/24 | General private endpoints | nsg-privatelink |

### 2.4 AKS Spoke Subnets (vnet-spoke-aks-prod 10.5.0.0/16)

| Subnet | CIDR | Purpose | NSG |
|---|---|---|---|
| snet-aks-system | 10.5.0.0/24 | AKS system node pool | nsg-aks |
| snet-aks-workload | 10.5.1.0/23 | AKS workload node pool | nsg-aks |
| snet-aks-spot | 10.5.3.0/23 | AKS spot node pool | nsg-aks |
| snet-aks-pods | 10.5.64.0/18 | AKS pod overlay network | nsg-aks |
| snet-aks-ilb | 10.5.128.0/24 | AKS internal load balancers | nsg-aks-ilb |
| snet-aks-privatelink | 10.5.130.0/24 | AKS private endpoints | nsg-privatelink |

---

## 3. NSG Rule Specifications

### 3.1 nsg-bastion

| Priority | Name | Direction | Source | Destination | Port | Action |
|---|---|---|---|---|---|---|
| 100 | AllowHttpsInbound | Inbound | Internet | * | 443 | Allow |
| 110 | AllowGatewayManagerInbound | Inbound | GatewayManager | * | 443 | Allow |
| 120 | AllowAzureLoadBalancerInbound | Inbound | AzureLoadBalancer | * | 443 | Allow |
| 130 | AllowBastionHostComms | Inbound | VirtualNetwork | VirtualNetwork | 8080,5701 | Allow |
| 4096 | DenyAllInbound | Inbound | * | * | * | Deny |
| 100 | AllowSshRdpOutbound | Outbound | * | VirtualNetwork | 22,3389 | Allow |
| 110 | AllowAzureCloudOutbound | Outbound | * | AzureCloud | 443 | Allow |
| 120 | AllowBastionCommsOutbound | Outbound | * | VirtualNetwork | 8080,5701 | Allow |
| 4096 | DenyAllOutbound | Outbound | * | * | * | Deny |

### 3.2 nsg-aks

| Priority | Name | Direction | Source | Destination | Port | Action |
|---|---|---|---|---|---|---|
| 100 | AllowAzureLoadBalancer | Inbound | AzureLoadBalancer | * | * | Allow |
| 110 | AllowVnetInbound | Inbound | VirtualNetwork | VirtualNetwork | * | Allow |
| 4096 | DenyAllInbound | Inbound | * | * | * | Deny |
| 100 | AllowVnetOutbound | Outbound | VirtualNetwork | VirtualNetwork | * | Allow |
| 110 | AllowInternetOutbound | Outbound | * | Internet | 443 | Allow |
| 4096 | DenyAllOutbound | Outbound | * | * | * | Deny |

### 3.3 nsg-data

| Priority | Name | Direction | Source | Destination | Port | Action |
|---|---|---|---|---|---|---|
| 100 | AllowAppTierInbound | Inbound | 10.1.0.0/23 | * | 1433,6380,443 | Allow |
| 110 | AllowAKSInbound | Inbound | 10.5.0.0/16 | * | 1433,6380,443 | Allow |
| 4096 | DenyAllInbound | Inbound | * | * | * | Deny |
| 100 | AllowVnetOutbound | Outbound | * | VirtualNetwork | * | Allow |
| 4096 | DenyAllOutbound | Outbound | * | * | * | Deny |

---

## 4. Route Tables (UDR)

### 4.1 rt-spoke-default
Applied to all spoke subnets to force traffic through Azure Firewall.

| Route Name | Address Prefix | Next Hop Type | Next Hop IP |
|---|---|---|---|
| default-to-firewall | 0.0.0.0/0 | VirtualAppliance | 10.0.1.4 |
| rfc1918-10-to-firewall | 10.0.0.0/8 | VirtualAppliance | 10.0.1.4 |
| rfc1918-172-to-firewall | 172.16.0.0/12 | VirtualAppliance | 10.0.1.4 |
| rfc1918-192-to-firewall | 192.168.0.0/16 | VirtualAppliance | 10.0.1.4 |

### 4.2 rt-gateway-subnet
Applied to GatewaySubnet to route on-premises traffic to spokes via firewall.

| Route Name | Address Prefix | Next Hop Type | Next Hop IP |
|---|---|---|---|
| spoke-corp-prod | 10.1.0.0/16 | VirtualAppliance | 10.0.1.4 |
| spoke-corp-nonprod | 10.2.0.0/16 | VirtualAppliance | 10.0.1.4 |
| spoke-online-prod | 10.3.0.0/16 | VirtualAppliance | 10.0.1.4 |
| spoke-data-prod | 10.4.0.0/16 | VirtualAppliance | 10.0.1.4 |
| spoke-aks-prod | 10.5.0.0/16 | VirtualAppliance | 10.0.1.4 |

---

## 5. Azure Firewall Policy

### 5.1 Policy Hierarchy

fw-policy-base (Parent - Global rules)
- fw-policy-prod (Child - Production rules)
- fw-policy-nonprod (Child - Non-production rules)

### 5.2 Base Policy Rule Collections

Network Rule Collection: rc-net-infrastructure (Priority 100)

| Rule | Source | Destination | Port | Protocol | Action |
|---|---|---|---|---|---|
| allow-dns | 10.0.0.0/8 | 168.63.129.16 | 53 | UDP/TCP | Allow |
| allow-ntp | 10.0.0.0/8 | * | 123 | UDP | Allow |
| allow-azure-monitor | 10.0.0.0/8 | AzureMonitor | 443 | TCP | Allow |
| allow-key-vault | 10.0.0.0/8 | AzureKeyVault | 443 | TCP | Allow |
| allow-storage | 10.0.0.0/8 | Storage | 443 | TCP | Allow |
| allow-acr | 10.0.0.0/8 | AzureContainerRegistry | 443 | TCP | Allow |

Application Rule Collection: rc-app-internet (Priority 200)

| Rule | Source | Target FQDN | Port | Action |
|---|---|---|---|---|
| allow-windows-update | 10.0.0.0/8 | WindowsUpdate | 80,443 | Allow |
| allow-ubuntu-updates | 10.0.0.0/8 | *.ubuntu.com | 80,443 | Allow |
| allow-mcr | 10.0.0.0/8 | mcr.microsoft.com | 443 | Allow |
| allow-github | 10.5.0.0/16 | github.com,*.github.com | 443 | Allow |
| deny-all-internet | 10.0.0.0/8 | * | * | Deny |

---

## 6. DNS Architecture

### 6.1 DNS Resolution Flow

Azure Workloads
- Query DNS: 168.63.129.16 (Azure DNS)
- Azure DNS Private Resolver (Inbound: 10.0.3.4)
  - Private DNS Zones for Azure PaaS services
  - Conditional forwarder to on-premises DNS
- On-Premises DNS (10.100.1.10)
  - Resolves internal on-premises hostnames

### 6.2 Private DNS Zones

| Zone | Linked VNets | Purpose |
|---|---|---|
| privatelink.blob.core.windows.net | All spokes | Storage blob |
| privatelink.file.core.windows.net | All spokes | Storage files |
| privatelink.database.windows.net | Corp spokes | Azure SQL |
| privatelink.vaultcore.azure.net | All spokes | Key Vault |
| privatelink.azurecr.io | AKS spoke | Container Registry |
| privatelink.canadacentral.azmk8s.io | Hub, Corp | AKS private cluster |
| privatelink.redis.cache.windows.net | Corp spokes | Redis Cache |
| privatelink.servicebus.windows.net | Corp spokes | Service Bus |

---

## 7. Private Endpoint Design

### 7.1 Private Endpoint Inventory

| Resource | Type | Subnet | Private IP | DNS Zone |
|---|---|---|---|---|
| sa-prod-app-001 | Storage blob | snet-data-storage | 10.1.11.4 | privatelink.blob.core.windows.net |
| sa-prod-app-001 | Storage file | snet-data-storage | 10.1.11.5 | privatelink.file.core.windows.net |
| sql-prod-app-001 | Azure SQL | snet-data-sql | 10.1.10.4 | privatelink.database.windows.net |
| kv-prod-app-001 | Key Vault | snet-privatelink | 10.1.30.4 | privatelink.vaultcore.azure.net |
| acr-prod-001 | Container Registry | snet-aks-privatelink | 10.5.130.4 | privatelink.azurecr.io |
| redis-prod-001 | Redis Cache | snet-data-redis | 10.1.12.4 | privatelink.redis.cache.windows.net |
| sb-prod-001 | Service Bus | snet-privatelink | 10.1.30.5 | privatelink.servicebus.windows.net |

---

## 8. VNet Peering Configuration

### 8.1 Peering Settings

| Peering | Allow VNet Access | Allow Forwarded Traffic | Allow Gateway Transit | Use Remote Gateway |
|---|---|---|---|---|
| hub-to-spoke-corp-prod | Yes | Yes | Yes | No |
| spoke-corp-prod-to-hub | Yes | Yes | No | Yes |
| hub-to-spoke-aks-prod | Yes | Yes | Yes | No |
| spoke-aks-prod-to-hub | Yes | Yes | No | Yes |
| hub-to-spoke-online-prod | Yes | Yes | Yes | No |
| spoke-online-prod-to-hub | Yes | Yes | No | Yes |

Note: No direct spoke-to-spoke peering. All cross-spoke traffic routes via hub firewall.

---

## 9. ExpressRoute / VPN Gateway

### 9.1 ExpressRoute Configuration

| Parameter | Value |
|---|---|
| Gateway SKU | ErGw3AZ (Zone redundant) |
| Circuit bandwidth | 1 Gbps |
| Peering type | Private peering |
| BGP ASN (Azure) | 65515 |
| BGP ASN (On-premises) | 65001 |
| Primary peer subnet | 192.168.100.0/30 |
| Secondary peer subnet | 192.168.100.4/30 |
| Advertised prefixes | 10.0.0.0/8 |

### 9.2 VPN Gateway (Backup)

| Parameter | Value |
|---|---|
| Gateway SKU | VpnGw3AZ (Zone redundant) |
| VPN type | Route-based |
| Connection type | Site-to-site |
| IKE version | IKEv2 |
| Encryption | AES-256 |
| Integrity | SHA-256 |
| DH Group | DHGroup24 |

---

## 10. Terraform Resource Mapping

| Azure Resource | Terraform Resource | Module |
|---|---|---|
| Hub VNet | azurerm_virtual_network.hub | network/hub |
| Hub subnets | azurerm_subnet.* | network/hub |
| Azure Firewall | azurerm_firewall.hub | network/hub |
| Firewall Policy | azurerm_firewall_policy.base | network/hub |
| VPN Gateway | azurerm_virtual_network_gateway.vpn | network/hub |
| Azure Bastion | azurerm_bastion_host.hub | network/hub |
| Spoke VNets | azurerm_virtual_network.spoke | network/spoke |
| VNet Peerings | azurerm_virtual_network_peering.* | network/peering |
| NSGs | azurerm_network_security_group.* | network/nsg |
| Route Tables | azurerm_route_table.* | network/routing |
| Private DNS Zones | azurerm_private_dns_zone.* | network/dns |
| Private Endpoints | azurerm_private_endpoint.* | network/privatelink |

---

## 11. Related Documents

- HLD: Azure Landing Zone (HLD-azure-landing-zone.md)
- ADR-001: Multi-Cloud Strategy
- ADR-002: Kubernetes Platform Decision
- Azure Security Baseline
- AKS Terraform Module README
