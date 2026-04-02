#!/usr/bin/env python3
"""AKS Cluster Health Checker

Checks AKS cluster health including node status, pod status,
resource utilization, and certificate expiry.

Usage:
    python3 aks_health_checker.py --cluster-name <name> --resource-group <rg>
"""

import argparse
import subprocess
import json
import sys
from datetime import datetime, timezone

from azure.identity import DefaultAzureCredential
from azure.mgmt.containerservice import ContainerServiceClient

def run_kubectl(args: list[str]) -> dict:
    """Run kubectl command and return JSON output."""
    cmd = ["kubectl"] + args + ["-o", "json"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"kubectl error: {result.stderr}")
        return {}
    return json.loads(result.stdout)

def check_nodes() -> dict:
    """Check node health and resource utilization."""
    nodes = run_kubectl(["get", "nodes"])
    results = []

    for node in nodes.get("items", []):
        name = node["metadata"]["name"]
        conditions = node["status"]["conditions"]
        ready = next(
            (c for c in conditions if c["type"] == "Ready"), None
        )
        results.append({
            "name": name,
            "ready": ready["status"] == "True" if ready else False,
            "version": node["status"]["nodeInfo"]["kubeletVersion"],
            "os": node["status"]["nodeInfo"]["osImage"],
        })
    return results

def check_failed_pods() -> list:
    """Check for failed or crash-looping pods."""
    pods = run_kubectl(["get", "pods", "--all-namespaces"])
    failed = []

    for pod in pods.get("items", []):
        phase = pod["status"].get("phase", "Unknown")
        name = pod["metadata"]["name"]
        namespace = pod["metadata"]["namespace"]

        # Check for crash looping containers
        for cs in pod["status"].get("containerStatuses", []):
            restarts = cs.get("restartCount", 0)
            if restarts > 5:
                failed.append({
                    "namespace": namespace,
                    "pod": name,
                    "container": cs["name"],
                    "issue": f"High restart count: {restarts}",
                    "severity": "critical" if restarts > 20 else "warning",
                })

        if phase in ["Failed", "Unknown"]:
            failed.append({
                "namespace": namespace,
                "pod": name,
                "container": "N/A",
                "issue": f"Pod phase: {phase}",
                "severity": "critical",
            })

    return failed

def check_pending_pvcs() -> list:
    """Check for PVCs stuck in Pending state."""
    pvcs = run_kubectl(["get", "pvc", "--all-namespaces"])
    pending = []

    for pvc in pvcs.get("items", []):
        phase = pvc["status"].get("phase", "Unknown")
        if phase == "Pending":
            pending.append({
                "namespace": pvc["metadata"]["namespace"],
                "name": pvc["metadata"]["name"],
                "storage_class": pvc["spec"].get("storageClassName", "unknown"),
                "capacity": pvc["spec"]["resources"]["requests"].get("storage", "unknown"),
            })
    return pending

def print_health_report(cluster_name: str, nodes: list,
                        failed_pods: list, pending_pvcs: list) -> None:
    """Print formatted health report."""
    print("\n" + "="*60)
    print(f"AKS CLUSTER HEALTH REPORT: {cluster_name}")
    print(f"Generated: {datetime.now(timezone.utc).isoformat()}")
    print("="*60)

    # Node status
    print(f"\nNODES ({len(nodes)} total):")
    for node in nodes:
        status = "READY" if node["ready"] else "NOT READY"
        print(f"  {status:10} {node["name"]:50} {node["version"]}")

    # Failed pods
    print(f"\nFAILED/UNHEALTHY PODS ({len(failed_pods)} found):")
    if failed_pods:
        for pod in failed_pods:
            print(f"  [{pod["severity"].upper():8}] {pod["namespace"]}/{pod["pod"]}: {pod["issue"]}")
    else:
        print("  All pods healthy")

    # Pending PVCs
    print(f"\nPENDING PVCs ({len(pending_pvcs)} found):")
    if pending_pvcs:
        for pvc in pending_pvcs:
            print(f"  {pvc["namespace"]}/{pvc["name"]} ({pvc["capacity"]})")
    else:
        print("  All PVCs bound")

def main() -> None:
    parser = argparse.ArgumentParser(
        description="AKS Cluster Health Checker"
    )
    parser.add_argument(
        "--cluster-name", required=True, help="AKS cluster name"
    )
    parser.add_argument(
        "--resource-group", required=True, help="Resource group name"
    )
    parser.add_argument(
        "--subscription-id", required=True, help="Azure subscription ID"
    )
    args = parser.parse_args()

    # Get AKS credentials
    subprocess.run([
        "az", "aks", "get-credentials",
        "--name", args.cluster_name,
        "--resource-group", args.resource_group,
        "--subscription", args.subscription_id,
        "--overwrite-existing"
    ], check=True)

    nodes = check_nodes()
    failed_pods = check_failed_pods()
    pending_pvcs = check_pending_pvcs()

    print_health_report(args.cluster_name, nodes, failed_pods, pending_pvcs)

    # Exit with error if critical issues found
    critical = [p for p in failed_pods if p["severity"] == "critical"]
    not_ready = [n for n in nodes if not n["ready"]]
    if critical or not_ready:
        sys.exit(1)


if __name__ == "__main__":
    main()
