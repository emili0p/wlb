#!/bin/env bash

# emilio izquierdo
# 16 de enero de 2026
# archivo para listar todos tus juegos de steam con fzf
# y lanzarlos desde la terminal
# requieres fzf y steam

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="gamerunner"
TARGET="$INSTALL_DIR/$SCRIPT_NAME"
VERSION=1.0
SCRIPT_PATH="$(realpath "$0")"

if [[ "$1" == "install" ]]; then
  echo "Instalando $SCRIPT_NAME…"

  mkdir -p "$INSTALL_DIR" || exit 1

  echo "Copiando desde: $SCRIPT_PATH"
  echo "Copiando hacia: $TARGET"

  if ! cp "$SCRIPT_PATH" "$TARGET"; then
    echo "ERROR: no se pudo copiar el script"
    exit 1
  fi

  chmod +x "$TARGET"

  echo "Instalado correctamente como $TARGET"
  exit 0
fi

if [[ "$1" == "uninstall" ]]; then
  rm -f "$HOME/.local/bin/gamerunner"
  echo "Se ha desinstalado gamerunner"
  exit 0
fi

if [[ "$1" == "-v" || "$1" == "--version" ]]; then
  echo "$VERSION"
  exit 0
fi

if [[ "$1" == "-h" || "$1" == "--help " ]]; then
  cat <<EOF
gamerunner es un lanzador de juegos de steam desde la clit

uso:
  gamerunner        Ejecuta el launcher
  gamerunner install    installa en ~/.local/bin/
  gamerunner uninstall   Desinstala el launcher

Require de 
  - steam
  - fzf

EOF
  exit 0
fi

# logica
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

[ -z "$selected" ] && exit 0

appid=$(echo "$selected" | cut -f1)
name=$(echo "$selected" | cut -f2)

echo "lanzando : $name "
steam "steam://rungameid/$appid" >/dev/null 2>&1 &
