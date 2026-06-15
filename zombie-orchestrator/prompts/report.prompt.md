Read ALL {run_dir}/analysis/deep_scan_*.json.

Generate a comprehensive Markdown report using the Write tool. The report should cover all deep-scanned resources with one section per resource (labeled by hostname or IP). Each resource section has 5 sub-sections:

**Section 0 "Traffic"** -- Service Topology:
- One entry for the VM (resource_id, hostname, status)
- For each edge in traffic_graph.edges, create peer entries:
  - Process known -> "IP:port process_name"
  - Only port/IP known -> "IP:port"
  - Unmapped -> "IP:port (degraded)"
- Edge details: from=src ip:port, to=dst ip:port, rate_kbps throughput

**Section 1 "Services"** -- with:
- Table: processes[] (PID, user, CPU%, MEM%, command), filter out systemd/sshd/kthread
- List: listening_ports[] as "port process status"
- Note if local_databases non-empty: "Local databases: ..."

**Section 2 "Scheduled Tasks"** -- with:
- Table: crontab_entries[] (user, schedule, command)
- Table: systemd_timers[] (unit, next, schedule)

**Section 3 "Storage"** -- with:
- List: disk_partitions[] mount: "used/size (use%)"
- Note if disk_usage has results with top-5 large directories

**Section 4 "Ownership"** -- with:
- List: business.owner, business.team, business.environment, etc.
- Table: estimated_monthly_cost, spec.cpu_cores, spec.memory_gb, spec.disk_gb
