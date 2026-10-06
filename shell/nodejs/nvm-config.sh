#!/bin/sh
# ============================================
# NVM Configuration
# Node Version Manager - Configuración completa
# Compatible con Zsh y Bash (macOS y Linux)
# ============================================

# Configurar directorio de NVM
# Usa XDG_CONFIG_HOME si está definido, sino ~/.nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"

# Cargar NVM principal
# '-s' verifica que el archivo existe y no está vacío
# '\.' es lo mismo que 'source' pero más portable
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Cargar autocompletado de NVM
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ============================================
# Auto-switch multi-shell (Zsh + Bash)
# Detecta automáticamente el shell en uso
# y cambia la versión de Node.js al entrar
# en directorios con archivo .nvmrc
# ============================================

# Verificar si estamos en Zsh
if [ -n "$ZSH_VERSION" ]; then
  # ============ SECCIÓN PARA ZSH ============
  
  # Cargar el sistema de hooks de Zsh
  # 'autoload' permite cargar funciones bajo demanda
  # '-U' evita expandir alias durante la carga
  # 'add-zsh-hook' es la utilidad para registrar eventos
  autoload -U add-zsh-hook
  
  # Función que verifica y cambia la versión de Node
  load-nvmrc() {
    # Verificar si existe un archivo .nvmrc en el directorio actual
    # '-f' comprueba que el archivo existe
    # '-r' comprueba que el archivo es legible
    if [[ -f .nvmrc && -r .nvmrc ]]; then
      # Si existe .nvmrc, cambiar a la versión especificada
      # '--silent' evita mostrar mensajes innecesarios
      nvm use --silent
    fi
  }
  
  # Registrar la función para que se ejecute automáticamente
  # cada vez que cambiemos de directorio (evento 'chpwd')
  add-zsh-hook chpwd load-nvmrc
  
  # Ejecutar la función una vez al cargar este script
  # Esto cubre el caso de abrir la terminal directamente
  # en un proyecto que ya tiene .nvmrc
  load-nvmrc

elif [ -n "$BASH_VERSION" ]; then
  # ============ SECCIÓN PARA BASH ============
  
  # En Bash no existe el hook 'chpwd', por lo que
  # necesitamos redefinir la función 'cd' para
  # detectar cuando cambiamos de directorio
  
  # Redefinir la función cd para incluir auto-switch
  cd() {
    # Ejecutar el cambio de directorio normal
    # 'builtin' asegura que usamos el cd original del sistema
    # '$@' pasa todos los argumentos recibidos
    # '|| return' si el cd falla, no continuamos
    builtin cd "$@" || return
    
    # Verificar si existe un archivo .nvmrc en el nuevo directorio
    # '-f' comprueba que el archivo existe
    # '-r' comprueba que el archivo es legible
    if [[ -f .nvmrc && -r .nvmrc ]]; then
      # Si existe .nvmrc, cambiar a la versión especificada
      # '--silent' evita mostrar mensajes innecesarios
      nvm use --silent
    fi
  }
  
  # Verificar al iniciar la terminal
  # Esto cubre el caso de abrir la terminal directamente
  # en un proyecto que ya tiene .nvmrc
  if [[ -f .nvmrc && -r .nvmrc ]]; then
    nvm use --silent
  fi
fi
