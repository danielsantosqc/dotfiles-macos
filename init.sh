#!/bin/zsh
# init.sh - punto de entrada de los dotfiles.
# Es lo unico que ~/.zshrc necesita sourcear.
# No instala nada ni escribe en disco: solo deja el shell listo.
# Debe ser silencioso y rapido, porque corre en cada terminal nueva.

export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/my-dotfiles}"

# --- shell/: todo lo que se sourcea ---------------------------------------------
# find + sort da un orden estable; find evita el error de zsh cuando un glob no
# coincide (shell/nodejs vacio, por ejemplo). El while corre en el shell actual,
# asi que las funciones y alias que se definan aqui persisten.
if [[ -d "$DOTFILES_DIR/shell" ]]; then
	while IFS= read -r f; do
		[[ -r "$f" ]] && source "$f"
	done < <(find "$DOTFILES_DIR/shell" -type f -name '*.sh' | sort)
fi

# --- PATHs ----------------------------------------------------------------------
[[ -d "$HOME/.local/bin" ]] && export PATH="$PATH:$HOME/.local/bin"
[[ -d "$HOME/.rar" ]] && export PATH="$HOME/.rar:$PATH"
# bin/ se añade al final del bloque para que quede primero en el PATH: los scripts
# del repo (notify, watch-docker-containers.sh) se llaman por su nombre.
export PATH="$DOTFILES_DIR/bin:$PATH"

# --- Solo zsh: completions de Docker y compinit ---------------------------------
if [[ -n "${ZSH_VERSION:-}" ]]; then
	if [[ -d "$HOME/.docker/completions" ]]; then
		fpath=("$HOME/.docker/completions" $fpath)
	fi
	autoload -Uz compinit && compinit
fi

# --- Starship -------------------------------------------------------------------
# Sin STARSHIP_CONFIG: el symlink de install.sh lo deja en la ruta que starship
# busca por defecto (~/.config/starship.toml).
if command -v starship >/dev/null 2>&1; then
	[[ -n "${ZSH_VERSION:-}" ]] && eval "$(starship init zsh)"
fi
