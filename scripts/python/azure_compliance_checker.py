#!/usr/bin/env python3
"""Azure Resource Compliance Checker

Checks Azure resources for compliance with tagging standards,
security baselines, and cost governance policies.

Usage:
    python3 azure_compliance_checker.py --subscription-id <sub-id>
    python3 azure_compliance_checker.py --subscription-id <sub-id> --output-format json
"""

import argparse
import json
import sys
from dataclasses import dataclass, field
from datetime import datetime
from typing import Any

from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.storage import StorageManagementClient

# ── Configuration ─────────────────────────────────────────────────────────────

REQUIRED_TAGS = ["Environment", "CostCenter", "Owner", "Project", "ManagedBy"]

ALLOWED_VM_SIZES_PROD = [
    "Standard_D4s_v5",
    "Standard_D8s_v5",
    "Standard_D16s_v5",
    "Standard_E4s_v5",
    "Standard_E8s_v5",
]

# ── Data Classes ──────────────────────────────────────────────────────────────

@dataclass
class ComplianceIssue:
    resource_id: str
    resource_type: str
    resource_name: str
    issue_type: str
    severity: str
    description: str
    remediation: str

@dataclass
class ComplianceReport:
    subscription_id: str
    generated_at: str
    total_resources: int = 0
    compliant_resources: int = 0
    issues: list = field(default_factory=list)

    @property
    def compliance_score(self) -> float:
        if self.total_resources == 0:
            return 100.0
        return round((self.compliant_resources / self.total_resources) * 100, 2)

    @property
    def critical_issues(self) -> list:
        return [i for i in self.issues if i.severity == "critical"]

    @property
    def high_issues(self) -> list:
        return [i for i in self.issues if i.severity == "high"]

# ── Compliance Checks ─────────────────────────────────────────────────────────

class AzureComplianceChecker:
    """Main compliance checker class."""

    def __init__(self, subscription_id: str):
        self.subscription_id = subscription_id
        self.credential = DefaultAzureCredential()
        self.resource_client = ResourceManagementClient(
            self.credential, subscription_id
        )
        self.compute_client = ComputeManagementClient(
            self.credential, subscription_id
        )
        self.storage_client = StorageManagementClient(
            self.credential, subscription_id
        )
        self.report = ComplianceReport(
            subscription_id=subscription_id,
            generated_at=datetime.utcnow().isoformat(),
        )

    def check_tags(self, resource: Any) -> list[ComplianceIssue]:
        """Check resource for required tags."""
        issues = []
        tags = resource.tags or {}
        missing_tags = [t for t in REQUIRED_TAGS if t not in tags]

        if missing_tags:
            issues.append(ComplianceIssue(
                resource_id=resource.id,
                resource_type=resource.type,
                resource_name=resource.name,
                issue_type="missing_tags",
                severity="high",
                description=f"Missing required tags: {", ".join(missing_tags)}",
                remediation="Add missing tags via Terraform or Azure CLI: "
                           f"az resource tag --ids {resource.id} --tags "
                           + " ".join(f"{t}=<value>" for t in missing_tags),
            ))
        return issues

    def check_storage_account(self, account: Any) -> list[ComplianceIssue]:
        """Check storage account security configuration."""
        issues = []

        if account.allow_blob_public_access:
            issues.append(ComplianceIssue(
                resource_id=account.id,
                resource_type="Microsoft.Storage/storageAccounts",
                resource_name=account.name,
                issue_type="public_blob_access",
                severity="critical",
                description="Storage account allows public blob access",
                remediation=f"az storage account update --name {account.name} "
                           "--allow-blob-public-access false",
            ))

        if account.minimum_tls_version not in ["TLS1_2", "TLS1_3"]:
            issues.append(ComplianceIssue(
                resource_id=account.id,
                resource_type="Microsoft.Storage/storageAccounts",
                resource_name=account.name,
                issue_type="weak_tls",
                severity="high",
                description=f"TLS version {account.minimum_tls_version} is below minimum TLS1_2",
                remediation=f"az storage account update --name {account.name} "
                           "--min-tls-version TLS1_2",
            ))

        if not account.enable_https_traffic_only:
            issues.append(ComplianceIssue(
                resource_id=account.id,
                resource_type="Microsoft.Storage/storageAccounts",
                resource_name=account.name,
                issue_type="http_allowed",
                severity="critical",
                description="Storage account allows HTTP traffic",
                remediation=f"az storage account update --name {account.name} "
                           "--https-only true",
            ))

        return issues

    def run_checks(self) -> ComplianceReport:
        """Run all compliance checks and return report."""
        print(f"Running compliance checks for subscription: {self.subscription_id}")

        # Check all resources for tags
        resources = list(self.resource_client.resources.list())
        self.report.total_resources = len(resources)

        for resource in resources:
            resource_issues = self.check_tags(resource)
            self.report.issues.extend(resource_issues)
            if not resource_issues:
                self.report.compliant_resources += 1

        # Check storage accounts
        storage_accounts = list(self.storage_client.storage_accounts.list())
        for account in storage_accounts:
            issues = self.check_storage_account(account)
            self.report.issues.extend(issues)

        return self.report

# ── Output Formatters ─────────────────────────────────────────────────────────

def print_text_report(report: ComplianceReport) -> None:
    """Print human-readable compliance report."""
    print("\n" + "="*60)
    print("AZURE COMPLIANCE REPORT")
    print("="*60)
    print(f"Subscription: {report.subscription_id}")
    print(f"Generated:    {report.generated_at}")
    print(f"\nCompliance Score: {report.compliance_score}%")
    print(f"Total Resources:  {report.total_resources}")
    print(f"Compliant:        {report.compliant_resources}")
    print(f"Issues Found:     {len(report.issues)}")
    print(f"  Critical: {len(report.critical_issues)}")
    print(f"  High:     {len(report.high_issues)}")

    if report.issues:
        print("\n" + "-"*60)
        print("ISSUES FOUND:")
        print("-"*60)
        for issue in sorted(report.issues, key=lambda x: x.severity):
            print(f"\n[{issue.severity.upper()}] {issue.resource_name}")
            print(f"  Type:        {issue.resource_type}")
            print(f"  Issue:       {issue.description}")
            print(f"  Remediation: {issue.remediation}")

def print_json_report(report: ComplianceReport) -> None:
    """Print JSON compliance report."""
    output = {
        "subscription_id": report.subscription_id,
        "generated_at": report.generated_at,
        "compliance_score": report.compliance_score,
        "total_resources": report.total_resources,
        "compliant_resources": report.compliant_resources,
        "issues": [
            {
                "resource_name": i.resource_name,
                "resource_type": i.resource_type,
                "issue_type": i.issue_type,
                "severity": i.severity,
                "description": i.description,
                "remediation": i.remediation,
            }
            for i in report.issues
        ],
    }
    print(json.dumps(output, indent=2))

# ── Main ──────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Azure Resource Compliance Checker"
    )
    parser.add_argument(
        "--subscription-id",
        required=True,
        help="Azure subscription ID to check",
    )
    parser.add_argument(
        "--output-format",
        choices=["text", "json"],
        default="text",
        help="Output format (default: text)",
    )
    args = parser.parse_args()

    checker = AzureComplianceChecker(args.subscription_id)
    report = checker.run_checks()

    if args.output_format == "json":
        print_json_report(report)
    else:
        print_text_report(report)

    # Exit with non-zero code if critical issues found
    if report.critical_issues:
        sys.exit(1)


if __name__ == "__main__":
    main()
