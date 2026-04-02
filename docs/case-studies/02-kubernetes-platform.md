# Case Study 02: Enterprise Kubernetes Platform

**Industry:** Retail & E-Commerce  
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

The organization needed a standardized, self-service Kubernetes platform that
could handle 20x traffic spikes during peak seasons while reducing deployment
failures and improving developer experience.

---

## Problem Statement

The existing deployment landscape had grown organically over 5 years:

- 300+ microservices deployed inconsistently across VMs and early Kubernetes clusters
- 12 development teams each maintaining their own deployment scripts
- No standardized CI/CD pipeline — 40% of deployments required manual intervention
- Black Friday 2024 caused 4 hours of downtime due to inability to scale fast enough
- No GitOps — developers had direct kubectl access to production clusters
- Container images not scanned — 3 critical CVEs discovered in production in 2024
- Mean time to deploy a new service: 3 weeks

---

## Solution Architecture

### Platform Design Principles

Defined four core platform principles before writing a single line of code:

1. **Self-service** — development teams deploy without platform team involvement
2. **Paved road** — golden paths make the right way the easy way
3. **Secure by default** — security controls built in, not bolted on
4. **Observable by default** — every service gets logs, metrics, traces automatically

### AKS Cluster Architecture

Deployed a multi-cluster AKS architecture:

| Cluster | Purpose | Region | Node Pools |
|---|---|---|---|
| aks-platform-prod | Platform services (ArgoCD, monitoring) | Canada Central | system, platform |
| aks-workload-prod | Application workloads | Canada Central | system, workload, spot |
| aks-workload-dr | DR standby | Canada East | system, workload |

**Cluster configuration highlights:**
- Private clusters with API server VNet integration
- Azure CNI overlay networking with Calico network policy
- Workload Identity Federation for all pod-level Azure access
- Cluster autoscaler configured for 3–50 nodes on workload pool
- KEDA (Kubernetes Event Driven Autoscaling) for event-based scaling
- Vertical Pod Autoscaler for right-sizing resource requests

### GitOps with ArgoCD

Implemented App of Apps pattern with ArgoCD:
