# Terraform Module: AKS Cluster

A production-grade Azure Kubernetes Service (AKS) module with enterprise
security, observability, and high availability built in.

## Features

- Private cluster with API server VNet integration
- Azure CNI with overlay networking mode
- Workload Identity Federation (no pod-managed identities)
- Three node pools: system, workload, and spot
- Cluster autoscaler on workload and spot pools
- Availability zone spread across zones 1, 2, 3
- Microsoft Defender for Containers
- Azure Policy add-on for compliance enforcement
- Key Vault Secrets Provider with auto-rotation
- Log Analytics integration with full diagnostic settings
- Automatic patch upgrades with maintenance windows

## Usage
