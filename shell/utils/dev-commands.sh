#!/usr/bin/env bash
# ============================================
# dev-commands.sh - chuletas de comandos
# Referencia rápida para consultar en la terminal
# Uso: source ~/my-dotfiles/dev-commands.sh
#
#   grep-flags     -> patrones, flags y pipes de grep
#   find-flags     -> búsqueda de archivos con find
#   dev-comandos   -> comandos mas usados en backend
# ============================================

# GREP - referencia rápida
dev-grep() {
    command cat <<'EOF'
=================== PATRONES ===================
•  texto literal         Ej: grep "error" archivo
•  ^ = empieza con       Ej: grep "^error" archivo
•  $ = termina con       Ej: grep "error$" archivo
•  . = un carácter cualq Ej: grep "er.ror" archivo
•  [ ] = grupo de chars  Ej: grep "[Ee]rror" archivo
•  [a-z] [0-9] = rango   Ej: grep "[0-9]" archivo
•  ^$ = línea vacía      Ej: grep "^$" archivo
•  | = "o" (con -E)      Ej: grep -E "error|warning" archivo
•  * = repetir anterior  Ej: grep -E "ab*" archivo
•  ? = opcional (con -E) Ej: grep -E "colou?r" archivo
•  \. = punto literal    Ej: grep "error\." archivo

==================== FLAGS =====================
•  -i = ignora mayúsc/minúsc     Ej: grep -i "patrón" archivo
•  -v = excluye coincidencias    Ej: grep -v "patrón" archivo
•  -w = palabra completa         Ej: grep -w "patrón" archivo
•  -n = número de línea          Ej: grep -n "patrón" archivo
•  -c = contar coincidencias     Ej: grep -c "patrón" archivo
•  -E = regex extendido          Ej: grep -E "patrón1|patrón2" archivo
•  -o = solo la parte que match  Ej: grep -o "patrón" archivo
•  -r = recursivo en carpeta     Ej: grep -r "patrón" .
•  -l = archivos con match       Ej: grep -l "patrón" *.txt
•  -L = archivos SIN match       Ej: grep -L "patrón" *.txt
•  -A 2 = 2 líneas después       Ej: grep -A 2 "patrón" archivo
•  -B 2 = 2 líneas antes         Ej: grep -B 2 "patrón" archivo
•  -C 2 = contexto antes+desp.   Ej: grep -C 2 "patrón" archivo
•  -m 5 = máx 5 coincidencias    Ej: grep -m 5 "patrón" archivo
•  -e = varios patrones          Ej: grep -e "error" -e "warning" archivo

nota: ^ $ . [ ] * van en grep normal; | + ? { } ( ) usan -E

================= OPERADORES ==================
  A ;  B    (secuencia) B corre siempre (al terminar A)
  A |  B    (pipe)      la salida de A entra a B
  A && B    (y)         B solo si A salio bien
  A || B    (o)         B solo si A fallo

============ USO CON PIPES (STDIN) ============
grep lee de 2 formas:
•  archivo       Ej: grep "error" app.log
•  stdin (pipe)  Ej: ps aux | grep -i "spotify"     ← "spotify" es el patrón

pipe: comando | grep "patrón"
•  history | grep "git"          buscar en tu historial
•  ps aux | grep -i "spotify"    buscar un proceso (spotify = patrón)
•  ls -la | grep "^d"            solo directorios
•  brew list | grep python       paquetes instalados (python = patrón)

nota: cat archivo | grep es innecesario; usa grep "patrón" archivo
EOF
}

# FIND - referencia rápida
dev-find() {
    command cat <<'EOF'
============ FIND ============
•  find = busca archivos por NOMBRE/atributos (tipo, tamaño, fecha)
============= SINTAXIS =============
find <ruta> <opciones>
<ruta>: . = actual | ~ = home del usuario | / = todo el sistema

============ OPCIONES MÁS USADAS ============
•  -name     = nombre exacto                 Ej: find . -name "Nombre.m4a"
•  -iname    = nombre sin importar mayúsc.   Ej: find ~ -iname "*nombre*"
•  -type f   = solo archivos                Ej: find . -type f -name "*.sh"
•  -type d   = solo carpetas                Ej: find . -type d
•  -size +10M= mayores a 10 MB              Ej: find ~ -size +100M
•  -mtime -7 = modificados últimos 7 días   Ej: find ~/Music -mtime -1
•  -empty    = archivos/carpetas vacíos     Ej: find . -type f -empty
•  -maxdepth N = no bajar más de N niveles  Ej: find . -maxdepth 2 -name "*.sh"
•  -delete   = borra lo encontrado          Ej: find . -name "*.tmp" -delete
•  -exec     = ejecutar comando en c/u      Ej: find . -name "*.sh" -exec chmod +x {} \;
•  !         = negación (excluir)           Ej: find . -name "*.sh" ! -name "test*"

============ COMODINES (wildcards) ============
ejemplo base: "Cancion bonita - gatitos.mp3"

•  *         = 0 o más caracteres (cualquier cosa)    Ej: find . -iname "*.mp3"           → sí (termina en .mp3)
•  *gatitos* = el nombre CONTIENE "gatitos"          Ej: find . -iname "*gatitos*"        → sí
•  ?         = exactamente 1 carácter                 Ej: find . -iname "gatito?.mp3"      → sí (la "s")
•  [ ]       = 1 carácter del grupo/rango             Ej: find . -iname "gatito[a-z].mp3"  → sí (la "s")
•  [0-9]     = 1 dígito                               Ej: find . -iname "gatito[0-9].mp3"  → no (no hay dígito)
•  [!0-9]    = 1 carácter que NO sea dígito           Ej: find . -iname "*[!0-9].mp3"     → sí

============ EJEMPLOS REALES ============
•  find ~/Music -iname "*nombre*"            buscar una canción
•  find ~/Music -type f -iname "*.mp3"      listar todos tus mp3
•  find ~ -size +500M -type f 2>/dev/null   archivos gigantes que ocupan espacio
•  find . -maxdepth 2 -type d               solo carpetas (sin bajar mucho)
•  find ~/Descargas -mtime -1               lo que descargaste hoy

============ ERRORES DE PERMISOS ============
•  añade 2>/dev/null para ocultarlos
   Ej: find / -iname "nombre*" 2>/dev/null

============ OPERADORES (encadenar comandos) ============
  A ;  B    (secuencia) B corre siempre (al terminar A)
  A |  B    (pipe)      la salida de A entra a B
  A && B    (y)         B solo si A salio bien
  A || B    (o)         B solo si A fallo

============ EJEMPLOS CON find ============
•  ;   find . -name "*.tmp" -delete ; echo "limpieza terminada"
•  |   find . -name "*.sh" | wc -l                    cuantos scripts hay
•  |   find ~/Music -type f -iname "*.mp3" | sort     ordenar la lista
•  &&  find . -name "*.sh" -exec chmod +x {} + && echo "permisos OK"
•  ||  find /ruta/inexistente 2>/dev/null || echo "la ruta no existe"

nota: find sale con 0 aunque NO encuentre nada; solo falla si hay error
      (ruta inexistente, permisos...). Para "no hay resultados" usa:
      find . -name "*.log" | grep -q . || echo "no hay logs"
EOF
}

