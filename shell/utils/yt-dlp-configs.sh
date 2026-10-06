#!/usr/bin/env bash
# ============================================
# yt-dlp-configs.sh - funciones para yt-dlp
# Uso: source ~/my-dotfiles/yt-dlp-configs.sh
#
#   link_sanitize "url"  -> devuelve la URL sin la lista de reproduccion
#   ytda "url"           -> descarga solo AUDIO (m4a, mejor calidad)
#   ytdv "url"           -> descarga VIDEO mp4 (avc1 + mp4a)
#
# Ejemplo:
#   ytda "https://www.youtube.com/watch?v=abcdef&list=RD123&index=4"
#     -> ----URL acortado---
#     -> New-URL https://www.youtube.com/watch?v=abcdef
# ============================================

# Quita los parametros de lista de reproduccion (playlist) de una URL de YouTube.
# Soporta formato largo (watch?v=...&list=...) y corto (youtu.be/...?list=...).
link_sanitize() {
    local url="$1"

    if [[ "$url" == *"&list="* ]]; then
        url="${url%%&*}"
    elif [[ "$url" == *"?list="* ]]; then
        url="${url%%\?*}"
    fi

    echo '----URL acortado---' >&2
    echo "New-URL $url" >&2
    echo "$url"
}

# Descarga solo audio en m4a
#   -x                      extrae el audio
#   --audio-format m4a      convierte el contenedor a m4a
#   -f bestaudio            elige la mejor pista de audio
#   -o "%(title)s.%(ext)s"  nombra el archivo con el titulo del video
#   "$(link_sanitize "$1")"  usa la URL ya saneada (sin playlist)

ytda() {
    yt-dlp -x --audio-format m4a -f bestaudio -o "%(title)s.%(ext)s" "$(link_sanitize "$1")"
}

# Descarga video en mp4 (prioriza codecs compatibles: H.264 avc1 + audio AAC mp4a; si no, el mejor disponible)

ytdv() {
    yt-dlp -f "bestvideo[vcodec^=avc1]+bestaudio[acodec^=mp4a]/best[vcodec^=avc1]" --merge-output-format mp4 "$(link_sanitize "$1")"
}

# sin sanitization de links 

#alias de yt-dlt(youtube-dowloader)
#alias ytda='yt-dlp -x --audio-format m4a -f bestaudio -o "%(title)s.%(ext)s"'
#alias ytdv='yt-dlp -f "bestvideo[vcodec^=avc1]+bestaudio[acodec^=mp4a]/best[vcodec^=avc1]" --merge-output-format mp4'