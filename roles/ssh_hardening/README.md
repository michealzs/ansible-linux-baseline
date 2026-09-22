# ssh_hardening

Writes `/etc/ssh/sshd_config.d/00-baseline.conf` and restarts sshd only after
both the drop-in and the merged configuration pass `sshd -t`.

What the drop-in sets: key-only login (`PasswordAuthentication no`,
`AuthenticationMethods publickey`), `PermitRootLogin no`, `MaxAuthTries 3`,
`LoginGraceTime 30`, client keepalive, `X11Forwarding no`, agent and TCP
forwarding off, `AllowGroups admins`, verbose logging, and a modern set of
KexAlgorithms, Ciphers, MACs and HostKeyAlgorithms.

## The lockout pre-check

Before password authentication is turned off, `tasks/precheck.yml` fails the
play unless:

1. at least one `authorized_keys` file under `/home` or `/root` contains a
   public key line, and
2. every group in `ssh_hardening_allow_groups` exists and has at least one
   member.

The check is skipped when `ssh_hardening_password_authentication` is true, or
when you set `ssh_hardening_skip_lockout_check: true`. Do not set that unless
you have console access.

## Why `00-`

sshd keeps the first value it reads for a keyword. `sshd_config` on these
distributions starts with `Include /etc/ssh/sshd_config.d/*.conf`, and the
files are read in sorted order. `00-baseline.conf` therefore beats
`50-cloud-init.conf`, which on some cloud images sets
`PasswordAuthentication yes`.

## Ubuntu 24.04 and ssh.socket

24.04 starts sshd through `ssh.socket`, which listens on port 22 regardless of
`Port` in sshd_config. The role disables the socket and enables `ssh.service`
instead (`ssh_hardening_disable_socket_activation: true`). Set it to false if
you want to keep socket activation and are not changing the port.

## Variables you are likely to change

| Variable | Default |
| --- | --- |
| `ssh_hardening_port` | `22` |
| `ssh_hardening_allow_groups` | `[admins]` |
| `ssh_hardening_permit_root_login` | `"no"` |
| `ssh_hardening_allow_tcp_forwarding` | `false` |
| `ssh_hardening_client_alive_interval` | `300` |
| `ssh_hardening_extra_settings` | `{}` (keyword: value pairs appended verbatim) |

Full list in `defaults/main.yml`.
