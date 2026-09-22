# auditd

Installs auditd and writes `/etc/audit/rules.d/99-baseline.rules`. The rule
set is deliberately small: changes to identity files, sudoers, sshd
configuration and login records, plus execution of privileged commands by
real users and kernel module loading. Search the log with the keys
`identity`, `sudoers`, `sshd`, `logins`, `privileged` and `modules`, for
example `ausearch -k sudoers`.

`auditd.conf` gets rotation settings so the log cannot fill the disk: five
files of 50 MB, rotate when full.

## Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `auditd_privileged_commands` | sudo, su, passwd, chsh, chfn, newgrp, gpasswd, usermod, useradd, userdel | Binaries whose execution is logged |
| `auditd_log_kernel_modules` | `true` | Log module load and unload |
| `auditd_extra_rules` | `[]` | Raw rules appended verbatim |
| `auditd_immutable` | `false` | Add `-e 2`; rules then need a reboot to change |
| `auditd_conf_settings` | rotation settings | Key/value pairs applied to auditd.conf |

## Notes

- The distribution ships `/etc/audit/rules.d/audit.rules` with `-D` and the
  buffer size. This role's file sorts after it and must not repeat `-D`.
- auditd cannot run inside a container, so this role is not part of the
  molecule scenario. It is covered by lint and syntax checks.
