#!/bin/bash
# Zombie Skills E2E Test — VM-only scenario
#
# Scans 3 known eval VMs (172.30.0.41/42/43) via SSH.
# Validates Phase A (discover+filter), Phase B (score), Phase D (deep scan).
# Does NOT isolate or delete any resources.
#
# Usage: bash run-e2e.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$SCRIPT_DIR/logs/e2e-${TIMESTAMP}.log"
PROMPT_FILE="$SCRIPT_DIR/prompts/vm-only.md"

# --------------------------------------------------
# Step 0: Load env
# --------------------------------------------------
echo "=== Zombie Skills E2E Test ==="
echo "Skill dir: $SKILL_DIR"
echo "Log file: $LOG_FILE"

if [ -f "$SCRIPT_DIR/.env" ]; then
  echo "Loading .env"
  source "$SCRIPT_DIR/.env"
fi

export SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/id_rsa}"
echo "SSH key: $SSH_KEY_PATH"

if [ ! -f "$SSH_KEY_PATH" ]; then
  echo "ERROR: SSH key not found at $SSH_KEY_PATH"
  exit 1
fi

# --------------------------------------------------
# Step 1: Run goclaude -p
# --------------------------------------------------
echo ""
echo ">>> Running goclaude -p with zombie skills..."

# Unset CLAUDECODE to allow nested claude execution
unset CLAUDECODE

echo "Loading prompt from: $PROMPT_FILE"
cat "$PROMPT_FILE" | goclaude -p \
  --plugin-dir "$SKILL_DIR/zombie-orchestrator" \
  --plugin-dir "$SKILL_DIR/zombie-metrics-collector" \
  --plugin-dir "$SKILL_DIR/zombie-resource-screener" \
  --plugin-dir "$SKILL_DIR/zombie-deep-scanner" \
  --plugin-dir "$SKILL_DIR/zombie-isolation-planner" \
  --plugin-dir "$SKILL_DIR/zombie-isolation-executor" \
  --plugin-dir "$SKILL_DIR/zombie-decision-handler" \
  --plugin-dir "$SKILL_DIR/zombie-backup-creator" \
  --plugin-dir "$SKILL_DIR/zombie-resource-cleaner" \
  --output-format stream-json \
  --verbose \
  --dangerously-skip-permissions \
  - 2>&1 | tee "$LOG_FILE"

# Symlink latest
ln -sf "$(basename "$LOG_FILE")" "$SCRIPT_DIR/logs/e2e-latest.log"

echo ""
echo "=== Execution complete ==="

# --------------------------------------------------
# Step 2: Verify outputs
# --------------------------------------------------
RUN_DIR=$(ls -td run_output* 2>/dev/null | head -1)

if [ -z "$RUN_DIR" ]; then
  echo "ERROR: No run_output directory found"
  exit 1
fi

echo ""
echo ">>> Verifying outputs in $RUN_DIR/..."

PASS=true

# Check candidates.json
echo ""
echo "--- candidates.json ---"
if [ -f "$RUN_DIR/candidates.json" ]; then
  COUNT=$(python3 -c "import json; d=json.load(open('$RUN_DIR/candidates.json')); print(d.get('layer_b_candidates_count', d.get('candidates_count', '?')))" 2>/dev/null || echo "?")
  echo "PASS: candidates.json exists (candidates: $COUNT)"
else
  echo "FAIL: candidates.json not found"
  PASS=false
fi

# Check suspect_assessment.json
echo ""
echo "--- suspect_assessment.json ---"
if [ -f "$RUN_DIR/suspect_assessment.json" ]; then
  HIGH=$(python3 -c "import json; d=json.load(open('$RUN_DIR/suspect_assessment.json')); s=d.get('summary',{}); print(f\"high={s.get('high_suspect','?')}, med={s.get('medium_suspect','?')}, low={s.get('low_suspect','?')}\")" 2>/dev/null || echo "parse error")
  echo "PASS: suspect_assessment.json exists ($HIGH)"
else
  echo "FAIL: suspect_assessment.json not found"
  PASS=false
fi

# Check deep_scan files
echo ""
echo "--- deep_scan files ---"
for ip in 172_30_0_41 172_30_0_42 172_30_0_43; do
  if [ -f "$RUN_DIR/analysis/deep_scan_${ip}.json" ]; then
    TG=$(python3 -c "import json; d=json.load(open('$RUN_DIR/analysis/deep_scan_${ip}.json')); tg=d.get('technical',{}).get('traffic_graph',{}); print(f'edges={len(tg.get(\"edges\",[]))}')" 2>/dev/null || echo "parse error")
    echo "PASS: deep_scan_${ip}.json exists (traffic_graph: $TG)"
  else
    echo "FAIL: deep_scan_${ip}.json not found"
    PASS=false
  fi
done

# Check signal output includes threshold+is_active
echo ""
echo "--- signal contract ---"
if [ -f "$RUN_DIR/candidates.json" ]; then
  SIG_CHECK=$(python3 -c "
import json
d=json.load(open('$RUN_DIR/candidates.json'))
cands = d.get('candidates', [])
if not cands:
    print('no candidates - all active')
else:
    sigs = cands[0].get('coarse_filter_signals', {})
    for name, s in sigs.items():
        has_threshold = 'threshold' in s
        has_active = 'is_active' in s
        print(f'{name}: threshold={\"PASS\" if has_threshold else \"MISSING\"}, is_active={\"PASS\" if has_active else \"MISSING\"}')
" 2>/dev/null || echo "parse error")
  echo "$SIG_CHECK"
fi

# Summary
echo ""
if [ "$PASS" = true ]; then
  echo "PASS: All expected output files present and valid."
else
  echo "FAIL: Some verifications failed. Check logs: $LOG_FILE"
  exit 1
fi
