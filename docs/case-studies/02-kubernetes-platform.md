# Case Study 02: Enterprise Kubernetes Platform

**Industry:** Retail and E-Commerce
**Timeline:** 8 months
**Team Size:** 6 engineers
**Cloud:** Azure (AKS)

---

## Background

A large retail organization with 300+ microservices deployed across inconsistent
environments was struggling with deployment reliability, scalability during peak
shopping seasons, and developer productivity. Black Friday traffic spikes caused
repeated outages due to manual scaling and inconsistent deployment practices
across 12 development teams.

---

## Problem Statement

- 300+ microservices deployed inconsistently across VMs and early Kubernetes clusters
- 12 development teams each maintaining their own deployment scripts
- No standardized CI/CD pipeline - 40% of deployments required manual intervention
- Black Friday 2024 caused 4 hours of downtime due to inability to scale fast enough
- No GitOps - developers had direct kubectl access to production clusters
- Container images not scanned - 3 critical CVEs discovered in production in 2024
- Mean time to deploy a new service: 3 weeks

---

## Solution Architecture

### Platform Design Principles

1. Self-service: development teams deploy without platform team involvement
2. Paved road: golden paths make the right way the easy way
3. Secure by default: security controls built in, not bolted on
4. Observable by default: every service gets logs, metrics, traces automatically

### AKS Cluster Architecture

| Cluster | Purpose | Region | Node Pools |
|---|---|---|---|
| aks-platform-prod | Platform services (ArgoCD, monitoring) | Canada Central | system, platform |
| aks-workload-prod | Application workloads | Canada Central | system, workload, spot |
| aks-workload-dr | DR standby | Canada East | system, workload |

Cluster configuration highlights:
- Private clusters with API server VNet integration
- Azure CNI overlay networking with Calico network policy
- Workload Identity Federation for all pod-level Azure access
- Cluster autoscaler configured for 3-50 nodes on workload pool
- KEDA for event-based scaling
- Vertical Pod Autoscaler for right-sizing resource requests

### GitOps with ArgoCD

Implemented App of Apps pattern with ArgoCD:

platform-repo/
- apps/
  - app-of-apps.yaml        (Root application)
  - platform/               (Platform services)
    - argocd.yaml
    - prometheus.yaml
    - grafana.yaml
    - cert-manager.yaml
  - workloads/              (Team applications)
    - team-payments/
    - team-catalog/
    - team-checkout/
- charts/                   (Shared Helm charts)
  - microservice/           (Golden path chart)
  - cronjob/

Every team deploys by submitting a PR to the platform repo.
ArgoCD syncs automatically on merge to main.

### Developer Golden Path

Created a standardized Helm chart that every team uses as their deployment template:

- Automatic Prometheus metrics scraping via ServiceMonitor
- Pre-configured HorizontalPodAutoscaler and PodDisruptionBudget
- Automatic sidecar injection for distributed tracing (OpenTelemetry)
- Network policies restricting ingress to only required services
- Resource requests and limits enforced via admission webhook
- Automatic TLS certificate provisioning via cert-manager

New service deployment time reduced from 3 weeks to 2 hours.

### Observability Stack

- Metrics: Prometheus + Thanos for long-term storage, Grafana dashboards
- Logs: Fluent Bit to Azure Log Analytics to Grafana
- Traces: OpenTelemetry Collector to Azure Monitor Application Insights
- Alerts: Alertmanager to PagerDuty (SEV-1/2) and Slack (SEV-3/4)

### Security Architecture

Supply chain security:
- All images built via GitHub Actions with Trivy scanning
- Images signed with Cosign - unsigned images rejected by admission controller
- Private Azure Container Registry with geo-replication

Runtime security:
- Falco for runtime threat detection
- Azure Policy enforcing pod security standards (restricted profile)
- Network policies - default deny, explicit allow only
- Secrets managed via Azure Key Vault with CSI driver

Access control:
- No direct kubectl access to production - all changes via GitOps
- Azure AD groups mapped to Kubernetes RBAC roles
- Audit logs shipped to Azure Sentinel for SIEM correlation

---

## Challenges and Solutions

### Challenge 1 - Developer Adoption Resistance

Development teams were resistant to giving up direct kubectl access to production.

Solution: Ran a 2-day internal platform engineering summit. Demonstrated
the golden path reducing deployment time from days to hours. Provided a
6-week transition period with platform team pairing support.
Adoption reached 100% within 10 weeks.

### Challenge 2 - Peak Season Scaling

Black Friday required 20x normal traffic capacity within minutes.

Solution: Implemented KEDA with Azure Service Bus triggers for
event-driven scaling. Pre-scaled critical services 2 hours before peak
using scheduled ScaledObjects. Spot node pool provided cost-effective
burst capacity. Conducted 3 load tests simulating Black Friday traffic
before go-live.

### Challenge 3 - Multi-Team Namespace Isolation

12 teams sharing clusters required strong isolation without complexity.

Solution: Implemented hierarchical namespaces (HNC) with team-level
resource quotas and network policies. Each team owns their namespace tree.
Platform team manages cluster-level resources only.

---

## Results

| Metric | Before | After | Improvement |
|---|---|---|---|
| Deployment failure rate | 40% | 3% | 92% reduction |
| Time to deploy new service | 3 weeks | 2 hours | 99% reduction |
| Black Friday availability | 96% (4hr outage) | 99.98% | No outage |
| Peak traffic handling | 5x normal | 20x normal | 4x capacity increase |
| Container CVEs in production | 3 critical/year | 0 | 100% reduction |
| Developer satisfaction score | 5.2/10 | 8.7/10 | 67% improvement |
| Platform team toil | 60% of time | 15% of time | 75% reduction |

---

## Key Lessons Learned

GitOps eliminates entire categories of incidents. Removing direct production
access eliminated configuration drift and unauthorized changes entirely.
Every production state is auditable via git history.

Golden paths must be genuinely better, not just mandated. Teams adopted
the platform chart because it saved them work - automatic TLS, metrics,
and tracing were features they wanted but could not build themselves.

Load test before peak season, not during. Three pre-Black Friday load
tests revealed two scaling bottlenecks that would have caused outages.

---

## Technologies Used

- Azure Kubernetes Service (AKS)
- ArgoCD, Helm, Kustomize
- KEDA, Cluster Autoscaler, VPA
- Prometheus, Thanos, Grafana, Alertmanager
- Fluent Bit, OpenTelemetry, Application Insights
- Falco, Cosign, Trivy
- cert-manager, External Secrets Operator
- Azure Container Registry, Azure Key Vault
- Terraform for all infrastructure
- GitHub Actions for CI/CD
