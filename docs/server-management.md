# Arkie CS2 server management setup

Arkie can manage the game server process over SSH. The current backend is `systemd`, but the app stores a backend-specific management configuration so other backends can be added later.

## Server-side setup

### 1. Copy the installer to the server

Copy `scripts/install-arkie-cs2-dispatcher.sh` to the CS2 host.

### 2. Install the dispatcher

Run it as root, passing your systemd unit name:

```sh
sudo ./install-arkie-cs2-dispatcher.sh <systemd-unit-name>
```

For example:

```sh
sudo ./install-arkie-cs2-dispatcher.sh cs2server.service
```

> **Tip:** If you're unsure of your service name, list your systemd units:
>
> ```sh
> systemctl list-unit-files --type=service | grep -i cs
> ```
>
> or
>
> ```sh
> systemctl list-unit-files --type=service | grep -i counter
> ```

The installer creates a least-privilege `arkie-cs2` system user, installs `/usr/local/bin/arkie-cs2`, and writes a sudoers file that only allows these exact commands for that one unit:

- `systemctl start <unit>`
- `systemctl stop <unit>`
- `systemctl restart <unit>`
- `journalctl -u <unit> -f -n 200 -o short-iso`

### 3. Generate an SSH key pair

On the computer running Arkie (not the game server), create a dedicated key pair:

```sh
ssh-keygen -t ed25519 -f ~/.ssh/arkie_cs2 -C arkie-cs2
chmod 600 ~/.ssh/arkie_cs2
```

This creates:

- Private key: `~/.ssh/arkie_cs2`
- Public key: `~/.ssh/arkie_cs2.pub`

The private key stays on the Arkie computer. Only the public key is copied to the server.
When you choose the private key in Arkie, the app validates it immediately and, when you save,
imports a protected copy into Arkie's application-support directory. Arkie does not retain or
display the source file's path. Moving or deleting the source file later does not affect Arkie.

### 4. Install the public key on the server

Copy the contents of `~/.ssh/arkie_cs2.pub` from the Arkie computer.

On the server, become root:

```sh
sudo -i
```

Then append the public key to the authorized keys for the `arkie-cs2` user:

```sh
echo '<paste the entire contents of arkie_cs2.pub here>' >> /home/arkie-cs2/.ssh/authorized_keys
```

Ensure the permissions remain correct:

```sh
chown -R arkie-cs2:arkie-cs2 /home/arkie-cs2/.ssh
chmod 700 /home/arkie-cs2/.ssh
chmod 600 /home/arkie-cs2/.ssh/authorized_keys
```

### 5. Verify SSH access

Before configuring Arkie, verify that the key works:

```sh
ssh -i ~/.ssh/arkie_cs2 arkie-cs2@<server-ip>
```

The login should succeed without prompting for a password.

### 6. Record the server host key fingerprint

Run on the server:

```sh
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Example output:

```text
256 SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx root@server (ED25519)
```

Record only the fingerprint portion:

```text
SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

This is the value entered into Arkie.

## Arkie UI setup

When adding a server, enable **Manage server over SSH** and enter:

| Field | Value |
|-------|-------|
| SSH host | Server IP or hostname |
| SSH port | Usually `22` |
| SSH user | `arkie-cs2` |
| Private key path | `~/.ssh/arkie_cs2` |
| Host key fingerprint | The `SHA256:...` fingerprint recorded above |

Arkie verifies the host key fingerprint before authentication and rejects the connection if it differs.
Choose the private key with the system file picker; encrypted private keys are not supported yet.

To rotate a key, open the server's **Server process** section, choose **Edit**, and then
**Replace**. Saving imports the replacement before removing Arkie's previous copy. Turning off
**Manage server over SSH** removes the management configuration and Arkie's managed key copy.

Configurations created by older Arkie versions stored an external path. For safety, Arkie never
reads that legacy path automatically. The Server process section will ask you to reselect the key
once, after which Arkie stores the managed reference instead.

## Available actions

The UI exposes Start, Stop, Restart, and Stream logs. Arkie only sends:

- `arkie-cs2 start`
- `arkie-cs2 stop`
- `arkie-cs2 restart`
- `arkie-cs2 logs`

The server-side dispatcher maps those tokens to the fixed systemd commands configured during installation.
