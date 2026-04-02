# Architecture Review Board (ARB) Governance

**Version:** 1.0
**Date:** 2026-04-02
**Owner:** Cloud Architecture Team
**Review Cycle:** Annually

---

## 1. Purpose

The Architecture Review Board (ARB) is a governance body responsible for
ensuring all significant technology and cloud architecture decisions align
with enterprise standards, security requirements, and business objectives.

The ARB provides oversight, guidance, and approval for architectural changes
that have significant impact on the organization's technology landscape,
security posture, or cost profile.

---

## 2. ARB Membership

| Role | Responsibility | Voting |
|---|---|---|
| Chief Architect (Chair) | Final decision authority, strategic alignment | Yes |
| Senior Cloud Architect | Cloud platform standards, IaC governance | Yes |
| Security Architect | Security review, compliance validation | Yes |
| Network Architect | Network design review | Yes |
| Engineering Lead | Implementation feasibility, team impact | Yes |
| FinOps Lead | Cost impact assessment | Advisory |
| Data Architect | Data architecture alignment | Advisory |
| Product Owner | Business requirements validation | Advisory |

Quorum requires 4 of 5 voting members present.
Decisions require simple majority of voting members present.

---

## 3. Meeting Cadence

| Meeting Type | Frequency | Duration | Purpose |
|---|---|---|---|
| Regular ARB | Bi-weekly | 90 minutes | Review submitted proposals |
| Emergency ARB | As needed | 60 minutes | Urgent production decisions |
| Architecture Forum | Monthly | 60 minutes | Standards updates, education |
| Annual Review | Yearly | Half day | Strategy and standards refresh |

---

## 4. What Requires ARB Review

### 4.1 Mandatory Review (ARB Approval Required)

The following changes MUST go through ARB review and approval:

- Introduction of a new cloud service or technology not in the approved catalog
- Changes to the network topology or hub-spoke architecture
- New external connectivity (ExpressRoute, VPN, peering)
- Changes to the identity architecture or Azure AD configuration
- New cloud provider or region adoption
- Architecture changes affecting more than one business unit
- Changes to security baseline or compliance controls
- New data residency or sovereignty requirements
- Estimated cloud cost increase greater than $10,000/month
- Disaster recovery architecture changes
- Introduction of new IaC tooling or CI/CD platforms
- Decommissioning of production systems

### 4.2 Advisory Review (ARB Consultation Recommended)

The following changes should consult ARB but do not require formal approval:

- New application deployments using approved patterns
- Scaling changes within approved architecture
- Minor configuration changes to existing approved services
- Dev/test environment changes
- Cost optimizations within approved architecture

### 4.3 No Review Required

- Routine patching and updates
- Application code deployments
- Monitoring and alerting configuration
- Documentation updates

---

## 5. ARB Submission Process

### 5.1 Submission Timeline

Standard submissions must be received at least 5 business days before
the ARB meeting. Emergency submissions may be accepted with 24 hours
notice for the Emergency ARB.

### 5.2 Required Submission Materials

All ARB submissions must include:

1. Architecture Proposal Document (using template below)
2. High Level Design (HLD) or Low Level Design (LLD) as appropriate
3. Architecture Decision Record (ADR) draft
4. Security impact assessment
5. Cost impact assessment (estimated monthly spend)
6. Risk assessment with mitigations
7. Implementation timeline
8. Rollback plan

### 5.3 Submission Checklist

Before submitting to ARB, the proposing architect must confirm:

- Architecture aligns with cloud strategy (ADR-001)
- Security baseline requirements are met
- FinOps checklist completed (see docs/finops/finops-framework.md)
- IaC implementation plan defined (Terraform modules identified)
- Observability requirements defined (logs, metrics, traces)
- DR requirements defined and tested
- Stakeholders have been consulted
- Proof of concept completed if applicable

---

## 6. ARB Proposal Template

### Proposal: [Title]

**Submitted By:** Name, Role
**Date Submitted:** YYYY-MM-DD
**Target ARB Date:** YYYY-MM-DD
**Priority:** Standard / Urgent

#### 6.1 Executive Summary
Two to three sentence summary of the proposed change and business justification.

#### 6.2 Business Justification
Describe the business problem being solved or opportunity being captured.
Include metrics where possible (e.g. current cost, current performance).

#### 6.3 Proposed Architecture
Describe the proposed solution. Reference HLD/LLD documents.
Include architecture diagrams.

#### 6.4 Alternatives Considered

| Option | Description | Reason Not Chosen |
|---|---|---|
| Option A | Description | Reason |
| Option B | Description | Reason |

