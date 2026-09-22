# fail2ban

Installs fail2ban and writes `/etc/fail2ban/jail.local` with an `sshd` jail.
Defaults: 5 failures in 10 minutes earn a 1 hour ban.

## Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `fail2ban_bantime` | `1h` | How long a ban lasts |
| `fail2ban_findtime` | `10m` | Window in which failures are counted |
| `fail2ban_maxretry` | `5` | Failures allowed inside the window |
| `fail2ban_ignoreip` | `[]` | Addresses or CIDRs that are never banned |
| `fail2ban_banaction` | `ufw` | Ban mechanism; `iptables-multiport` if ufw is not used |
| `fail2ban_backend` | `systemd` | Log source |
| `fail2ban_sshd_port` | `ssh_hardening_port` or 22 | Port the sshd jail watches |
| `fail2ban_sshd_mode` | `normal` | Filter mode; `aggressive` matches more |

## Notes

- Debian 12 does not install rsyslog, so there is no `/var/log/auth.log`.
  The `systemd` backend reads the journal directly and needs `python3-systemd`,
  which the role installs.
- Put your office or bastion range in `fail2ban_ignoreip`. A mistyped password
  from a shared NAT address otherwise bans everyone behind it.
