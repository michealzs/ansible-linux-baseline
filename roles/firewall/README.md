# firewall

ufw with incoming denied, outgoing allowed, SSH allowed with `limit`, and any
number of extra rules from a list. Logging is set to `low`.

The rules are added before ufw is enabled, so a first run on a fresh host never
has a window where the firewall is up and SSH is not allowed.

## Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `firewall_ssh_port` | `ssh_hardening_port` or 22 | Port that gets the rate-limited allow |
| `firewall_ssh_rate_limit` | `true` | Use `limit` instead of `allow` for SSH |
| `firewall_rules` | `[]` | Extra rules, see below |
| `firewall_logging` | `low` | ufw log level |
| `firewall_default_routed` | `deny` | Policy for forwarded traffic |

## Extra rules

```yaml
firewall_rules:
  - { port: 80, proto: tcp, comment: "HTTP" }
  - { port: 443, proto: tcp, comment: "HTTPS" }
  - { port: 5432, proto: tcp, src: 10.0.0.0/8, comment: "PostgreSQL from LAN" }
```

Supported keys: `port` (required), `proto`, `rule` (allow, deny, limit,
reject), `src`, `dest`, `interface`, `direction`, `comment`.

## Note on Docker

Docker publishes ports by inserting its own iptables rules in the FORWARD
chain, which ufw does not see. Ports published with `-p` are reachable even if
ufw denies them. Bind published ports to `127.0.0.1` or filter in the
`DOCKER-USER` chain if that matters for the host.
