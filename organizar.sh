#!/bin/bash
## requiere ffmepg
# emilio izquierdo
# 14 de mayo de 2026
MUSIC_DIR="$HOME/Música"

find "$MUSIC_DIR" -maxdepth 1 -type f \( \
  -iname "*.mp3" -o \
  -iname "*.flac" -o \
  -iname "*.m4a" -o \
  -iname "*.ogg" \) | while read -r file; do

  album=$(ffprobe -v error \
    -show_entries format_tags=album \
    -of default=noprint_wrappers=1:nokey=1 \
    "$file")

  artist=$(ffprobe -v error \
    -show_entries format_tags=artist \
    -of default=noprint_wrappers=1:nokey=1 \
    "$file")

  # limpiar caracteres
  album=$(echo "$album" | sed 's#[/:*?"<>|]#-#g')
  artist=$(echo "$artist" | sed 's#[/:*?"<>|]#-#g')

  # en dado caso de que no tenga artista mandarlo a Desconocido
  [ -z "$album" ] && album="Álbum Desconocido"
  [ -z "$artist" ] && artist="Artista Desconocido"

  target_dir="$MUSIC_DIR/$artist/$album"

  mkdir -p "$target_dir"

  echo "Moviendo: $file"
  mv "$file" "$target_dir/"
done
