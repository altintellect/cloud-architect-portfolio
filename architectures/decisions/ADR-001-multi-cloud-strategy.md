# ADR-001: Multi-Cloud Strategy

**Date:** 2026-04-02
**Status:** Accepted

## Context

The organization requires a cloud strategy that avoids vendor lock-in, optimizes
cost, and leverages best-of-breed services across cloud providers.

## Decision Drivers

- Regulatory requirements mandate data residency flexibility
- Different business units have existing investments in AWS and Azure
- Need for competitive pricing leverage with cloud vendors
- Best-of-breed service selection across providers

## Considered Options

1. Single cloud (AWS)
2. Single cloud (Azure)
3. Multi-cloud with workload placement strategy

## Decision Outcome

Chosen option: Multi-cloud with workload placement strategy.

- Azure for core platform services (aligned with M365/Teams ecosystem)
- AWS for data and ML workloads (SageMaker, Redshift)
- GCP used selectively for BigQuery analytics

## Positive Consequences

- Vendor negotiation leverage
- Best-of-breed service selection
- Regulatory flexibility
- Reduced risk of vendor lock-in

## Negative Consequences

- Increased operational complexity
- Requires unified IaC and observability strategy
- Higher skill set requirements for engineering teams
- More complex cost governance across providers

## Implementation Notes

- Terraform used as single IaC tool across all three providers
- Centralized observability via OpenTelemetry collector
- Unified identity strategy: Azure AD as primary IdP with federation
- FinOps tooling aggregates costs across all cloud providers

## Links

- Azure Landing Zone: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/
- AWS Well-Architected: https://aws.amazon.com/architecture/well-architected/
- Google Cloud Architecture Framework: https://cloud.google.com/architecture/framework
