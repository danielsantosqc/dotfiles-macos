#!/bin/bash
# install.sh - prepara esta maquina para usar los dotfiles.
# Se corre UNA vez despues de clonar el repo. No usa sudo.
#
# Hace siete cosas:
#   1. permisos
#   2. enlaza config/ a su sitio (starship, gitconfig, gitignore_global)
#   3. deja ~/.zshrc cargando init.sh
#   4. avisa si falta algun programa
#   5. pregunta por terminal-notifier (la usa bin/alert)
#   6. avisa si falta yt-dlp/ffmpeg (para ytda/ytdv)
#   7. otros programas que usamos (starship, htop, timer, casks)
set -u

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
ZSHRC="$HOME/.zshrc"
FECHA="$(date +%Y%m%d%H%M%S)"

[[ -f "$DOTFILES_DIR/init.sh" ]] || { echo "No encuentro init.sh en $DOTFILES_DIR"; exit 1; }
echo "Dotfiles en $DOTFILES_DIR"

# --- 1. Permisos ---------------------------------------------------------------
# 755 = se ejecuta, 644 = se lee. El 2>/dev/null ignora los globs que no coinciden.
chmod 755 "$DOTFILES_DIR"/bin/*.sh 2>/dev/null
chmod 755 "$DOTFILES_DIR"/tools/*/install.sh "$DOTFILES_DIR"/tools/*/uninstall.sh 2>/dev/null
chmod 755 "$DOTFILES_DIR"/tools/*/dev.sh "$DOTFILES_DIR"/tools/*/dev.command 2>/dev/null
chmod 755 "$DOTFILES_DIR"/tools/*/*.app/Contents/MacOS/* 2>/dev/null
chmod 644 "$DOTFILES_DIR"/shell/*.sh "$DOTFILES_DIR"/shell/*/*.sh 2>/dev/null

# --- 2. config/: symlinks a su sitio, respaldando lo que hubiera ----------------
mkdir -p "$HOME/.config"
enlaza() {   # enlaza <archivo del repo> <destino>
	local origen="$1" destino="$2"
	if [[ -e "$destino" && ! -L "$destino" ]]; then
		mv "$destino" "$destino.bak.$FECHA" || { echo "no pude respaldar $destino"; exit 1; }
		echo "  respaldo: $(basename "$destino") -> .bak.$FECHA"
	fi
	ln -sfn "$origen" "$destino"
	echo "  $(basename "$destino") -> config/$(basename "$origen")"
}
enlaza "$DOTFILES_DIR/config/starship.toml"    "$HOME/.config/starship.toml"
enlaza "$DOTFILES_DIR/config/gitconfig"        "$HOME/.gitconfig"
enlaza "$DOTFILES_DIR/config/gitignore_global" "$HOME/.gitignore_global"

# --- 3. ~/.zshrc: dos lineas y a otra cosa -------------------------------------
if grep -q 'init\.sh' "$ZSHRC" 2>/dev/null; then
	echo "zshrc: ya carga los dotfiles, no lo toco"
else
	if [[ -f "$ZSHRC" ]]; then
		cp "$ZSHRC" "$ZSHRC.bak.$FECHA" || { echo "no pude respaldar ~/.zshrc: no lo toco"; exit 1; }
		echo "zshrc: respaldo del anterior en .zshrc.bak.$FECHA"
	fi
	printf '%s\n' \
		'# Configuracion de zsh. Todo vive en ~/my-dotfiles: edita alli, no aqui.' \
		"export DOTFILES_DIR=\"$DOTFILES_DIR\"" \
		'' \
		'[ -r "$DOTFILES_DIR/init.sh" ] && source "$DOTFILES_DIR/init.sh"' > "$ZSHRC"
	echo "zshrc: reescrito"
fi

# --- 4. Aviso de lo que falta (no instala nada) --------------------------------
for c in git starship node pnpm docker brew; do
	command -v "$c" >/dev/null 2>&1 || echo "falta: $c"
done

