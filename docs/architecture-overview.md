# Cloud Architecture Overview

**Version:** 1.0
**Date:** 2026-04-02
**Owner:** Cloud Architecture Team
**Status:** Living Document

---

## Executive Summary

This document describes the cloud architecture for a multi-cloud enterprise platform
built on Azure as the primary cloud provider, with AWS for data and ML workloads,
and GCP selectively for analytics. The architecture follows a hub-spoke network
topology, zero-trust security model, and GitOps-driven deployment methodology.

---

## Architecture Principles

| Principle | Description |
|---|---|
| Design for failure | Every component assumes failure; no single points of failure |
| Least privilege | Minimal IAM permissions everywhere, reviewed quarterly |
| Infrastructure as Code | Nothing manual in production; all changes via Terraform/Bicep |
| Shift-left security | Security scanning in every PR pipeline |
| Cost awareness | FinOps embedded in architecture reviews and tagging strategy |
| Observability first | Logs, metrics, and traces from day one on every service |

---

## High-Level Architecture

AZURE PLATFORM

HUB VNET (10.0.0.0/16)
- Gateway Subnet    10.0.0.0/27
- Firewall Subnet   10.0.1.0/26  [Azure Firewall Premium]
- Bastion Subnet    10.0.2.0/27  [Azure Bastion]

Spoke VNets (peered to Hub via VNet Peering):
- SPOKE APP  10.1.0.0/16  [AKS Cluster, App Services, API Management]
- SPOKE DATA 10.2.0.0/16  [Azure SQL, CosmosDB, Redis]

Connected to On-Premises via ExpressRoute/VPN Gateway

---

## Network Architecture

### Hub-Spoke Topology

The network follows a hub-spoke topology where all traffic flows through
a centralized hub VNet containing shared security and connectivity services.

Hub VNet (10.0.0.0/16) contains:
- Azure Firewall Premium: inspects all east-west and north-south traffic
- Azure VPN Gateway: site-to-site connectivity to on-premises
- Azure Bastion: secure RDP/SSH access without public IPs
- Azure DDoS Protection Standard: volumetric attack mitigation

Spoke VNets are peered to the hub and contain workload resources:
- Spoke App (10.1.0.0/16): AKS cluster, App Services, API Management
- Spoke Data (10.2.0.0/16): databases, storage, analytics services

### Traffic Flow Rules

All traffic between spokes routes through Azure Firewall via User Defined Routes.
No direct spoke-to-spoke peering is permitted. Internet egress is forced through
Azure Firewall for inspection and logging. All PaaS services use Private Endpoints.

---

## Compute Architecture

### AKS Cluster Design

| Node Pool | SKU | Min | Max | Purpose |
|---|---|---|---|---|
| System | Standard_D4s_v5 | 3 | 3 | kube-system workloads |
| Workload | Standard_D8s_v5 | 3 | 10 | Application workloads |
| Spot | Standard_D8s_v5 | 0 | 20 | Batch, non-critical jobs |

Key AKS configuration:
- Private cluster with API server VNet integration
- Azure CNI with dynamic IP allocation
- Workload Identity Federation (replaces pod-managed identities)
- Cluster autoscaler enabled on workload and spot pools
- Availability zones spread across zones 1, 2, 3
- Azure Policy add-on for compliance enforcement
- Defender for Containers for runtime security

### GitOps Deployment Model

All application deployments use ArgoCD running in the argocd namespace:

Developer -> Git PR -> GitHub Actions CI -> Merge to main
-> ArgoCD detects git change -> Syncs to AKS cluster (App of Apps pattern)

---

## Security Architecture

### Zero Trust Model

Identity: Azure AD is the identity provider for all human and workload identities.
PIM gates all elevated access. Conditional Access policies enforce MFA and
compliant device requirements.

Network: No implicit trust based on network location. Azure Firewall Premium
with IDPS inspects all traffic. Private Endpoints eliminate public exposure.
NSGs enforce microsegmentation within subnets.

Data: All data encrypted at rest with Customer Managed Keys stored in
Azure Key Vault with HSM backing. TLS 1.3 enforced for all data in transit.

Applications: Container images scanned by Defender for Containers at build
and runtime. Azure Policy enforces pod security standards.

---

## Observability Architecture

### Three Pillars

Metrics: Prometheus scrapes all AKS workloads and node metrics.
Grafana dashboards provide real-time visibility. Azure Monitor collects
platform-level metrics for Azure resources.

Logs: All application and infrastructure logs ship to a centralized
Log Analytics Workspace. Azure Diagnostic Settings configured on every
resource. Log retention: 90 days hot, 2 years cold (Azure Storage).

Traces: OpenTelemetry SDK instrumented in all services. Traces
exported to Azure Monitor Application Insights.

### Alerting Flow

Prometheus Alert Rules -> Alertmanager -> PagerDuty (SEV-1/2) + Slack (SEV-3/4)

---

## Disaster Recovery

### Recovery Objectives

| Tier | Workloads | RTO | RPO |
|---|---|---|---|
| Tier 1 | Core platform services | 1 hour | 15 minutes |
| Tier 2 | Business applications | 4 hours | 1 hour |
| Tier 3 | Non-critical services | 24 hours | 4 hours |

Primary region is Canada Central. Secondary region is Canada East.
AKS clusters are deployed in both regions. Azure Traffic Manager provides
DNS-based failover. Database geo-replication is enabled for all Tier 1
and Tier 2 workloads.

---

## Related Documents

- ADR-001: Multi-Cloud Strategy
- ADR-002: Kubernetes Platform Decision
- HLD: Azure Landing Zone
- LLD: Hub-Spoke Network Design
- Azure Security Baseline
- Incident Response Runbook
- Prometheus Alert Rules
