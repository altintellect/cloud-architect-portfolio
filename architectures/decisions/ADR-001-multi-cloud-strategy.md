# ADR-001: Multi-Cloud Strategy

**Date:** 2026-04-02
**Status:** Accepted

## Context

The organization requires a cloud strategy that avoids vendor lock-in and optimizes cost.

## Decision

Adopt multi-cloud with workload placement strategy:
- Azure for core platform (M365/Teams ecosystem)
- AWS for data and ML workloads
- GCP selectively for BigQuery analytics

## Consequences

- Vendor negotiation leverage
- Best-of-breed service selection
- Increased operational complexity
