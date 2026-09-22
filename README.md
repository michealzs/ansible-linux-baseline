# ansible-linux-baseline

Ansible roles and playbooks that take a fresh Ubuntu 22.04, Ubuntu 24.04 or
Debian 12 host to a hardened, monitored baseline: key-only SSH with a lockout
pre-check, ufw, fail2ban, automatic security updates, auditd, sysctl
hardening, persistent journald, and Prometheus node_exporter. Docker CE is an
optional extra for hosts that need it. Every role is idempotent, tagged, and
exercised in CI with ansible-lint, a syntax check, and molecule against all
three distributions.

## What the baseline changes

| Role | What it does | Tag |
| --- | --- | --- |
| `common` | Base packages, chrony, timezone, persistent journald with size caps, sysctl hardening in `/etc/sysctl.d/99-baseline.conf`, optional swap file, MOTD | `common` |
| `users` | Admin accounts with SSH keys, sudo through a `visudo`-validated `sudoers.d` file, password field locked | `users` |
| `ssh_hardening` | `sshd_config.d/00-baseline.conf`: key-only login, no root, MaxAuthTries 3, keepalives, AllowGroups, modern KEX/ciphers/MACs; validated with `sshd -t` before restart; refuses to run without an installed key | `ssh_hardening` |
| `firewall` | ufw: deny incoming, allow outgoing, rate-limited SSH, extra rules from a list, low logging | `firewall` |
| `fail2ban` | sshd jail on the systemd journal, bans applied through ufw | `fail2ban` |
| `unattended_upgrades` | Security-only automatic updates, optional reboot window, optional mail report | `unattended_upgrades` |
| `auditd` | Rules for identity files, sudoers, sshd config, login records, privileged commands and module loading; log rotation | `auditd` |
| `docker` | Docker CE from the official repo with a `signed-by` keyring, validated `daemon.json` (log rotation, live-restore, address pools), optional docker group membership | `docker` |
| `node_exporter` | Pinned release with checksum verification, dedicated user, sandboxed systemd unit, ufw rule for the monitoring network only | `node_exporter` |

Group tags: `base` (common, users), `hardening` (ssh_hardening, firewall,
fail2ban, auditd), `updates`, `monitoring`.

`playbooks/site.yml` runs all of it. `playbooks/docker-hosts.yml` and
`playbooks/monitoring-agents.yml` are the two extras on their own.

## Quick start

```bash
git clone https://github.com/michealzs/ansible-linux-baseline.git
cd ansible-linux-baseline

# 1. Python venv, pinned ansible-core and ansible-lint, Galaxy collections
make deps

# 2. Your own inventory. Replace the hosts and the placeholder SSH key.
cp -r inventory/example inventory/prod
$EDITOR inventory/prod/hosts.yml inventory/prod/group_vars/all.yml

# 3. Dry run. Nothing changes; you see every file diff and every task that would run.
.venv/bin/ansible-playbook -i inventory/prod/hosts.yml playbooks/site.yml --check --diff

# 4. Apply
.venv/bin/ansible-playbook -i inventory/prod/hosts.yml playbooks/site.yml --diff
```

`make check` and `make apply` wrap steps 3 and 4 and accept `INVENTORY=`,
`LIMIT=` and `TAGS=`:

```bash
make check INVENTORY=inventory/prod/hosts.yml LIMIT=web-01.example.com TAGS=ssh_hardening,firewall
```

The first run on a cloud image usually connects as `ubuntu`, `debian` or
`root`. Set `ansible_user` in `group_vars/all.yml` for that run, then switch
it to one of your admin accounts.

## Safety

Hardening SSH on a remote host is the one place where a mistake means a trip
to the console. Three things guard against that:

1. **Lockout pre-check.** `ssh_hardening` will not disable password
   authentication until at least one `authorized_keys` file under `/home` or
   `/root` contains a public key, and every group in `AllowGroups` exists and
   has a member. The `users` role runs first and satisfies both. The check can
   be skipped with `ssh_hardening_skip_lockout_check: true`; do not, unless you
   have console access.
