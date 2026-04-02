# FinOps Cost Governance Framework

**Version:** 1.0
**Date:** 2026-04-02
**Owner:** Cloud Architecture Team
**Framework:** FinOps Foundation Cloud Cost Management

---

## 1. Overview

This document defines the FinOps framework for managing cloud costs across
Azure, AWS, and GCP. It establishes accountability, processes, and tooling
to ensure cloud spend is visible, optimized, and aligned with business value.

FinOps is not just a cost-cutting exercise - it is a cultural practice that
brings engineering, finance, and business teams together to make informed
decisions about cloud spending.

---

## 2. FinOps Maturity Model

| Phase | Description | Our Target |
|---|---|---|
| Crawl | Basic visibility, tagging, budgets | Completed |
| Walk | Allocation, showback, optimization | In Progress |
| Run | Chargeback, forecasting, automation | Q4 2026 |

---

## 3. Organizational Structure

### 3.1 FinOps Team

| Role | Responsibility |
|---|---|
| Cloud Architect | Cost architecture decisions, reserved capacity planning |
| FinOps Lead | Framework governance, reporting, optimization roadmap |
| Finance Partner | Budget management, chargeback, forecasting |
| Engineering Leads | Team-level cost accountability, optimization implementation |
| Platform Team | Tooling, automation, tagging enforcement |

### 3.2 Governance Cadence

| Meeting | Frequency | Attendees | Purpose |
|---|---|---|---|
| Cloud Cost Review | Weekly | FinOps Lead, Eng Leads | Review spend anomalies |
| FinOps Council | Monthly | All FinOps Team | Optimization decisions |
| Budget Review | Quarterly | Finance + Architecture | Forecast vs actuals |
| Reserved Capacity Review | Quarterly | Cloud Architect + Finance | RI/SP optimization |

---

## 4. Tagging Strategy

### 4.1 Mandatory Tags

All Azure resources must have these tags enforced via Azure Policy (Deny effect):

| Tag Key | Example Value | Purpose |
|---|---|---|
| Environment | prod, staging, dev | Environment identification |
| CostCenter | CC-1234 | Finance chargeback allocation |
| Owner | team-platform | Accountability |
| Project | cloud-migration | Project cost tracking |
| ManagedBy | Terraform | Change management |

### 4.2 Recommended Tags

| Tag Key | Example Value | Purpose |
|---|---|---|
| Application | payments-api | Application-level cost tracking |
| BusinessUnit | retail | Business unit allocation |
| Criticality | high, medium, low | DR tier and cost priority |
| AutoShutdown | true, false | Dev/test cost optimization |

### 4.3 Tag Enforcement

- Azure Policy initiative enforces mandatory tags at subscription scope
- Deny effect prevents resource creation without required tags
- Terraform modules include tag validation in variable definitions
- Weekly compliance report identifies untagged resources
- Untagged resources are automatically assigned to a default cost center
  with a penalty multiplier for reporting purposes

---

## 5. Budget Management

### 5.1 Budget Hierarchy

Budgets are set at three levels:

Level 1 - Enterprise Agreement (Annual)
- Total annual cloud commitment negotiated with Microsoft
- Reviewed and adjusted annually during EA renewal

Level 2 - Subscription (Monthly)
- Each subscription has a monthly budget set in Azure Cost Management
- Alert thresholds: 50%, 80%, 100% of budget
- Forecast alert at 100% of budget based on current trend

Level 3 - Resource Group (Monthly)
- Critical workload resource groups have individual budgets
- Enables team-level accountability and early warning

### 5.2 Alert Actions

| Threshold | Action | Owner |
|---|---|---|
| 50% of budget | Email notification | Engineering Lead |
| 80% of budget | Email + Slack alert | Engineering Lead + FinOps Lead |
| 100% of budget | Email + PagerDuty | Engineering Lead + Finance + CTO |
| Forecast 100% | Email + Slack alert | FinOps Lead + Finance |

### 5.3 Budget Overage Process

1. FinOps Lead investigates root cause within 24 hours
2. Engineering team provides remediation plan within 48 hours
3. Finance approves budget adjustment or optimization plan
4. Post-mortem documented for overages exceeding 20%

---

## 6. Cost Allocation and Showback

### 6.1 Allocation Model

| Cost Type | Allocation Method |
|---|---|
| Direct workload costs | Tag-based allocation to CostCenter |
| Shared platform costs | Proportional allocation by workload compute spend |
| Network egress | Allocated to consuming workload |
| Support costs | Split equally across business units |
| Reserved Instance savings | Credited to consuming workload |

### 6.2 Monthly Showback Report

Generated on the 3rd business day of each month covering:
- Total spend by business unit
- Total spend by environment (prod/staging/dev)
- Top 10 most expensive resources
- Month-over-month variance with explanation
- Savings achieved from optimization actions
- Reserved Instance utilization and coverage
- Recommendations for next month

