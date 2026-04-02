# Runbook: Cloud Infrastructure Incident Response

**Version:** 1.0
**Owner:** Cloud Architecture Team
**Review Cycle:** Quarterly

---

## Severity Definitions

| Severity | Impact | Response Time | Escalation |
|---|---|---|---|
| SEV-1 | Full outage, revenue impact | 15 min | Immediate exec notification |
| SEV-2 | Partial outage, degraded service | 30 min | Engineering lead |
| SEV-3 | Minor degradation, workaround exists | 2 hours | On-call engineer |
| SEV-4 | Informational, no user impact | Next business day | Ticket only |

---

## Initial Response Checklist

### Step 1 - Acknowledge (0-5 min)
- Acknowledge PagerDuty/OpsGenie alert
- Join incident Slack channel: #incident-YYYY-MM-DD
- Assign Incident Commander (IC) and Communications Lead
- Start incident timeline document

### Step 2 - Assess (5-15 min)
- Identify affected services and regions
- Check cloud provider status pages:
  - Azure: https://status.azure.com
  - AWS: https://health.aws.amazon.com
  - GCP: https://status.cloud.google.com
- Review monitoring dashboards (Grafana/Datadog)
- Check recent deployments in ArgoCD/GitHub Actions

### Step 3 - Contain (15-30 min)
- Enable maintenance mode if applicable
- Roll back last deployment if correlated
- Scale out affected services if resource exhaustion
- Activate DR/failover if primary region is down

### Step 4 - Communicate
- Post initial status to status page (Statuspage.io)
- Notify stakeholders via email/Teams
- Update every 30 minutes until resolved

### Step 5 - Resolve and Recover
- Confirm service restoration with monitoring
- Gradually restore traffic (canary to 100%)
- Verify all health checks pass
- Close incident and schedule post-mortem

---

## Common Scenarios

### Scenario: AKS Node Pool Exhaustion

Check node status:
kubectl get nodes -o wide

Check pending pods:
kubectl get pods --all-namespaces --field-selector=status.phase=Pending

Scale node pool (Azure):
az aks nodepool scale \
  --resource-group rg-aks-prod \
  --cluster-name aks-prod-001 \
  --name workloads \
  --node-count 10

### Scenario: Azure Firewall Blocking Traffic

Check firewall logs:
az monitor log-analytics query \
  --workspace <workspace-id> \
  --analytics-query "AzureDiagnostics | where Category == 'AzureFirewallNetworkRule' | where action_s == 'Deny' | take 50"

### Scenario: Terraform State Lock

Force unlock state:
terraform force-unlock <LOCK_ID>

Or via Azure Storage:
az storage blob lease break \
  --blob-name terraform.tfstate \
  --container-name tfstate \
  --account-name <storage-account>

---

## Post-Mortem Template

Incident: INC-XXXX
Date: YYYY-MM-DD
Duration: X hours Y minutes
Severity: SEV-X

### Timeline

| Time (UTC) | Event |
|---|---|
| HH:MM | Alert triggered |
| HH:MM | IC assigned |
| HH:MM | Root cause identified |
| HH:MM | Fix deployed |
| HH:MM | Service restored |

### Root Cause
Describe the technical root cause.

### Contributing Factors
What conditions allowed this to happen.

### Action Items

| Action | Owner | Due Date | Priority |
|---|---|---|---|
| Action 1 | Team | YYYY-MM-DD | High |

### Lessons Learned
What went well, what did not, what to improve.

---

## Related Documents

- Architecture Overview: docs/architecture-overview.md
- Azure Security Baseline: security/baselines/azure-security-baseline.md
- Prometheus Alert Rules: monitoring/prometheus/alert-rules.yml