# DEV - comandos mas usados (backend)
dev-commands() {
    command cat <<'EOF'
============ ARCHIVOS Y CARPETAS ============
•  ls      = listar              Ej: ls -la
•  cd      = cambiar carpeta    Ej: cd ~/proyecto
•  pwd     = carpeta actual     Ej: pwd
•  cp      = copiar             Ej: cp app.js app.js.bak
•  mv      = mover/renombrar    Ej: mv viejo.txt nuevo.txt
•  rm      = borrar             Ej: rm -i archivo.tmp
•  cat     = ver contenido      Ej: cat package.json
•  less    = leer paginando     Ej: less app.log
•  tail -f = ver log en vivo    Ej: tail -f app.log

============ GIT ============
•  git status                  ver cambios pendientes
•  git log --oneline           historial resumido
•  git diff                    ver cambios sin commitear
•  git add .                   agregar cambios
•  git commit -m "mensaje"      guardar cambios
•  git push / git pull         subir / bajar cambios
•  git branch                  ver ramas
•  git stash                   guardar cambios temporalmente

============ HTTP / APIs ============
•  curl -i "url"                         ver respuesta con headers
•  curl -s "url" | jq                    respuesta JSON formateada
•  curl -X POST "url" -H "Content-Type: application/json" -d '{"key":"value"}'
•  ping host                             ¿el servidor responde?
•  dig dominio                           consultar DNS
•  nc -vz host 3306                      ¿el puerto está abierto?

============ PROCESOS Y SISTEMA ============
•  ps aux | grep "proceso"       ver un proceso
•  top  /  htop                  uso de CPU/RAM en vivo
•  kill PID                      cerrar un proceso
•  df -h                         espacio en disco
•  du -sh *                      tamaño de cada carpeta
•  lsof -i :8080                 qué proceso usa el puerto 8080

============ REMOTO ============
•  ssh user@servidor                 entrar a un servidor
•  scp archivo user@servidor:/ruta   copiar archivo a remoto
•  rsync -av carpeta/ user@servidor:/ruta/   sincronizar carpetas

============ CONTENEDORES (docker) ============
•  docker ps                         contenedores activos
•  docker logs -f nombre             ver sus logs en vivo
•  docker exec -it nombre bash       entrar al contenedor
•  docker compose up -d              levantar servicios

============ DATOS Y TEXTOS ============
•  jq . archivo.json                 formatear JSON legible
•  wc -l archivo                     contar líneas
•  sort archivo | uniq -c            contar duplicados
•  grep -rn "texto" .               buscar en contenido (recursivo)
•  sed -i '' 's/viejo/nuevo/g' archivo   reemplazar texto (macOS)
EOF
}
# OPERADORES - encadenar comandos
dev-operators() {
    command cat <<'EOF'
============ OPERADORES (encadenar comandos) ============
•  ;    A ;  B    B corre siempre, cuando A termine
•  |    A |  B    la salida (stdout) de A entra a la entrada (stdin) de B
•  &&   A && B    B solo si A salido bien (exit 0)
•  ||   A || B    B solo si A fallo (exit != 0)

============ EJEMPLOS ============
•  ;   mkdir -p backup ; cp -r datos backup/        crea y copia en secuencia
•  ;   cd ~/proyectos ; ls                          entra y lista
•  ;   date ; uptime                                dos comandos seguidos
•  |   ps aux | grep -i docker                      filtra la salida
•  |   cat app.log | grep -i error | wc -l          cuenta los errores
•  |   history | grep git                           busca en el historial
•  &&  mkdir build && cd build                      entra solo si se creo
•  &&  git add . && git commit -m "wip"             commit solo si add fue bien
•  &&  cd ~/proyecto && npm install                 instala si la carpeta existe
•  ||  cd ~/proyecto || echo "no existe"            avisa si fallo
•  ||  ping -c1 host >/dev/null || echo "sin conexion"
•  ||  find /ruta/inexistente 2>/dev/null || echo "ruta no existe"

•  cd proyecto && git pull && npm test || echo "algo fallo"
EOF
}