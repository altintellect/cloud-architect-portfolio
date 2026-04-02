# ADR-002: Kubernetes Platform Decision

**Date:** 2026-04-02
**Status:** Accepted

## Context

The organization requires a managed Kubernetes platform to run containerized workloads
at scale. The platform must support multi-region deployments, enterprise security
requirements, and integrate with existing cloud infrastructure.

## Decision Drivers

- Existing Azure investment and M365/Teams ecosystem alignment
- Enterprise security and compliance requirements (SOC2, ISO27001)
- Team expertise and available skill sets
- Total cost of ownership
- Managed control plane to reduce operational overhead
- Integration with existing CI/CD pipelines and GitOps tooling

## Considered Options

1. Azure Kubernetes Service (AKS)
2. Amazon Elastic Kubernetes Service (EKS)
3. Google Kubernetes Engine (GKE)
4. Self-managed Kubernetes on VMs

## Decision Outcome

**Chosen option:** Azure Kubernetes Service (AKS)

AKS is selected as the primary Kubernetes platform due to deep integration with
existing Azure infrastructure, Azure AD for RBAC, Azure CNI networking, and
native support for Azure Policy and Defender for Containers.

### Positive Consequences

- Native Azure AD integration for RBAC and workload identity
- Azure CNI provides enterprise-grade networking with VNet integration
- Defender for Containers provides runtime security out of the box
- Azure Monitor and Container Insights for observability
- Reduced operational overhead with managed control plane
- Cost optimization via spot node pools and cluster autoscaler

### Negative Consequences

- Increased dependency on Azure ecosystem
- Cross-cloud workload portability requires additional abstraction layer
- AKS version upgrades require careful planning and testing

## Pros and Cons of the Options

### Option 1 — Azure Kubernetes Service (AKS)

- Chosen option
- Native Azure AD and Azure CNI integration
- Defender for Containers included
- Managed control plane, automatic upgrades
- Strong GitOps support via Azure Arc and ArgoCD

### Option 2 — Amazon Elastic Kubernetes Service (EKS)

- Best choice if primary workloads are on AWS
- Strong integration with AWS IAM and VPC CNI
- More manual configuration required for enterprise features
- Higher cost for managed node groups

### Option 3 — Google Kubernetes Engine (GKE)

- Most mature managed Kubernetes offering
- Autopilot mode reduces operational overhead significantly
- Less relevant given existing Azure/AWS investment
- Strong for ML workloads with GPU node support

### Option 4 — Self-managed Kubernetes on VMs

- Maximum flexibility and control
- Significantly higher operational overhead
- Not recommended for enterprise production workloads
- Requires dedicated platform engineering team

## Implementation Notes

- AKS clusters use Azure CNI with dynamic IP allocation
- System node pool: Standard_D4s_v5, min 3 nodes across availability zones
- Workload node pool: Standard_D8s_v5 with cluster autoscaler (3-10 nodes)
- Spot node pool for non-critical batch workloads (cost optimization)
- Private cluster with API server VNet integration
- GitOps via ArgoCD deployed in dedicated argocd namespace
- Workload Identity Federation replaces pod-managed identities

## Links

- [AKS Best Practices](https://learn.microsoft.com/en-us/azure/aks/best-practices)
- [AKS Baseline Architecture](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks)
- [ArgoCD on AKS](https://argo-cd.readthedocs.io/en/stable/)
