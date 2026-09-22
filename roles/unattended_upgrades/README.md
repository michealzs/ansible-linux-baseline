# unattended_upgrades

Security updates are installed automatically once a day. Nothing else is
upgraded unless you add more origins. Reboots are off by default.

## Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `unattended_upgrades_origins` | security origins for the detected distribution | Allowed-Origins list |
| `unattended_upgrades_package_blacklist` | `[]` | Packages never touched |
| `unattended_upgrades_automatic_reboot` | `false` | Reboot when a package requests it |
| `unattended_upgrades_automatic_reboot_time` | `"03:30"` | Local time for that reboot |
| `unattended_upgrades_mail` | `""` | Address for reports; needs a local MTA |
| `unattended_upgrades_mail_report` | `on-change` | `always`, `only-on-error` or `on-change` |
| `unattended_upgrades_autoclean_interval` | `7` | Days between apt autoclean runs |

## Notes

- Ubuntu origins include the ESM pockets. They are harmless when the host has
  no Pro subscription: the origin simply never matches.
- With `unattended_upgrades_automatic_reboot: true`, stagger
  `unattended_upgrades_automatic_reboot_time` across hosts in group_vars so a
  kernel update does not reboot a whole cluster at 03:30.
