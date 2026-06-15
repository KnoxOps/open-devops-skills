---
name: zombie-resource-scanner
description: Scan cloud infrastructure for zombie/idle resources, classify by utilization patterns, protect scheduled workloads, and generate cost optimization recommendations. Supports multi-cloud (AWS, Alibaba Cloud) with cost-ranking and utilization-based classification.
---

# Zombie Resource Scanner

## Objective

Identify and classify cloud resources that are idle, underutilized, or candidates for scheduled start-stop — what we call "zombie resources" — that silently drain cloud budgets. Generate prioritized, actionable cost optimization recommendations.

## Core Principles

1. **Cost-first scanning**: Rank resources by monthly cost, scan top N to maximize ROI
2. **Scheduled task protection**: Detect crontab/systemd timer/K8s CronJob; resources with active schedules are never recommended for deletion
3. **Multi-cloud support**: AWS, Alibaba Cloud (Azure WIP)
4. **Deterministic + LLM hybrid**: Scripted classification for clear-cut cases, LLM reasoning for edge cases
5. **Read-only safety**: No destructive operations — scan and recommend only

## Pipeline

```
Cost Ranking → Load Analysis → Scheduled Task Detection → Classification → Recommendations
```

### Classification Rules

| Category | Condition | Recommendation |
|----------|-----------|----------------|
| `zombie` | CPU avg < 5% AND memory avg < 10%, no active schedule | Delete |
| `underutilized` | CPU 5-20% OR memory 10-30%, no active schedule | Downsize |
| `scheduled` | Low utilization but has active periodic tasks | Scheduled start-stop |
| `normal` | All other cases | No action |

### Scheduled Task Protection

Resources with cron/systemd timer/K8s CronJob frequency ≥ once/week receive `has_active_schedule: true` and are reclassified to `scheduled` regardless of utilization metrics.

## Supported Resource Types

| Type | Dimensions | Cloud Providers |
|------|-----------|-----------------|
| Compute (EC2/ECS/VM) | CPU, memory, network, login history, cron tasks | AWS, Alibaba |
| Storage (EBS/Disk) | Mount status, IO metrics, snapshot age | AWS, Alibaba |
| Database (RDS) | Connections, QPS, storage growth, backup access | AWS, Alibaba |
| Load Balancer | Traffic, backend health, cost utilization | AWS, Alibaba |
| Kubernetes (Workload/Service) | Replica status, traffic, deploy age, HPA activity | Generic K8s |

## Input Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `cloud_provider` | string | Yes | aws / aliyun / azure |
| `region` | string | Yes | Target region |
| `top_n` | integer | No | Top N highest-cost resources (default: 100) |
| `resource_types` | array | No | Filter by type (default: all) |
| `scan_mode` | string | No | `full` (multi-round pipeline) or `quick` (cost-focused, < 3 min) |

## Output

All output written to the run directory:

| File | Description |
|------|-------------|
| `cost_ranking.json` | Top N resources by monthly cost |
| `utilization_metrics.json` | Raw monitoring metrics (30-day) |
| `utilization_analysis.json` | Classified resources with schedule annotations |
| `cost_optimization_recommendations.json` | Prioritized recommendations with estimated savings |

## Error Handling

| Scenario | Action |
|----------|--------|
| Billing API unavailable | Terminate, report error |
| Monitoring API partial failure | Skip failed resources, continue |
| SSH connection failure (cron check) | Annotate `cron_check_skipped`, continue |
| K8s API unavailable | Skip K8s resources, continue |

## Acceptance Criteria

- [ ] `cost_ranking.json` sorted by monthly_cost descending
- [ ] Every resource has `resource_id`, `monthly_cost`, `resource_type`
- [ ] Resources with `has_active_schedule: true` have no `delete` recommendations
- [ ] `utilization_analysis.json` contains `category` and `has_active_schedule` per resource
- [ ] Recommendations sorted by `estimated_savings` descending
