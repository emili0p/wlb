#!/bin/bash

# Este script muestra todos los logos que onefetch puede mostrar
# requiere onefetch
# es ejecutando pasandole el output de
# onefetch --languages  a este archivo
# ejemplo onefetch --languages | Lenguaje.sh

normalizar() {
  local s="$1"

  # minúsculas
  s="$(echo "$s" | tr '[:upper:]' '[:lower:]')"

  # quitar espacios alrededor
  s="$(echo "$s" | xargs)"

  # casos especiales conocidos de onefetch
  case "$s" in
  "visual basic") echo "visualbasic" ;;
  "objective c") echo "objective-c" ;;
  "protocol buffers") echo "protocol-buffers" ;;
  "jupyter notebooks") echo "jupyter-notebooks" ;;
  "emacs lisp") echo "emacs-lisp" ;;
  "c plus plus" | "c++") echo "c++" ;;
  "f sharp" | "f#") echo "f#" ;;
  *)
    # regla general: quitar espacios
    echo "${s// /}"
    ;;
  esac
}

while IFS= read -r lang; do
  [[ -z "$lang" || "$lang" =~ ^# ]] && continue

  lang_norm="$(normalizar "$lang")"

  echo "=============================="
  echo " Lenguaje: $lang_norm"
  echo "=============================="

  if ! onefetch --ascii-language "$lang_norm"; then
    echo "[!] No soportado por onefetch"
  fi

  echo
  echo
done <"${1:-/dev/stdin}"
