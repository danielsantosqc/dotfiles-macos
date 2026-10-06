#!/bin/sh
# ============================================
# PNPM Configuration
# Package Manager - Configuración completa
# ============================================

# Configurar directorio global de pnpm (programa)
export PNPM_HOME="$HOME/Library/pnpm"  # macOS
# export PNPM_HOME="$HOME/.local/share/pnpm"  # Linux

# Agregar pnpm al PATH
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Alias para comandos comunes
alias p="pnpm"
alias px="pnpm dlx"

# Autocompletado de pnpm
if [ -f "$PNPM_HOME/pnpm" ]; then
  eval "$(pnpm completion zsh 2>/dev/null || pnpm completion bash 2>/dev/null)"
fi
