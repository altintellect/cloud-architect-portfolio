# Senior Cloud Architect Portfolio

> Designing resilient, scalable, and secure cloud-native architectures 
> on Microsoft Azure with fully automated Infrastructure as Code pipelines.

## CI/CD Pipeline Status

## CI/CD Pipeline Status

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

<img width="125" height="302" alt="diagram(3)" src="https://github.com/user-attachments/assets/cc9aec7f-644d-4b1a-b104-eb6ffa6d112e" />
