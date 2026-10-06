#!/bin/bash
# dev.sh - abre las apps del entorno de desarrollo.
# La lista de apps vive en apps.conf (una ruta completa por linea).
# Las que ya estan abiertas se dejan como estan; las que no existen se reportan.
#
# Lanzadores: "Work Mode.app" (Spotlight, sin ventana) y dev.command (con
# Terminal). Ambos solo llaman a este script: la configuracion se lee aqui.
set -u

# --- Rutas base y opciones de linea de comandos --------------------------------

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # carpeta de este script
CONF="$DIR/apps.conf"                                 # lista de apps a abrir

DRY_RUN=false   # --dry-run: solo informa, no abre nada
LIST=false      # --list: imprime la lista y valida que las rutas existan

case "${1:-}" in
	--dry-run|-n) DRY_RUN=true ;;
	--list) LIST=true ;;
	--help|-h)
		cat <<EOF
dev.sh - abre el entorno de desarrollo

uso:
  dev.sh            abre las apps que falten (las ya abiertas no se tocan)
  dev.sh --dry-run  muestra que haria, sin abrir nada
  dev.sh --list     lista las apps configuradas y si existen

para agregar o quitar apps edita:
  $CONF
EOF
		exit 0
		;;
esac

# --- Deteccion de apps ya abiertas ---------------------------------------------
# Se pregunta a LaunchServices por el bundle id (lsappinfo). Con pgrep -f por ruta
# fallaba con Zap.app, cuyo ejecutable se llama zap-oss y pgrep no lo ve.
# pgrep queda como respaldo por si no se pudiera leer el Info.plist.

is_running() {
	local app="$1" bid
	bid="$(defaults read "$app/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || true)"
	if [[ -n "$bid" ]] && lsappinfo info -only pid "$bid" 2>/dev/null | grep -qE '"pid"=[1-9][0-9]*'; then
		return 0
	fi
	pgrep -f "$app/Contents/MacOS" >/dev/null 2>&1
}

# --- Lectura de apps.conf -------------------------------------------------------
# Unica fuente de apps: una ruta completa por linea. Se ignoran las lineas vacias
# y todo lo que siga a un "#", se recortan los espacios sobrantes y un "~" inicial
# se expande a la carpeta del usuario. Se acumulan en APPS en el orden del archivo.

load_apps() {
	local line
	[[ -r "$CONF" ]] || return 0
	while IFS= read -r line || [[ -n "$line" ]]; do
		line="${line%%#*}"
		line="${line#"${line%%[![:space:]]*}"}"
		line="${line%"${line##*[![:space:]]}"}"
		[[ -z "$line" ]] && continue
		line="${line/#\~/$HOME}"
		APPS[${#APPS[@]}]="$line"
	done < "$CONF"
}

# --- Carga de la lista ----------------------------------------------------------

APPS=()
load_apps

# Si el archivo no existe o no tiene ninguna app valida, se avisa y se sale.
# No hay lista embebida a proposito: la unica fuente de apps es apps.conf.
if [[ "${#APPS[@]}" -eq 0 ]]; then
	echo "No hay ninguna app configurada en $CONF" >&2
	echo "Agrega una ruta completa por linea (ver el README)." >&2
	exit 1
fi

# --- Modo --list: valida las rutas antes de confiar en ellas --------------------

if [[ "$LIST" == true ]]; then
	echo "apps configuradas en $CONF:"
	for app in "${APPS[@]}"; do
		if [[ -d "$app/Contents/MacOS" ]]; then
			printf "  %-45s ok\n" "$app"
		else
			printf "  %-45s NO EXISTE\n" "$app"
		fi
	done
	exit 0
fi

# --- Contadores y cabecera ------------------------------------------------------

opened=0
already=0
missing=0

if [[ "$DRY_RUN" == true ]]; then
	echo "Simulacion (--dry-run): no se abre nada"
fi
echo "Entorno de desarrollo - $(date '+%H:%M:%S')"
echo

# --- Bucle principal: una app por vuelta ----------------------------------------
# Si la ruta no es un bundle valido se reporta "no instalada"; si ya esta corriendo
# se deja intacta; si no, se abre con "open". Con --dry-run solo se anuncia.

for app in "${APPS[@]}"; do
	name="$(basename "$app" .app)"

	if [[ ! -d "$app/Contents/MacOS" ]]; then
		printf "  %-22s no instalada\n" "$name"
		missing=$(( missing + 1 ))
		continue
	fi

	if is_running "$app"; then
		printf "  %-22s ya estaba abierta\n" "$name"
		already=$(( already + 1 ))
		continue
	fi

	if [[ "$DRY_RUN" == true ]]; then
		printf "  %-22s se abriria\n" "$name"
	else
		open "$app"
		printf "  %-22s abriendo\n" "$name"
	fi
	opened=$(( opened + 1 ))
done

# --- Resumen final --------------------------------------------------------------

echo
echo "abiertas: $opened   ya estaban: $already   no instaladas: $missing"