---

## 7. Cost Optimization Strategies

### 7.1 Right-Sizing

- Azure Advisor recommendations reviewed weekly
- VMs with less than 20% CPU utilization over 14 days flagged for downsizing
- AKS Vertical Pod Autoscaler used for automatic right-sizing of containers
- Right-sizing implemented within 2 weeks of recommendation unless business justified

### 7.2 Reserved Instances and Savings Plans

| Resource Type | Commitment | Expected Saving |
|---|---|---|
| AKS system node pools | 1-year RI | 30-40% vs pay-as-you-go |
| Production VMs (stable) | 1-year RI | 30-40% vs pay-as-you-go |
| Azure SQL (production) | 1-year RI | 30-40% vs pay-as-you-go |
| Azure App Service (prod) | 1-year Savings Plan | 20-30% vs pay-as-you-go |
| Dev/test workloads | Pay-as-you-go + auto-shutdown | 60% vs always-on |

RI coverage target: 70% of stable production compute covered by reservations.
RI utilization target: Greater than 85% utilization on all purchased reservations.

### 7.3 Spot and Preemptible Instances

- AKS spot node pool for batch workloads and non-critical jobs
- KEDA used to scale spot workloads based on queue depth
- Spot interruption handlers implemented for graceful pod termination
- Expected saving: 60-80% vs on-demand for eligible workloads

### 7.4 Storage Optimization

| Storage Tier | Use Case | Relative Cost |
|---|---|---|
| Hot | Frequently accessed data (less than 30 days) | Highest |
| Cool | Infrequently accessed data (30-90 days) | Medium |
| Cold | Rarely accessed data (90-180 days) | Low |
| Archive | Long-term retention (180+ days) | Lowest |

Lifecycle management policies automatically transition blobs between tiers.
All storage accounts have lifecycle policies enforced via Terraform.

### 7.5 Dev/Test Cost Controls

- Auto-shutdown policy on all dev/test VMs: 7pm local time
- AKS dev clusters scaled to zero outside business hours via KEDA
- Dev/test subscriptions have hard spending limits
- Sandbox subscriptions auto-delete resources older than 30 days
- Dev/test uses Azure Hybrid Benefit for Windows Server licensing

---

## 8. Tooling

### 8.1 Azure Cost Management

- Primary tool for Azure cost visibility and budgets
- Custom views created per business unit and environment
- Cost exports to Azure Storage for custom reporting
- Power BI dashboard connected to cost export data

### 8.2 Third-Party Tools

| Tool | Purpose | Cloud |
|---|---|---|
| CloudHealth | Multi-cloud cost aggregation | Azure, AWS, GCP |
| Infracost | IaC cost estimation in CI/CD | All |
| Azure Advisor | Right-sizing recommendations | Azure |
| AWS Cost Explorer | AWS cost analysis | AWS |
| Kubecost | Kubernetes cost allocation | AKS, EKS |

### 8.3 Infracost in CI/CD

Every Terraform PR automatically generates a cost estimate:

- Infracost runs on every PR touching iac/terraform/
- Cost diff posted as PR comment showing monthly cost change
- PRs increasing cost by more than $500/month require FinOps Lead approval
- Cost estimates stored in cost history for trend analysis

---

## 9. FinOps KPIs

| KPI | Target | Current | Trend |
|---|---|---|---|
| Tagging compliance | 100% | 97% | Improving |
| RI utilization | Greater than 85% | 88% | On target |
| RI coverage | 70% stable compute | 65% | Improving |
| Unit cost per transaction | Decreasing MoM | -3% MoM | On target |
| Waste (unused resources) | Less than 5% of spend | 4.2% | On target |
| Forecast accuracy | Within 10% of actuals | 8% variance | On target |
| Dev/test vs prod ratio | Less than 20% | 18% | On target |

---

## 10. Architecture Decision Checklist

Every architecture review must answer these FinOps questions:

- What is the estimated monthly cost of this solution?
- What are the cost drivers and how do they scale with usage?
- Are Reserved Instances or Savings Plans applicable?
- Can spot/preemptible instances be used for any workloads?
- What storage tiers are appropriate for the data lifecycle?
- Are there cheaper PaaS alternatives to the proposed IaaS solution?
- What tagging will be applied for cost allocation?
- What budget alerts will be configured?
- How will costs be monitored post-deployment?
- What is the cost optimization roadmap for this solution?

---

## 11. Related Documents

- HLD Azure Landing Zone: docs/designs/HLD-azure-landing-zone.md
- Azure Security Baseline: security/baselines/azure-security-baseline.md
- Architecture Overview: docs/architecture-overview.md
- ADR-001 Multi-Cloud Strategy: architectures/decisions/ADR-001-multi-cloud-strategy.md
