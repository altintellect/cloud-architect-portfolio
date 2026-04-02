# Azure Security Baseline

## Identity
- All service principals use OIDC (no client secrets)
- Managed Identities preferred for Azure-to-Azure auth
- PIM required for all privileged roles

## Network
- Hub-spoke topology with Azure Firewall Premium
- No public IPs on workload VMs
- Private Endpoints for all PaaS services
- DDoS Protection Standard on hub VNet

## Data
- All storage encrypted with Customer Managed Keys
- TLS 1.2 minimum, TLS 1.3 preferred
- Azure Key Vault for all secrets and certificates

## Monitoring
- All resources ship logs to centralized Log Analytics
- Microsoft Defender for Cloud on Standard tier
- Weekly CSPM score review
