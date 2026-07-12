# Arkie CS2 server management setup

Arkie can manage the game server process over SSH. The current backend is `systemd`, but the app stores a backend-specific management configuration so other backends can be added later.

## Server-side setup

1. Copy `scripts/install-arkie-cs2-dispatcher.sh` to the CS2 host.
2. Run it as root, passing your systemd unit name:

   ```sh
   sudo ./install-arkie-cs2-dispatcher.sh cs2-server.service
   ```

   The script creates a least-privilege `arkie-cs2` system user, installs `/usr/local/bin/arkie-cs2`, and writes a sudoers file that only allows these exact commands for that one unit:

   - `systemctl start <unit>`
   - `systemctl stop <unit>`
   - `systemctl restart <unit>`
   - `journalctl -u <unit> -f -n 200 -o short-iso`

3. On the computer running Arkie, create a dedicated key pair and protect the private key with normal OS file permissions:

   ```sh
   ssh-keygen -t ed25519 -f ~/.ssh/arkie_cs2 -C arkie-cs2
   chmod 600 ~/.ssh/arkie_cs2
   ```

4. Append `~/.ssh/arkie_cs2.pub` to `/home/arkie-cs2/.ssh/authorized_keys` on the server.
5. Record the server host key fingerprint printed by the installer, or run:

   ```sh
   ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
   ```

## Arkie UI setup

When adding a server, enable **Manage server over SSH** and enter:

- SSH host and port.
- SSH user, normally `arkie-cs2`.
- Private key path on the Arkie machine, for example `~/.ssh/arkie_cs2`.
- Host key fingerprint in `SHA256:...` form.

Arkie verifies the host key fingerprint before authentication and rejects the connection if it differs. Arkie stores the private key path, not the private key material; keep the key in the operating system's protected SSH directory or a similarly secured location.

## Available actions

The UI exposes Start, Stop, Restart, and Stream logs. Arkie only sends `arkie-cs2 start`, `arkie-cs2 stop`, `arkie-cs2 restart`, or `arkie-cs2 logs`; the server-side dispatcher maps those tokens to the fixed systemd commands above.
