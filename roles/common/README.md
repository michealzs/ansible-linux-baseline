# common

Takes a fresh Debian or Ubuntu host to a sane starting point: base packages,
time sync, timezone, persistent journald with size caps, sysctl hardening,
an optional swap file, and a message of the day.

The first task refuses to run on anything other than Ubuntu 22.04, Ubuntu 24.04
or Debian 12, so a typo in the inventory does not end with hardening applied
to the wrong box.

## Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `common_packages` | curl, vim, htop, unzip, jq, chrony, ca-certificates, less | Packages installed everywhere |
| `common_manage_hostname` | `false` | Set the hostname to `common_hostname` |
| `common_hostname` | `inventory_hostname_short` | Hostname to apply when managed |
| `common_timezone` | `Etc/UTC` | System timezone |
| `common_journald_system_max_use` | `1G` | Disk cap for the persistent journal |
| `common_journald_max_retention_sec` | `1month` | Drop journal entries older than this |
| `common_sysctl_settings` | see `defaults/main.yml` | Key/value map written to `/etc/sysctl.d/99-baseline.conf` |
| `common_swap_enabled` | `false` | Create and activate a swap file |
| `common_swap_size_mb` | `2048` | Swap file size |
| `common_motd_banner` | short legal notice | First line of `/etc/motd` |
| `common_motd_disable_ubuntu_news` | `true` | Turn off Ubuntu's remote motd-news fetch |

## Notes

- sysctl values are applied live and written to the file, so no reboot is needed.
  `ignoreerrors` is on so hosts with IPv6 disabled do not fail on the `net.ipv6` keys.
- The swap file is created with `fallocate`, which is fine on ext4 and xfs. On
  btrfs, create the file by hand and set `common_swap_enabled: false`.
