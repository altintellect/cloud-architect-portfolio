# Senior Cloud Architect Portfolio

> Designing resilient, scalable, and secure cloud-native architectures 
> on Microsoft Azure with fully automated Infrastructure as Code pipelines.


![Infrastructure CI](https://github.com/altintellect/cloud-architect-portfolio/actions/workflows/infrastructure-ci.yml/badge.svg)
![AzDemo Deploy](https://github.com/altintellect/cloud-architect-portfolio/actions/workflows/azdemo-deploy.yml/badge.svg)
![AzLearn Deploy](https://github.com/altintellect/cloud-architect-portfolio/actions/workflows/azlearn-test-deploy.yml/badge.svg)

---

## About

This repository is a living portfolio of cloud architecture patterns, 
IaC templates, CI/CD pipelines, runbooks, and best practices. Every 
Azure resource shown here was deployed automatically through code — 
nothing built by clicking in the portal.

---

## Architecture Overview
The pipeline connects four layers — local development in VS Code,
source control on GitHub, automated deployment via GitHub Actions,
and live infrastructure on Microsoft Azure.
Code is written locally, pushed to GitHub, which triggers GitHub Actions
to run Terraform automatically. Terraform reads and writes state to Azure
Blob Storage and deploys all resources to Azure. No manual steps required
after the initial push.


<img width="190" height="453" alt="diagram(3)" src="https://github.com/user-attachments/assets/cc9aec7f-644d-4b1a-b104-eb6ffa6d112e" />


---

## Repository Structure

    cloud-architect-portfolio/
    ├── .github/workflows/
    │   ├── infrastructure-ci.yml
    │   ├── azlearn-test-deploy.yml
    │   └── azdemo-deploy.yml
    ├── iac/
    │   ├── azlearn-test/
    │   └── azdemo/
    ├── ci-cd/
    ├── architectures/decisions/
    ├── kubernetes/
    ├── monitoring/prometheus/
    ├── scripts/
    ├── security/
    └── runbooks/

---

## Featured Project — Azure Demo Environment

A fully automated Azure environment deployed through Terraform and GitHub Actions. Zero manual portal clicks.

| Resource | Name | Details |
|---|---|---|
| Resource Group | rg-azdemo-test | Canada Central |
| Virtual Network | vnet-azdemo-001 | 10.1.0.0/16 |
| Subnet | snet-azdemo-001 | 10.1.1.0/24 |
| Network Security Group | nsg-azdemo-001 | SSH restricted to known IPs |
| Virtual Machine | vm-azdemo-001 | Ubuntu 22.04 LTS |
| Storage Account | stazdemo001ca | Terraform remote state backend |
| Public IP | pip-azdemo-001 | Static Standard SKU |

---

## Core Competencies

| Domain | Technologies |
|---|---|
| Cloud Platforms | Microsoft Azure, AWS, GCP |
| Infrastructure as Code | Terraform, Bicep, Pulumi |
| CI/CD | GitHub Actions, ArgoCD |
| Configuration Management | Ansible |
| Containers | Kubernetes, Docker, Helm |
| Security | Zero Trust, NSG, RBAC, CSPM |
| Observability | Prometheus, Grafana, OpenTelemetry |
| Scripting | Python, Bash, PowerShell |

---

## Architecture Principles

1. **Everything as Code** — If it exists in Azure, it exists in Terraform first
2. **Security First** — Least privilege, restricted network access, zero hardcoded secrets
3. **Design for Failure** — Resilient architectures with redundancy built in
4. **Automation Over Manual** — GitHub Actions removes human error from deployments
5. **Observability First** — Monitoring and alerting built alongside infrastructure
6. **Cost Awareness** — Right-sized resources with tagging for cost attribution

---

## Environments

| Environment | Purpose | State Backend |
|---|---|---|
| azlearn-test | Initial learning environment | Azure Blob Storage |
| azdemo | Full demo with VM and networking | Azure Blob Storage |

---

*All Azure infrastructure deployed to Canada Central region.*
*Every resource shown has been successfully deployed through automated pipelines.*

---

## License

MIT License
---


