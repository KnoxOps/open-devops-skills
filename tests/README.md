# OpenDevOps Skills — E2E Tests

## VM-Only Scenario

Scans 3 known eval VMs (172.30.0.41/42/43) via SSH root access.
Validates Phase A (discover+filter), Phase B (score), Phase D (deep scan).
No isolation or deletion.

### Prerequisites

- SSH key at `~/.ssh/id_rsa` (or set `SSH_KEY_PATH` in `.env`)
- `goclaude` CLI available in PATH
- All 9 zombie skill directories at `../`
- Python 3 with `json` module for output verification

### Setup

```bash
cp .env.example .env
# Edit .env if needed (SSH_KEY_PATH default: ~/.ssh/id_rsa)
```

### Run

```bash
bash run-e2e.sh
```

### What It Tests

| Check | File |
|-------|------|
| 3-signal filter output | `run_output/candidates.json` |
| Score and ranking | `run_output/suspect_assessment.json` |
| Deep scan with iftop | `run_output/analysis/deep_scan_172_30_0_{41,42,43}.json` |
| Signal contract | Each signal has `threshold` + `is_active` fields |
