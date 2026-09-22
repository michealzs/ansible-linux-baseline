# users

Creates the admin accounts, installs their SSH public keys, adds them to a
sudo group and locks their password field so the accounts are key-only.

Sudo is granted through `/etc/sudoers.d/90-<group>`, written with
`visudo -cf %s` as the validator. A bad template never reaches disk.

## Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `users_admins` | `[]` | List of `{name, comment, shell, groups, authorized_keys}` |
| `users_admin_group` | `admins` | Group that carries the sudo grant |
| `users_sudo_nopasswd` | `true` | `NOPASSWD:` on the sudo rule |
| `users_lock_passwords` | `true` | Lock the password field for each admin |
| `users_authorized_keys_exclusive` | `true` | Remove keys not in the list |
| `users_removed` | `[]` | Accounts to delete along with their home directory |

## Example

```yaml
users_admins:
  - name: alice
    comment: Alice Example
    authorized_keys:
      - "ssh-ed25519 AAAA...example alice@example.com"
```

The key above is a placeholder. Put real public keys in your own group_vars.

## Notes

- `users_authorized_keys_exclusive: true` means any key added by hand on the
  host is removed on the next run. That is the point, but know it is on.
- Run this role before `ssh_hardening`. That role refuses to disable password
  authentication until at least one account has a public key installed.
