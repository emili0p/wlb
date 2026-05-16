#!/usr/bin/env bash

# emilio izquierdo
# 14 de enero de 2026
# archivo para convertir un directorio con archivos flac a mp3 en VO
# requieres ffmpeg
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Uso: $0 <folder>"
  exit 1
fi

SRC_DIR="$1"

# validar ruta
SRC_DIR="$(realpath -e -- "$1")" || {
  echo "Error: la ruta no existe"
  exit 1
}

if [ ! -d "$SRC_DIR" ]; then
  echo "Error: '$SRC_DIR' no es un directorio"
  exit 1
fi

echo "Buscando archivos FLAC en:"
echo "$SRC_DIR"
echo

# cargar archivos
mapfile -t FILES < <(find "$SRC_DIR" -type f -iname "*.flac")

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "No hay archivos FLAC en este directorio"
  exit 0
fi

echo "Los siguientes archivos serán convertidos a MP3 320kbps:"
echo "--------------------------------------------------------"

for f in "${FILES[@]}"; do
  echo "$f"
done

echo
read -rp "Desea continuar con la conversión [y/N]: " CONFIRM
CONFIRM=${CONFIRM,,}

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "yes" ]]; then
  echo "Cancelado."
  exit 0
fi

echo
echo "Empezando conversión..."
echo

for f in "${FILES[@]}"; do

  # mejor manejo de extensiones (.flac / .FLAC / etc)
  out="${f%.*}.mp3"

  if [ -f "$out" ]; then
    echo "Saltando (ya existe): $out"
    continue
  fi

  echo "Convirtiendo:"
  echo " $f"

  # conversion segura + borrado solo si sale bien
  if ffmpeg -loglevel error -stats \
    -i "$f" \
    -map_metadata 0 -vn \
    -c:a libmp3lame -q:a 0 \
    "$out"; then

    echo " OK  convertido"

    echo " borrando original FLAC"
    rm -f -- "$f"

  else
    echo " ERROR  no se borra: $f"
  fi

  echo

done

echo "Proceso terminado."
