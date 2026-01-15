#!/usr/bin/env bash

# emilio izquierdo
# 14 de enero de 2026
# archivo para convertir un directorio con archivos flac a mp3 en VO
# requieres ffmpeg

set -e
if [ $# -ne 1 ]; then
  echo "Usando $0 <folder>"
  exit 1
fi

SRC_DIR="$1"

if ! SRC_DIR="$(realpath -e -- "$1")"; then
  echo "Error: la ruta no existe"
  exit 1
fi

if [ ! -d "$SRC_DIR" ]; then
  echo "Error: '$SRC_DIR' no es un directorio"
  exit 1
fi

echo "Buscando archivos flac en:"
echo "$SRC_DIR"
echo

mapfile -t FILES < <(find "$SRC_DIR" -type f -iname "*.flac")

if [ ${FILES[0]} -eq 0 ]; then
  echo "No hay archivos flac en este directorio"
  exit 0
fi

echo "los siguientes archivos seran convertidos a mp3 320kbps:"
echo "--------------------------------------------------------"

for f in "${FILES[@]}"; do
  echo "$f"
done

read -rp "Desea continuar con la conversion [y/N] : " CONFIRM
CONFIRM=${CONFIRM,,}

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "yes" ]]; then
  echo "Cancelado."
  exit 0
fi

echo
echo "Empezando a convertir"
echo

for f in "${FILES[@]}"; do
  out="${f%.flac}.mp3"

  if [ -f "$out" ]; then
    echo "saltando archivo (ya existe): $out"
    continue
  fi

  echo "conveTiendo: "
  echo " $f"
  # donde se hace todo
  ffmpeg -loglevel error -stats \
    -i "$f" \
    -map_metadata 0 -vn \
    -c:a libmp3lame -q:a 0 \
    "$out"
done

echo
