#!/usr/bin/env python3
"""Azure Cost Report Generator

Generates monthly cost reports by subscription, resource group,
and tag for FinOps showback reporting.

Usage:
    python3 cost_report_generator.py --subscription-id <sub-id>
    python3 cost_report_generator.py --subscription-id <sub-id> --month 2026-03
"""

import argparse
import json
from datetime import datetime, date
from calendar import monthrange

from azure.identity import DefaultAzureCredential
from azure.mgmt.costmanagement import CostManagementClient
from azure.mgmt.costmanagement.models import (
    QueryDefinition,
    QueryTimePeriod,
    QueryDataset,
    QueryAggregation,
    QueryGrouping,
    TimeframeType,
)

def get_month_range(month_str: str) -> tuple[str, str]:
    """Get start and end dates for a given month (YYYY-MM)."""
    year, month = map(int, month_str.split("-"))
    start = date(year, month, 1)
    end = date(year, month, monthrange(year, month)[1])
    return start.isoformat(), end.isoformat()

def query_costs_by_resource_group(
    client: CostManagementClient,
    scope: str,
    start_date: str,
    end_date: str,
) -> list[dict]:
    """Query costs grouped by resource group."""
    query = QueryDefinition(
        type="ActualCost",
        timeframe=TimeframeType.CUSTOM,
        time_period=QueryTimePeriod(
            from_property=start_date,
            to=end_date,
        ),
        dataset=QueryDataset(
            granularity="None",
            aggregation={
                "totalCost": QueryAggregation(
                    name="Cost",
                    function="Sum",
                )
            },
            grouping=[
                QueryGrouping(type="Dimension", name="ResourceGroup"),
                QueryGrouping(type="Dimension", name="ServiceName"),
            ],
        ),
    )

    result = client.query.usage(scope=scope, parameters=query)
    rows = []
    columns = [col.name for col in result.columns]

    for row in result.rows:
        rows.append(dict(zip(columns, row)))

    return sorted(rows, key=lambda x: x.get("Cost", 0), reverse=True)

def query_costs_by_tag(
    client: CostManagementClient,
    scope: str,
    start_date: str,
    end_date: str,
    tag_name: str = "CostCenter",
) -> list[dict]:
    """Query costs grouped by tag value."""
    query = QueryDefinition(
        type="ActualCost",
        timeframe=TimeframeType.CUSTOM,
        time_period=QueryTimePeriod(
            from_property=start_date,
            to=end_date,
        ),
        dataset=QueryDataset(
            granularity="None",
            aggregation={
                "totalCost": QueryAggregation(
                    name="Cost",
                    function="Sum",
                )
            },
            grouping=[
                QueryGrouping(type="TagKey", name=tag_name),
            ],
        ),
    )

    result = client.query.usage(scope=scope, parameters=query)
    rows = []
    columns = [col.name for col in result.columns]

    for row in result.rows:
        rows.append(dict(zip(columns, row)))

    return sorted(rows, key=lambda x: x.get("Cost", 0), reverse=True)

def print_cost_report(
    subscription_id: str,
    month: str,
    by_rg: list[dict],
    by_cost_center: list[dict],
) -> None:
    """Print formatted cost report."""
    print("\n" + "="*60)
    print(f"AZURE COST REPORT - {month}")
    print(f"Subscription: {subscription_id}")
    print("="*60)

    total = sum(r.get("Cost", 0) for r in by_rg)
    print(f"\nTotal Spend: ${total:,.2f} CAD")

    print("\nTOP 10 RESOURCE GROUPS BY COST:")
    print(f"  {"Resource Group":<40} {"Service":<30} {"Cost":>10}")
    print(f"  {"-"*40} {"-"*30} {"-"*10}")
    for row in by_rg[:10]:
        rg = str(row.get("ResourceGroup", "Unknown"))[:40]
        svc = str(row.get("ServiceName", "Unknown"))[:30]
        cost = row.get("Cost", 0)
        print(f"  {rg:<40} {svc:<30} ${cost:>9,.2f}")

    print("\nCOST BY COST CENTER:")
    print(f"  {"Cost Center":<30} {"Cost":>10} {"% of Total":>12}")
    print(f"  {"-"*30} {"-"*10} {"-"*12}")
    for row in by_cost_center:
        cc = str(row.get("CostCenter", "Untagged"))[:30]
        cost = row.get("Cost", 0)
        pct = (cost / total * 100) if total > 0 else 0
        print(f"  {cc:<30} ${cost:>9,.2f} {pct:>11.1f}%")

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Azure Cost Report Generator"
    )
    parser.add_argument(
        "--subscription-id", required=True, help="Azure subscription ID"
    )
    parser.add_argument(
        "--month",
        default=datetime.now().strftime("%Y-%m"),
        help="Month to report on (YYYY-MM), defaults to current month",
    )
    parser.add_argument(
        "--output-format",
        choices=["text", "json"],
        default="text",
    )
    args = parser.parse_args()

    credential = DefaultAzureCredential()
    client = CostManagementClient(credential)
    scope = f"/subscriptions/{args.subscription_id}"
    start_date, end_date = get_month_range(args.month)

    print(f"Generating cost report for {args.month}...")
    by_rg = query_costs_by_resource_group(client, scope, start_date, end_date)
    by_cc = query_costs_by_tag(client, scope, start_date, end_date, "CostCenter")

    if args.output_format == "json":
        print(json.dumps({
            "subscription_id": args.subscription_id,
            "month": args.month,
            "by_resource_group": by_rg,
            "by_cost_center": by_cc,
        }, indent=2, default=str))
    else:
        print_cost_report(args.subscription_id, args.month, by_rg, by_cc)


if __name__ == "__main__":
    main()
