#!/usr/bin/env bash
#
# Descarga una playlist de YouTube como MP3 con metadata y thumbnail.

set -euo pipefail

for cmd in yt-dlp ffmpeg; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Falta: $cmd" >&2
    exit 1
  }
done

URL="${1:-}"
if [[ -z "$URL" ]]; then
  read -rp "URL de la playlist: " URL
fi

if [[ ! "$URL" =~ ^https?:// ]]; then
  echo "URL inválida: $URL" >&2
  exit 1
fi

DOWNLOADS_DIR="${DOWNLOADS_DIR:-$HOME/Música}"
mkdir -p "$DOWNLOADS_DIR"
cd "$DOWNLOADS_DIR"

echo "Descargando en: $DOWNLOADS_DIR"
echo

yt-dlp \
  --format 'bestaudio/best' \
  --extract-audio \
  --audio-format mp3 \
  --audio-quality 0 \
  --embed-metadata \
  --embed-thumbnail \
  --convert-thumbnails jpg \
  --parse-metadata '%(playlist_title)s:%(album)s' \
  --parse-metadata '%(playlist_index)s:%(track_number)s' \
  --parse-metadata '%(uploader|)s:%(album_artist)s' \
  --output '%(playlist_title|Album)s/%(playlist_index|00)02d - %(title)s.%(ext)s' \
  --ignore-errors \
  --no-overwrites \
  --newline \
  --progress \
  "$URL"

echo
ALBUM_DIR="$(find "$DOWNLOADS_DIR" -maxdepth 1 -type d -printf '%T@ %p\n' |
  sort -nr | head -n1 | cut -d' ' -f2-)"

echo "Ruta: $ALBUM_DIR"
echo
echo "Contenido:"
find "$ALBUM_DIR" -maxdepth 1 -type f -printf '  %f\n' | sort

echo
echo "Total MP3: $(find "$ALBUM_DIR" -maxdepth 1 -type f -iname '*.mp3' | wc -l)"
