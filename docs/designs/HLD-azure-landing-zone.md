# High Level Design: Azure Landing Zone

**Document Type:** High Level Design (HLD)
**Version:** 1.0
**Date:** 2026-04-02
**Status:** Approved
**Author:** Senior Cloud Architect
**Reviewed By:** Architecture Review Board

---

## 1. Executive Summary

This High Level Design describes the Azure Landing Zone architecture for a
large enterprise organization migrating workloads to Azure. The landing zone
provides a secure, scalable, and governed foundation for all cloud workloads
following Microsoft Cloud Adoption Framework (CAF) principles.

The design supports 50+ application teams, 200+ Azure subscriptions, and
estimated 5,000+ cloud resources at steady state.

---

## 2. Business Requirements

| Requirement | Description | Priority |
|---|---|---|
| BR-001 | Support multi-subscription model for workload isolation | High |
| BR-002 | Enforce security and compliance controls at scale | High |
| BR-003 | Provide centralized network connectivity to on-premises | High |
| BR-004 | Enable self-service provisioning for application teams | Medium |
| BR-005 | Integrate cost governance and chargeback reporting | Medium |
| BR-006 | Support hybrid identity with on-premises Active Directory | High |
| BR-007 | Meet SOC2 Type II and ISO 27001 compliance requirements | High |
| BR-008 | Enable disaster recovery across two Azure regions | High |

---

## 3. Architecture Overview

### 3.1 Management Group Hierarchy

Tenant Root Group
- Platform
  - Management
  - Connectivity
  - Identity
- Landing Zones
  - Corp
    - Production
    - Non-Production
    - DR
  - Online
    - Production
    - Non-Production
- Sandbox
- Decommissioned

### 3.2 Subscription Design

| Subscription | Management Group | Purpose |
|---|---|---|
| sub-management | Platform/Management | Centralized management tools |
| sub-connectivity | Platform/Connectivity | Hub network, firewall, DNS |
| sub-identity | Platform/Identity | AD DS, AAD Connect |
| sub-corp-prod-XXX | Landing Zones/Corp/Production | Production workloads |
| sub-corp-nonprod-XXX | Landing Zones/Corp/Non-Production | Dev/test workloads |
| sub-online-prod-XXX | Landing Zones/Online/Production | Internet-facing apps |
| sub-sandbox-XXX | Sandbox | Developer experimentation |

### 3.3 Network Topology

Hub VNet - Canada Central (10.0.0.0/16)
- GatewaySubnet       10.0.0.0/27   VPN/ER Gateway
- AzureFirewallSubnet 10.0.1.0/26   Firewall Premium
- BastionSubnet       10.0.2.0/27   Bastion

Spoke VNets peered to Hub:
- Corp Prod Spoke     10.1.0.0/16   snet-app, snet-data, snet-mgmt
- Online Prod Spoke   10.2.0.0/16   snet-frontend, snet-backend, snet-data

On-Premises connected via ExpressRoute/VPN:
- On-Premises Network 10.100.0.0/16

### 3.4 Identity Architecture

- Azure Active Directory: cloud identity provider for all users and workloads
- Azure AD Connect: hybrid sync from on-premises Active Directory
- Privileged Identity Management: just-in-time access for all privileged roles
- Conditional Access: MFA + compliant device required for all access
- Azure AD B2B: external partner and vendor access management

---

## 4. Security Architecture

### 4.1 Defense in Depth

- Layer 1 - Perimeter:    Azure DDoS Protection Standard
- Layer 2 - Network:      Azure Firewall Premium + NSGs
- Layer 3 - Compute:      Defender for Servers + Patch Management
- Layer 4 - Application:  WAF (App Gateway / Front Door)
- Layer 5 - Data:         Encryption at rest (CMK) + in transit (TLS 1.3)
- Layer 6 - Identity:     Azure AD + MFA + PIM + Conditional Access

### 4.2 Governance Controls

| Control | Implementation | Scope |
|---|---|---|
| Policy enforcement | Azure Policy initiatives | Management Group |
| Security posture | Defender for Cloud Standard | All subscriptions |
| Compliance monitoring | Regulatory compliance dashboard | All subscriptions |
| Cost governance | Azure Cost Management + budgets | Per subscription |
| Resource tagging | Azure Policy deny untagged | All subscriptions |
| Allowed regions | Azure Policy deny non-approved | All subscriptions |
| Allowed VM SKUs | Azure Policy deny oversized | Landing Zone MGs |