#### 6.5 Security Impact

| Area | Impact | Mitigation |
|---|---|---|
| Identity | Description | Mitigation |
| Network | Description | Mitigation |
| Data | Description | Mitigation |

#### 6.6 Cost Impact

| Component | Monthly Cost | Annual Cost |
|---|---|---|
| Component 1 | $X,XXX | $XX,XXX |
| Total | $X,XXX | $XX,XXX |

Cost optimization measures applied: Description

#### 6.7 Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Risk 1 | Medium | High | Mitigation |

#### 6.8 Implementation Plan

| Phase | Description | Duration | Dependencies |
|---|---|---|---|
| Phase 1 | Description | 2 weeks | None |

#### 6.9 Rollback Plan
Describe how to revert the change if issues arise post-implementation.

#### 6.10 Success Criteria
Define measurable criteria that confirm successful implementation.

---

## 7. ARB Decision Outcomes

| Decision | Meaning | Next Steps |
|---|---|---|
| Approved | Proceed as proposed | Update ADR to Accepted, begin implementation |
| Approved with Conditions | Proceed with modifications | Address conditions, confirm with Chair |
| Deferred | More information needed | Resubmit with additional information |
| Rejected | Proposal not approved | Document reason, explore alternatives |

All decisions are documented in the ARB decision log and communicated
to the submitting architect within 2 business days of the meeting.

---

## 8. Architecture Standards Catalog

### 8.1 Approved Cloud Services

| Service Category | Approved Services | Notes |
|---|---|---|
| Compute | Azure VMs, AKS, App Service, Azure Functions | AKS preferred for containerized workloads |
| Networking | Azure VNet, Firewall Premium, Bastion, Front Door | No third-party NVAs |
| Storage | Azure Blob, Files, ADLS Gen2 | Must use private endpoints |
| Database | Azure SQL, CosmosDB, Redis Cache, PostgreSQL Flexible | No public endpoints |
| Messaging | Azure Service Bus, Event Hub, Event Grid | Preferred over custom queuing |
| Security | Key Vault, Defender for Cloud, Sentinel | Mandatory on all subscriptions |
| Identity | Azure AD, PIM, Conditional Access | No local accounts in production |
| Monitoring | Azure Monitor, Log Analytics, App Insights | Grafana for custom dashboards |
| IaC | Terraform, Bicep | Terraform preferred |
| CI/CD | GitHub Actions, Azure DevOps | GitHub Actions preferred |

### 8.2 Prohibited Patterns

The following patterns are explicitly prohibited without ARB exception approval:

- Public endpoints on any PaaS service in production
- SSH/RDP open to the internet (0.0.0.0/0)
- Shared service accounts or passwords in code/config files
- Manual resource creation in production (all via IaC)
- Storage accounts with public blob access enabled
- SQL servers with public network access enabled
- VMs without Defender for Servers enabled
- Resources without mandatory tags
- Direct internet egress without Azure Firewall inspection
- Spoke-to-spoke VNet peering (must route via hub firewall)

---

## 9. Architecture Decision Record Process

Every ARB-approved architectural decision must be captured as an ADR:

1. Draft ADR created during proposal preparation
2. ADR reviewed during ARB meeting
3. On approval: ADR status set to Accepted, merged to main branch
4. On rejection: ADR status set to Rejected with reason documented
5. ADRs reviewed annually for continued relevance
6. Superseded ADRs linked to replacement ADR

ADR template: architectures/decisions/ADR-000-template.md
ADR location: architectures/decisions/

---

## 10. Governance Metrics

The ARB tracks the following metrics monthly:

| Metric | Target | Purpose |
|---|---|---|
| ARB submission lead time | Greater than 5 days | Ensure adequate review time |
| ARB approval rate | Greater than 80% | Indicates proposal quality |
| Time from submission to decision | Less than 10 days | Governance velocity |
| ADR coverage | 100% of major decisions | Documentation completeness |
| Prohibited pattern violations | 0 | Compliance enforcement |
| Post-implementation issues | Less than 10% of approved | Architecture quality |

---

## 11. Related Documents

- Architecture Overview: docs/architecture-overview.md
- HLD Azure Landing Zone: docs/designs/HLD-azure-landing-zone.md
- LLD Hub-Spoke Network: docs/designs/LLD-hub-spoke-network.md
- ADR Template: architectures/decisions/ADR-000-template.md
- Azure Security Baseline: security/baselines/azure-security-baseline.md
- FinOps Framework: docs/finops/finops-framework.md
- Azure Policy Definitions: security/policies/azure-policies.json
