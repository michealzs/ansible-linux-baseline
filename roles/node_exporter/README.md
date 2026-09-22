# node_exporter

Installs a pinned Prometheus node_exporter release from GitHub, verifies it
against the upstream `sha256sums.txt`, and runs it as a dedicated system user
under a systemd unit with the usual sandboxing (`ProtectSystem=strict`,
`NoNewPrivileges`, `PrivateTmp`, empty capability set, and so on).

The download only happens when `node_exporter --version` does not already
report the pinned version, so steady-state runs make no network calls.

## Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `node_exporter_version` | `1.9.1` | Release to install |
| `node_exporter_listen_ip` | `0.0.0.0` | Bind address |
| `node_exporter_port` | `9100` | Metrics port |
| `node_exporter_enabled_collectors` | `[]` | Extra collectors, for example `systemd` |
| `node_exporter_disabled_collectors` | `[]` | Collectors to switch off |
| `node_exporter_extra_args` | `[]` | Extra command line flags |
| `node_exporter_manage_firewall` | `true` | Add ufw rules for the port |
| `node_exporter_allowed_cidrs` | `[10.0.0.0/8]` | Networks allowed to scrape |

## Notes

- Set `node_exporter_allowed_cidrs` to the Prometheus server's network. With
  the firewall role in place nothing else can reach port 9100.
- Drop `.prom` files into `/var/lib/node_exporter/textfile_collector` to expose
  custom metrics. The directory is group-owned by `node_exporter` and writable
  by root only.
- To upgrade, change `node_exporter_version` and re-run. The old archive stays
  in `/usr/local/src` for rollback.
