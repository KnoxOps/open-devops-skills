# Open DevOps Skills

Production-ready [Claude Code](https://claude.ai/code) and [Codex](https://github.com/openai/codex) skills for DevOps, SRE, and platform engineering teams.

## Skills

| Skill | Description | Cloud / Stack |
|-------|-------------|---------------|
| [zombie-resource-scanner](./skills/zombie-resource-scanner/) | Scan cloud infrastructure for zombie/idle resources, generate cost optimization recommendations with auto-classification and scheduled task protection | AWS, Alibaba Cloud, Azure (WIP) |

## Why Open DevOps Skills?

Existing DevOps skill projects focus on coding workflows — Terraform authoring, CI/CD config, K8s YAML. This project covers **operational workflows**: what SRE teams actually do day-to-day — scanning zombie resources, troubleshooting incidents, analyzing blast radius, reviewing monitoring coverage.

Each skill follows a **multi-agent pipeline** pattern:

```
Plan → Collect → Validate → Analyze → Report
```

Rather than a single flat prompt, each skill orchestrates specialized agents that verify each other's work, producing reliable, production-safe results.

## Install

```bash
# Claude Code
cp -r skills/* ~/.claude/skills/

# Codex
cp -r skills/* ~/.codex/skills/
```

Or cherry-pick individual skill directories.

## Roadmap

- [ ] K8s troubleshooting skill (pod failures, cluster issues, OOM diagnosis)
- [ ] Monitoring coverage audit (Prometheus/Grafana gap analysis)
- [ ] Incident blast-radius calculator
- [ ] CI/CD pipeline health check
- [ ] AWS cost optimization (Reserved Instance / Savings Plan analysis)
- [ ] Secret sprawl detection

## Contributing

Skills use standard Claude Code SKILL.md format. Each skill directory is self-contained with zero external dependencies beyond the agent runtime.

1. Fork the repo
2. Create `skills/your-skill-name/SKILL.md`
3. Add tests and examples under `skills/your-skill-name/`
4. Open a PR with a description of what the skill does and who it's for

## License

MIT