2. **Validated before restart.** The sshd drop-in is checked with
   `sshd -t -f` before it is written, and the merged configuration is checked
   again with `sshd -t` in a handler before sshd is restarted. The sudoers file
   goes through `visudo -cf`. `daemon.json` goes through `dockerd --validate`.
3. **Run `--check --diff` first, then apply in batches.** `site.yml` uses
   `serial` (25% of the group per batch by default, `-e baseline_serial=1` for
   one host at a time) with `max_fail_percentage: 0`, so a failure in one batch
   stops the play before the next batch starts.

Keep an SSH session open to a host while you apply the SSH and firewall roles
to it for the first time. If something is wrong, that session still works.

## Testing

```bash
make lint        # yamllint + ansible-lint, production profile
make syntax      # ansible-playbook --syntax-check against the example inventory
make molecule    # MOLECULE_DISTRO=ubuntu2204|ubuntu2404|debian12; needs Docker
```

CI (`.github/workflows/ci.yml`) runs the same three stages on every push and
pull request. Molecule builds a systemd container from the
`geerlingguy/docker-*-ansible` images, applies the baseline roles, runs them a
second time to prove idempotence, then `verify.yml` asserts the effective sshd
settings from `sshd -T`, that ufw is active with the expected rules, that the
fail2ban sshd jail is loaded, that sysctl values are live, and that
node_exporter is serving metrics as its own user under `ProtectSystem=strict`.

The `docker` and `auditd` roles are not part of the molecule scenario because
neither can run inside a container. They are covered by lint and the syntax
check.

Pre-commit hooks for yamllint and ansible-lint are in
`.pre-commit-config.yaml`; run `pre-commit install` once after cloning.

## Variables you will want to change

All of these live in `inventory/<env>/group_vars/all.yml`. Role defaults are
documented in each role's README.

| Variable | Why |
| --- | --- |
| `users_admins` | Your admin accounts and public keys. The example key is a placeholder. |
| `ansible_user` | Bootstrap account for the first run |
| `ssh_hardening_port` | Only if you move SSH off 22; the firewall and fail2ban follow it |
| `ssh_hardening_allow_groups` | Must include the group your admins are in (`admins` by default) |
| `fail2ban_ignoreip` | Your office or bastion range, so one typo does not ban the whole team |
| `node_exporter_allowed_cidrs` | The network your Prometheus server scrapes from |
| `firewall_rules` | Any service ports beyond SSH, usually set per group |
| `unattended_upgrades_automatic_reboot` and `_time` | Whether hosts may reboot for kernel updates, and when |
| `docker_add_admin_users_to_group` | Docker group membership is root-equivalent; off by default |
| `common_timezone` | `Etc/UTC` unless you have a reason |

## Tested on

- Ubuntu 22.04 (jammy)
- Ubuntu 24.04 (noble)
- Debian 12 (bookworm)

All three through molecule in CI, using `ansible-core` 2.17 on Python 3.12.
Roles use only `ansible.builtin`, `ansible.posix`, `community.general` and
(for molecule) `community.docker`, at the versions pinned in
`requirements.yml`.

## Layout

```text
ansible.cfg              inventory path, roles_path, fact cache, yaml output
requirements.txt         ansible-core, ansible-lint, molecule (control node)
requirements.yml         Galaxy collections, pinned
playbooks/               site.yml, docker-hosts.yml, monitoring-agents.yml
inventory/example/       hosts.yml and group_vars to copy from
roles/                   one directory per role, each with its own README
molecule/default/        molecule.yml, converge.yml, verify.yml
.github/workflows/ci.yml lint, syntax, molecule matrix
```

## License

MIT. See `LICENSE`.

Maintained by Micheal ([@michealzs](https://github.com/michealzs)).
