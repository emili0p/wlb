#!/usr/bin/env bash
# requiere ffmepg
# emilio izquierdo
# 14 de mayo de 2026
set -euo pipefail

MUSIC_DIR="$HOME/Música"
DRY_RUN=false

# FLAG que nos permite ver el resultado antes de ejecutar:
# ./script.sh --dry-run
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi
# funcion para mover los archivos de directorio a directorio b
move_file() {
  local src="$1"
  local dst="$2"

  if $DRY_RUN; then
    echo "[DRY] mv \"$src\" \"$dst\""
  else
    mv -n "$src" "$dst"
  fi
}
# limpiar lo que sea que tenemos
sanitize() {
  echo "$1" | sed 's#[/:*?"<>|]#-#g' | sed 's/^ *//;s/ *$//'
}

echo "Escaneando archivos sin organizar en:"
echo "$MUSIC_DIR"
echo
# solamente busca en la raiz
find "$MUSIC_DIR" -maxdepth 1 -type f | while read -r file; do

  ext="${file##*.}"

  case "${ext,,}" in
  mp3 | flac | ogg | m4a | wav) ;;

  jpg | jpeg | png)
    echo "Saltando imagen: $(basename "$file")"
    continue
    ;;

  *)
    # salta los archivos que no sean flac ogg m4a o wav
    echo "Saltando archivo desconocido: $(basename "$file")"
    continue
    ;;
  esac

  echo "Procesando: $(basename "$file")"

  ## leer metadata
  album=$(ffprobe -v error \
    -show_entries format_tags=album \
    -of default=noprint_wrappers=1:nokey=1 \
    "$file" 2>/dev/null | head -n1)

  year=$(ffprobe -v error \
    -show_entries format_tags=date \
    -of default=noprint_wrappers=1:nokey=1 \
    "$file" 2>/dev/null | head -n1)

  # Limpiar
  album=$(sanitize "$album")
  year=$(sanitize "$year")

  # Si no hay album o la cancion no tiene tag
  if [[ -z "$album" ]]; then
    album="Unknown Album"
  fi

  # Si hay un año valido usamos un regex para leer eso de la salida de ffmpeg
  if [[ "$year" =~ ^[0-9]{4}$ ]]; then
    folder_name="$year - $album"
  else
    folder_name="$album"
  fi

  target_dir="$MUSIC_DIR/$folder_name"

  if $DRY_RUN; then
    echo "[DRY] mkdir -p \"$target_dir\""
  else
    mkdir -p "$target_dir"
  fi

  target_file="$target_dir/$(basename "$file")"

  if [[ -e "$target_file" ]]; then
    echo "Duplicado detectado, saltando."
    echo
    continue
  fi

  move_file "$file" "$target_file"

  echo "→ Movido a:"
  echo "  $folder_name"
  echo
done

echo "Listo."
