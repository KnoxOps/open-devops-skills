Scan these 3 hosts for zombie resources using the zombie-orchestrator skill pipeline.

Target hosts:
- 172.30.0.41 (eval-bare-vm-1)
- 172.30.0.42 (eval-bare-vm-2)
- 172.30.0.43 (eval-bare-vm-3)

Access: ssh -i $SSH_KEY_PATH -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@<ip>
Cloud provider: none (bare metal SSH). Use SSH fallback for all signal collection.

Required skill execution order:
1. zombie-metrics-collector — discover 3 hosts, apply 3-signal coarse filter
2. zombie-resource-screener — score and rank candidates
3. zombie-deep-scanner — deep scan approved candidates (processes, ports, crontab, iftop, disk)

WRITE ALL OUTPUT to: ./run_output/

CRITICAL RULES:
- NO human-in-the-loop. Never ask for confirmation. Assume all answers are "yes" for disk usage scans and iftop installs.
- Do NOT isolate or delete any resources. Stop after deep scan.
- Use the Agent tool (subagent_type=general-purpose) to dispatch sub-agents.
- Read prompts/signals-compute.md for signal thresholds.
- Every signal output must include: value, threshold, threshold_unit, is_active, reliability, data_source.

Expected output files:
- run_output/candidates.json
- run_output/suspect_assessment.json
- run_output/analysis/deep_scan_172_30_0_41.json
- run_output/analysis/deep_scan_172_30_0_42.json
- run_output/analysis/deep_scan_172_30_0_43.json
