# docker

Installs Docker CE, the CLI, containerd, buildx and the compose plugin from
`download.docker.com`. The signing key is stored in `/etc/apt/keyrings` and
referenced with `signed-by`, so no key ends up in the global apt trust store.

`/etc/docker/daemon.json` is rendered from `docker_daemon_config` and checked
with `dockerd --validate --config-file` before it replaces the live file.

## Defaults in daemon.json

- `json-file` logging capped at 3 files of 10 MB per container
- `live-restore: true` so containers keep running while dockerd restarts
- `default-address-pools` set to `172.20.0.0/14` and `10.200.0.0/16`, which
  keeps Docker networks away from the common `172.16.0.0/12` corporate ranges

## Variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `docker_daemon_config` | see above | Dictionary written to daemon.json |
| `docker_add_admin_users_to_group` | `false` | Add every `users_admins` account to the docker group |
| `docker_users` | `[]` | Extra accounts for the docker group |
| `docker_remove_conflicting_packages` | `true` | Purge docker.io, podman-docker and friends first |
| `docker_packages` | docker-ce and plugins | Package list |

## Notes

- Membership of the `docker` group is equivalent to root on the host. The
  toggle is off by default for that reason.
- Docker manages its own iptables rules. Published ports bypass ufw; see the
  firewall role README.
