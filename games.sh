#!/bin/env bash

# emilio izquierdo
# 16 de enero de 2026
# archivo para listar todos tus juegos de steam con fzf
# y lanzarlos desde la terminal
# requieres fzf y steam

STEAM_DIR=$(realpath "$HOME/.steam/steam" 2>/dev/null)
if [ ! -d "$STEAM_DIR/steamapps" ]; then
  echo "No se encontró el directorio real de Steam"
  exit 1
fi
APPS_DIR="$STEAM_DIR/steamapps"

command -v fzf >/dev/null || {
  echo "fzf no esta instalado"
  exit 1
}

command -v steam >/dev/null || {
  echo "fzf no esta instalado"
  exit 1
}

[ -d "$APPS_DIR" ] || {
  echo "no se encontro el directorio de steam"
  exit 1
}

# extraer datos
games=$(
  grep -R '"name"' "$APPS_DIR"/appmanifest_*.acf 2>/dev/null |
    sed -E 's|.*/appmanifest_([0-9]+)\.acf:.*"name"[[:space:]]+"([^"]+)"|\1\t\2|' |
    sort -k2
)

[ -z "$games" ] && {
  echo "no se encontraron juegos"
  exit 1
}
#PROMPT DE FZF
selected=$(echo "$games" | fzf \
  --prompt="Steam >" \
  --with-nth=2 \
  --delimiter=$'\t' \
  --border)
echo "$games" | wc -l

[ -z "$selected" ] && exit 0

appid=$(echo "$selected" | cut -f1)
name=$(echo "$selected" | cut -f2)

echo "lanzando : $name "
steam "steam://rungameid/$appid" >/dev/null 2>&1 &