# --- 5. terminal-notifier: la usa bin/alert para el banner ---------------------
# Sin ella, alert cae a osascript, que en macOS suele no mostrar nada.
if command -v terminal-notifier >/dev/null 2>&1; then
	echo "terminal-notifier: instalado"
else
	echo
	echo "Falta terminal-notifier (la usa 'alert' para mostrar las notificaciones)."
	echo "  Instalalo con:  brew install terminal-notifier"
	echo "  Repo:           https://github.com/julienXX/terminal-notifier"
	printf "Lo instalamos ahora? [y/N] "
	read -r respuesta
	case "$respuesta" in
		y|Y|yes|Yes|YES|s|S|si|Si|SI|sí|Sí)
			if command -v brew >/dev/null 2>&1; then
				brew install terminal-notifier
			else
				echo "  no encontro brew; instalalo desde https://brew.sh"
			fi
			;;
		*)
			echo "  ok, sigo."
			;;
	esac
fi

# --- 6. Para usar ytda / ytdv (shell/utils/yt-dlp-configs.sh) -------------------
# Necesitan yt-dlp y ffmpeg. Si falta alguno, se ofrece instalarlo con brew.
faltan=()
for c in yt-dlp ffmpeg; do
	command -v "$c" >/dev/null 2>&1 || faltan+=("$c")
done

if (( ${#faltan[@]} == 0 )); then
	echo "yt-dlp y ffmpeg: instalados"
else
	echo
	echo "Para usar 'ytda' y 'ytdv' necesitas instalar lo siguiente:"
	for c in "${faltan[@]}"; do
		case "$c" in
			yt-dlp) echo "  yt-dlp  ->  brew install yt-dlp      repo: https://github.com/yt-dlp/yt-dlp" ;;
			ffmpeg) echo "  ffmpeg  ->  brew install ffmpeg      repo: https://ffmpeg.org" ;;
		esac
	done

	printf "Lo instalamos ahora? [y/N] "
	read -r respuesta
	case "$respuesta" in
		y|Y|yes|Yes|YES|s|S|si|Si|SI|sí|Sí)
			if command -v brew >/dev/null 2>&1; then
				brew install "${faltan[@]}"
			else
				echo "  no encontro brew; instalalo desde https://brew.sh"
			fi
			;;
		*)
			echo "  ok, sigo con el resto."
			sleep 3
			;;
	esac
fi

# --- 7. Otros programas que usamos (uno por uno) ------------------------------
INSTALAR=(
	"brew install starship"
	"brew install htop"
	"brew install caarlos0/tap/timer"
	"brew install --cask appcleaner"
	"brew install --cask codexbar"
	"brew install --cask macfuse"
	"brew install --cask rectangle"
	"brew install --cask monitorcontrol"
	"brew install --cask stats"
	"brew install --cask battery"
	"brew install --cask maccy"
	"brew install --cask portkiller"
	"brew install --cask veracrypt"
	"brew install --cask fuse-t"
)

printf "Instalamos los otros programas que usamos? [y/N] "
read -r respuesta
case "$respuesta" in
	y|Y|yes|Yes|YES|s|S|si|Si|SI|sí|Sí)
		for cmd in "${INSTALAR[@]}"; do
			app="${cmd##* }"; app="${app##*/}"   # --cask maccy -> maccy ; caarlos0/tap/timer -> timer
			echo "-> $cmd"
			if $cmd; then
				printf '\033[32m  -+++++++++++++++++ %s instalado +++++++++++++++++++++++++-\033[0m\n' "$app"
			else
				printf '\033[31m   -!!!!!!!!%s fallo la instalación !!!!!!!!!!!!!!!!!!!!!!-\033[0m\n' "$app"
			fi
		done
		;;
	*) echo "  ok, sigo." ;;
esac

echo
echo "Listo. En una terminal nueva ya carga solo; en la actual:  source ~/.zshrc"
echo "A mano si los quieres: los .json de VS Code (manual/vscode) y  sudo tools/chargelimit/install.sh"
