#!/usr/bin/env bash
# requiere ffmepg, figlet y cowsay
# emilio izquierdo
# 14 de mayo de 2026
set -euo pipefail

MUSIC_DIR="$HOME/Música"

clear
show_banner() {

  local cols
  cols=$(tput cols)

  figlet -f slant "organizador" | while IFS= read -r line; do

    padding=$(((cols - ${#line}) / 2))

    ((padding < 0)) && padding=0

    printf "%*s%s\n" "$padding" "" "$line"

  done
}

pause() {
  echo
  read -rp "Presione ENTER para continuar..."
}

sanitize() {
  echo "$1" |
    sed 's#[/:*?"<>|]#-#g' |
    sed 's/^ *//;s/ *$//'
}

organize_music() {

  echo
  echo "Organizando música..."
  echo

  find "$MUSIC_DIR" -maxdepth 1 -type f | while read -r file; do

    ext="${file##*.}"

    case "${ext,,}" in
    mp3 | flac | ogg | m4a | wav) ;;
    *)
      continue
      ;;
    esac

    echo "Procesando: $(basename "$file")"

    album=$(ffprobe -v error \
      -show_entries format_tags=album \
      -of default=noprint_wrappers=1:nokey=1 \
      "$file" 2>/dev/null |
      sed '/^$/d' |
      head -n1)

    year=$(ffprobe -v error \
      -show_entries format_tags=date \
      -of default=noprint_wrappers=1:nokey=1 \
      "$file" 2>/dev/null |
      sed '/^$/d' |
      head -n1)

    album=$(sanitize "$album")
    year=$(sanitize "$year")

    [[ -z "$album" ]] && album="Unknown Album"

    if [[ "$year" =~ ^[0-9]{4}$ ]]; then
      folder_name="$year - $album"
    else
      folder_name="$album"
    fi

    target_dir="$MUSIC_DIR/$folder_name"

    mkdir -p "$target_dir"

    target_file="$target_dir/$(basename "$file")"

    if [[ -e "$target_file" ]]; then
      echo "Duplicado detectado, saltando."
      echo
      continue
    fi

    mv -n "$file" "$target_file"

    echo "→ Movido a:"
    echo "  $folder_name"
    echo
  done

  clear

  cowsay -f tux "Disfrute"

  echo
}

dry_run() {

  echo
  echo "Modo simulación"
  echo

  find "$MUSIC_DIR" -maxdepth 1 -type f | while read -r file; do

    ext="${file##*.}"

    case "${ext,,}" in
    mp3 | flac | ogg | m4a | wav) ;;
    *)
      continue
      ;;
    esac

    album=$(ffprobe -v error \
      -show_entries format_tags=album \
      -of default=noprint_wrappers=1:nokey=1 \
      "$file" 2>/dev/null |
      sed '/^$/d' |
      head -n1)

    year=$(ffprobe -v error \
      -show_entries format_tags=date \
      -of default=noprint_wrappers=1:nokey=1 \
      "$file" 2>/dev/null |
      sed '/^$/d' |
      head -n1)

    album=$(sanitize "$album")
    year=$(sanitize "$year")

    [[ -z "$album" ]] && album="Unknown Album"

    if [[ "$year" =~ ^[0-9]{4}$ ]]; then
      folder_name="$year - $album"
    else
      folder_name="$album"
    fi

    echo "[DRY RUN]"
    echo "\"$(basename "$file")\""
    echo "→ \"$folder_name\""
    echo
  done
}

while true; do

  clear
  show_banner

  echo
  echo "=================================================="
  echo "              ORGANIZADOR DE MUSICA"
  echo "=================================================="
  echo
  echo "1) Organizar música"
  echo "2) Simulación (dry run)"
  echo "3) Salir"
  echo

  read -rp "Seleccione una opción: " option

  case "$option" in

  1)
    clear
    show_banner
    organize_music
    pause
    ;;

  2)
    clear
    show_banner
    dry_run
    pause
    ;;

  3)
    clear

    cowsay -f tux "Adios y disfrute su musica :)"

    echo
    exit 0
    ;;
  *)
    echo
    echo "Opción inválida."
    sleep 1
    ;;

  esac

done
