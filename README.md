# Open DevOps Skills

Community repository of DevOps & SRE skills for [Claude Code](https://claude.ai/code) and [Codex](https://github.com/openai/codex).

## Available Skills

| Skill | Role | Description |
|-------|------|-------------|
| `zombie-orchestrator` | Captain | Full-pipeline orchestrator — dispatches sub-agents for each phase |
| `zombie-metrics-collector` | Collector | Discover cloud resources + apply 3-signal coarse filter |
| `zombie-resource-screener` | Architect | Multi-dimension scoring and zombie ranking |
| `zombie-deep-scanner` | Collector | Per-machine deep scan: processes, ports, crontab, disk, iftop, business info |
| `zombie-isolation-planner` | Architect | Design iptables DROP isolation strategies with rollback plans |
| `zombie-isolation-executor` | Coordinator | Execute isolation + observation period + auto-rollback |
| `zombie-decision-handler` | Coordinator | Merge deep scan + observation results, user decision DELETE/KEEP |
| `zombie-backup-creator` | Collector | Pre-deletion backup (snapshot, image, export) |
| `zombie-resource-cleaner` | Coordinator | Execute resource deletion + cost savings report |

**Pipeline**: Collect → Filter → Score → Review → Deep Scan → Report → Isolate → Observe → Decide → Backup → Delete

Each skill is independent — you can run any individual skill or the full orchestrator.

### Key Features

- **3-signal coarse filter**: CPU > 20%, Network > 2 GB/day, Login 30 days (thresholds in `signals-compute.md`)
- **Deep scan with iftop**: Real-time per-connection traffic graph with process attribution
- **Contract-based**: Every step declares input/output with JSON Schema — contracts validated at build time
- **Multi-cloud**: AWS CLI + Alibaba Cloud CLI. SSH fallback for bare metal.
- **No external MCPs required**: Bash + SSH + cloud CLI tools only

## Installation

### Marketplace (recommended)

```bash
# Claude Code
/plugin marketplace add https://github.com/KnoxOps/open-devops-skills
/plugin install zombie-orchestrator@open-devops-skills

# Codex
codex plugin marketplace add https://github.com/KnoxOps/open-devops-skills
codex plugin install zombie-orchestrator@open-devops-skills
```

Install individual skills as needed (e.g. `zombie-deep-scanner` for deep scans only).

### Manual

```bash
git clone https://github.com/KnoxOps/open-devops-skills.git

# Claude Code
cp -r open-devops-skills/zombie-* ~/.claude/plugins/

# Codex
cp -r open-devops-skills/zombie-* ~/.agents/plugins/
```

## Usage

Once installed, use skills through Claude Code or Codex:

**Full Pipeline (orchestrator):**
- "Scan my AWS account for zombie resources"
- "Find idle EC2 instances and unused EBS volumes"
- "Run zombie scan on my Alibaba Cloud dev environment"
- "Deep scan these 3 hosts and tell me if they're zombies"

**Individual Skills:**
- "Run zombie-metrics-collector on these IPs via SSH"
- "Score and rank the candidates from candidates.json"
- "Deep scan 172.30.0.41 and collect iftop traffic data"

## Why Open DevOps Skills?

Existing DevOps skill projects focus on coding workflows — Terraform authoring, CI/CD config, K8s YAML. This project covers **operational workflows**: what SRE teams actually do day-to-day — scanning zombie resources, troubleshooting incidents, analyzing blast radius, reviewing monitoring coverage.

Each skill follows a **multi-agent pipeline** pattern:

```
Plan → Collect → Validate → Analyze → Report
```

Rather than a single flat prompt, each skill orchestrates specialized agents that verify each other's work, producing reliable, production-safe results.

## Roadmap

- [ ] K8s troubleshooting skill (pod failures, cluster issues, OOM diagnosis)
- [ ] Monitoring coverage audit (Prometheus/Grafana gap analysis)
- [ ] Incident blast-radius calculator
- [ ] CI/CD pipeline health check
- [ ] AWS cost optimization (Reserved Instance / Savings Plan analysis)
- [ ] Secret sprawl detection

## Contributing

Each skill is an independent plugin with its own `.claude-plugin/plugin.json` manifest.

1. Fork the repo
2. Create `your-skill-name/.claude-plugin/plugin.json`
3. Create `your-skill-name/skills/SKILL.md` with proper frontmatter
4. Add `your-skill-name/skills/references/` and `your-skill-name/skills/scripts/` as needed
5. Update `.claude-plugin/marketplace.json` to include your skill
6. Update README with skill description and usage examples
7. Open a PR

## License

MIT
