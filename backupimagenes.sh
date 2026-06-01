#!/usr/bin/env bash
# este archivo hace backup de las imagenes de mi laptop a mi pc usando scp
# emilio izquierdo montero
# 31 de mayo de 2025
# requiere scp
REMOTE_HOST="arch"
REMOTE_DIR="Imágenes"

find "$HOME/Imágenes" -type f | while read -r archivo; do
  relativo="${archivo#$HOME/}"

  if ssh "$REMOTE_HOST" "[ -f \"$relativo\" ]"; then
    echo "[EXISTE] $relativo"
  else
    echo "[COPIANDO] $relativo"

    ssh "$REMOTE_HOST" "mkdir -p \"$(dirname "$relativo")\""
    scp "$archivo" "$REMOTE_HOST:$relativo"
  fi
done