### 4.3 Compliance Framework Alignment

| Framework | Status | Implementation |
|---|---|---|
| CIS Azure Benchmark v2.0 | Enforced | Azure Policy initiative |
| SOC 2 Type II | Compliant | Defender for Cloud + audit logs |
| ISO 27001 | Compliant | Azure Policy + documentation |
| NIST CSF | Aligned | Defender for Cloud mapping |

---

## 5. Observability Architecture

### 5.1 Centralized Logging

All platform and workload logs flow to a centralized Log Analytics Workspace
in the Management subscription:

- Azure Activity Logs (all subscriptions)
- Azure AD Sign-in and Audit Logs
- Azure Firewall logs
- Defender for Cloud alerts
- Resource diagnostic logs via Azure Policy auto-deployment

Retention: 90 days hot (Log Analytics), 2 years cold (Azure Storage Archive)

### 5.2 Monitoring Stack

| Tool | Purpose | Scope |
|---|---|---|
| Azure Monitor | Platform metrics and alerting | All Azure resources |
| Log Analytics | Centralized log aggregation | All subscriptions |
| Application Insights | APM for application workloads | Per application |
| Microsoft Sentinel | SIEM and SOAR | All subscriptions |
| Grafana | Custom dashboards | Platform and workloads |

---

## 6. Disaster Recovery

### 6.1 Regional Strategy

| Component | Primary | Secondary | Replication |
|---|---|---|---|
| Hub Network | Canada Central | Canada East | Active-Passive |
| Identity AD DS | Canada Central | Canada East | Active-Active |
| Management tools | Canada Central | Canada East | Active-Passive |
| Workload data | Canada Central | Canada East | Geo-redundant |

### 6.2 Recovery Objectives

| Tier | RTO | RPO | Examples |
|---|---|---|---|
| Tier 1 Critical | 1 hour | 15 minutes | Core platform, identity |
| Tier 2 High | 4 hours | 1 hour | Business applications |
| Tier 3 Standard | 24 hours | 4 hours | Non-critical workloads |

---

## 7. Cost Governance

### 7.1 FinOps Framework

- Budgets set per subscription with 80% and 100% alerts
- Cost allocation tags enforced via Azure Policy (CostCenter, Owner, Project)
- Reserved Instances for predictable workloads (1-year commitment)
- Spot instances for non-critical batch and dev workloads
- Azure Advisor recommendations reviewed monthly
- Showback reports generated monthly per business unit

### 7.2 Cost Optimization Controls

| Control | Saving Estimate | Implementation |
|---|---|---|
| Auto-shutdown dev VMs | 60% dev compute | Azure Automation |
| Right-sizing recommendations | 15-25% compute | Azure Advisor |
| Reserved Instances | 30-40% compute | EA commitment |
| Spot node pools AKS | 60-80% batch compute | AKS spot pools |
| Storage lifecycle policies | 40-60% storage | Blob lifecycle rules |

---

## 8. Assumptions and Constraints

### Assumptions
- Organization has an existing Azure EA (Enterprise Agreement)
- On-premises Active Directory will be retained for hybrid identity
- ExpressRoute circuit will be provisioned within 90 days of project start
- Application teams will follow the landing zone onboarding process

### Constraints
- All data must remain within Canada (canadacentral, canadaeast)
- No third-party firewall appliances - Azure Firewall Premium only
- All IaC must use Terraform - no manual portal deployments in production
- Change management requires 5-day lead time for production changes

---

## 9. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| ExpressRoute delay | Medium | High | VPN Gateway as interim connectivity |
| Application team adoption | Medium | Medium | Self-service portal + documentation |
| Policy breaking existing workloads | Low | High | Audit mode before enforce mode |
| Cost overrun in sandbox | Medium | Low | Hard budget limits + auto-shutdown |

---

## 10. Related Documents

- LLD-001: Hub-Spoke Network Design
- ADR-001: Multi-Cloud Strategy
- ADR-002: Kubernetes Platform Decision
- Azure Security Baseline
- Architecture Overview
