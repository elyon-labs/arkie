#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${1:-cs2-server.service}"
if ! [[ "${SERVICE_NAME}" =~ ^[A-Za-z0-9@._-]+\.service$ ]]; then
  echo "Invalid systemd service name: ${SERVICE_NAME}" >&2
  exit 64
fi
ARKIE_USER="${ARKIE_USER:-arkie-cs2}"
DISPATCHER="${DISPATCHER:-/usr/local/bin/arkie-cs2}"
SUDOERS_FILE="/etc/sudoers.d/arkie-cs2"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root: sudo $0 [systemd-service-name]" >&2
  exit 1
fi

id -u "${ARKIE_USER}" >/dev/null 2>&1 || useradd --system --create-home --shell /bin/bash "${ARKIE_USER}"
install -o root -g root -m 0755 /dev/stdin "${DISPATCHER}" <<SCRIPT
#!/usr/bin/env bash
set -euo pipefail
SERVICE="${SERVICE_NAME}"
case "\${1:-}" in
  start) exec sudo /bin/systemctl start "\${SERVICE}" ;;
  stop) exec sudo /bin/systemctl stop "\${SERVICE}" ;;
  restart) exec sudo /bin/systemctl restart "\${SERVICE}" ;;
  logs) exec sudo /bin/journalctl -u "\${SERVICE}" -f -n 200 -o short-iso ;;
  *) echo "usage: arkie-cs2 {start|stop|restart|logs}" >&2; exit 64 ;;
esac
SCRIPT

install -o root -g root -m 0440 /dev/stdin "${SUDOERS_FILE}" <<SUDOERS
${ARKIE_USER} ALL=(root) NOPASSWD: /bin/systemctl start ${SERVICE_NAME}, /bin/systemctl stop ${SERVICE_NAME}, /bin/systemctl restart ${SERVICE_NAME}, /bin/journalctl -u ${SERVICE_NAME} -f -n 200 -o short-iso
SUDOERS
visudo -cf "${SUDOERS_FILE}"

install -d -o "${ARKIE_USER}" -g "${ARKIE_USER}" -m 0700 "/home/${ARKIE_USER}/.ssh"
touch "/home/${ARKIE_USER}/.ssh/authorized_keys"
chown "${ARKIE_USER}:${ARKIE_USER}" "/home/${ARKIE_USER}/.ssh/authorized_keys"
chmod 0600 "/home/${ARKIE_USER}/.ssh/authorized_keys"

echo "Installed ${DISPATCHER} for ${SERVICE_NAME}. Add Arkie's public key to /home/${ARKIE_USER}/.ssh/authorized_keys."
echo "Host key fingerprint: $(ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub | awk '{print $2}')"
