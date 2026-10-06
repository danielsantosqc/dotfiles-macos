#!/bin/bash
set -euo pipefail

CLI="/usr/local/bin/chargelimit"
LIB_DIR="/usr/local/lib/chargelimit"
CONF="/usr/local/etc/chargelimit.conf"
PLIST="/Library/LaunchDaemons/local.chargelimit.plist"
LABEL="local.chargelimit"
LOG="/var/log/chargelimit.log"

if [[ "$(id -u)" -ne 0 ]]; then
	echo "Necesita root. Ejecuta:  sudo $0" >&2
	exit 1
fi

if [[ -x "$CLI" ]]; then
	echo "==> Desactivando el limite de carga (vuelve a cargar hasta 100%)"
	"$CLI" off || echo "Aviso: no se pudo desactivar el limite" >&2
fi

echo "==> Descargando LaunchDaemon"
launchctl bootout "system/$LABEL" 2>/dev/null || true

echo "==> Eliminando archivos"
rm -fv "$PLIST" "$CLI" "$CONF" "$LOG"
rm -frv "$LIB_DIR"

echo
echo "Listo. La bateria volvera a cargar hasta el 100%."
