# Azure Security Baseline

**Version:** 1.0
**Date:** 2026-04-02
**Owner:** Cloud Architecture Team
**Frameworks:** CIS Azure Benchmark v2.0, SOC2 Type II, ISO 27001

---

## Identity and Access Management

### Service Principal Standards
- All service principals use OIDC/Workload Identity Federation (no client secrets)
- Managed Identities preferred over service principals for Azure-to-Azure auth
- Service principal credentials rotated every 90 days maximum
- No service principal has Owner role at subscription scope

### RBAC Principles
- All assignments use custom roles or built-in roles at resource group scope minimum
- No direct user assignments at subscription scope - use AAD groups
- Privileged Identity Management (PIM) required for all privileged roles
- Emergency break-glass accounts documented and access reviewed monthly

---

## Network Security

### Virtual Network Standards
- All production VNets use hub-spoke topology with Azure Firewall Premium
- No public IPs on workload VMs - use Azure Bastion for management access
- Private Endpoints required for all PaaS services (Storage, KeyVault, SQL)
- DDoS Protection Standard enabled on hub VNet

### NSG Rules
- Default deny-all inbound rule on all NSGs
- No inbound rules allowing 0.0.0.0/0 except through Azure Firewall
- NSG Flow Logs enabled and sent to Log Analytics

---

## Data Protection

### Encryption Standards
- All storage encrypted at rest with Customer Managed Keys (CMK)
- TLS 1.2 minimum for all data in transit (TLS 1.3 preferred)
- Azure Key Vault used for all secrets, certificates, and keys
- Key rotation automated via Key Vault rotation policy

### Data Classification

| Classification | Examples | Controls |
|---|---|---|
| Public | Marketing content | Standard encryption |
| Internal | Architecture docs | RBAC + audit logging |
| Confidential | Customer PII | CMK + Private Endpoint + DLP |
| Restricted | Credentials, keys | Key Vault + HSM + PIM |

---

## Monitoring and Compliance

### Required Diagnostic Settings

Every resource must ship logs to centralized Log Analytics workspace:
- Activity logs (subscription level)
- Resource diagnostic logs
- Azure AD sign-in and audit logs
- Microsoft Defender for Cloud alerts

### Compliance Frameworks
- Azure Policy assignments enforce CIS Azure Benchmark v2.0
- Microsoft Defender for Cloud set to Standard tier (all resource types)
- Weekly CSPM score review with remediation tracking

---

## Patch Management

- Azure Update Manager used for all VM patch orchestration
- Critical patches applied within 48 hours of release
- High severity patches applied within 7 days
- Patch compliance reports reviewed weekly
- AKS node OS upgrades automated via node image upgrade channel

---

## Incident Response

- Microsoft Sentinel SIEM configured with healthcare/enterprise detection rules
- Automated playbooks (Logic Apps) for common incident types
- PagerDuty integration for SEV-1 and SEV-2 alerts
- Incident response runbook maintained in runbooks/incident-response.md
- Post-mortem required for all SEV-1 and SEV-2 incidents
- Security incident register maintained and reviewed quarterly

---

## Related Documents

- Azure Policy Definitions: security/policies/azure-policies.json
- Incident Response Runbook: runbooks/incident-response.md
- Architecture Overview: docs/architecture-overview.md
- HLD Azure Landing Zone: docs/designs/HLD-azure-landing-zone.md
