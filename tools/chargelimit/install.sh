#!/bin/bash
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SMC_URL="https://raw.githubusercontent.com/actuallymentor/battery/main/dist/smc"
LIB_DIR="/usr/local/lib/chargelimit"
BIN_DIR="/usr/local/bin"
ETC_DIR="/usr/local/etc"
PLIST_DIR="/Library/LaunchDaemons"
LABEL="local.chargelimit"

if [[ "$(id -u)" -ne 0 ]]; then
	echo "Este instalador necesita root. Ejecuta:  sudo $0" >&2
	exit 1
fi

for f in chargelimit local.chargelimit.plist chargelimit.conf; do
	if [[ ! -f "$SRC_DIR/$f" ]]; then
		echo "Falta el archivo $SRC_DIR/$f" >&2
		exit 1
	fi
done

echo "==> Creando directorios"
mkdir -p "$LIB_DIR" "$ETC_DIR"

echo "==> Instalando binario smc"
if [[ -x "$SRC_DIR/smc" ]]; then
	echo "    usando el binario incluido en la carpeta"
	install -o root -g wheel -m 755 "$SRC_DIR/smc" "$LIB_DIR/smc"
else
	echo "    no hay ./smc local, descargando desde $SMC_URL"
	tmp="$(mktemp)"
	trap 'rm -f "$tmp"' EXIT
	curl -fsSL "$SMC_URL" -o "$tmp"
	if [[ "$(file -b "$tmp")" != *Mach-O* ]]; then
		echo "La descarga no es un binario Mach-O valido. Abortando." >&2
		exit 1
	fi
	install -o root -g wheel -m 755 "$tmp" "$LIB_DIR/smc"
fi

echo "==> Instalando comando chargelimit"
install -o root -g wheel -m 755 "$SRC_DIR/chargelimit" "$BIN_DIR/chargelimit"

echo "==> Instalando LaunchDaemon"
install -o root -g wheel -m 644 "$SRC_DIR/local.chargelimit.plist" "$PLIST_DIR/$LABEL.plist"

if [[ -f "$ETC_DIR/chargelimit.conf" ]]; then
	echo "==> Config ya existente, se conserva: $(cat "$ETC_DIR/chargelimit.conf")"
else
	install -o root -g wheel -m 644 "$SRC_DIR/chargelimit.conf" "$ETC_DIR/chargelimit.conf"
	echo "==> Config creada: $(cat "$ETC_DIR/chargelimit.conf")"
fi

echo "==> Cargando LaunchDaemon"
launchctl bootout "system/$LABEL" 2>/dev/null || true
launchctl bootstrap system "$PLIST_DIR/$LABEL.plist"

echo
"$BIN_DIR/chargelimit"
