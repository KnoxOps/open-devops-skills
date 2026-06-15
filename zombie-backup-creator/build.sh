#!/bin/bash
cd "$(dirname "$0")"
PYTHONPATH=/Users/hzp/github/agent-runbook python3 -m agent_runbook generate runbook.yaml -o skills --lang en
