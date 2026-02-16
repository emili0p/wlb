#!/usr/bin/env bash

# This scripts lets you change between shells in kitty based of what you have installed
# changing via reading which shells you have in your bin and letting you pick in a list
# 16th february 2026

KITTY_CONF="$HOME/.config/kitty/kitty.conf"
if [ ! -f "$KITTY_CONF" ]; then
  echo "Kitty config doesnt exists... yet"
  exit 1
fi

echo "Aviables shells in your system:"
echo
SHELLS=()
while read -r line; do
  CLEAN=$(echo "$line" | tr -d '\r' | xargs)
  case "$CLEAN" in
  "" | \#*) continue ;;
  *) SHELLS+=("$CLEAN") ;;
  esac
done </etc/shells

# Mostrar menú
for i in "${!SHELLS[@]}"; do
  printf "%d) %s\n" $((i + 1)) "${SHELLS[$i]}"
done
for i in "${!SHELLS[@]}"; do
  printf "%d) %s\n" $((i + 1)) "${SHELLS[$1]}"
done

echo
read -rp "Select shell number you want to use: " OPTION
if ! [[ "$OPTION" =~ ^[0-9]+$ ]] || [ "$OPTION" -lt 1 ] || [ "$OPTION" -gt "${#SHELLS[@]}" ]; then
  echo "invalid OPTION"
  exit 1
fi

SELECTED_SHELL="${SHELLS[$((OPTION - 1))]}"
echo
echo "selectec shell: $SELECTED_SHELL"

# backup just in case!
cp "$KITTY_CONF" "$KITTY_CONF.bak"

if grep -q "^shell " "KITTY_CONF"; then
  sed -i "s|^shell .*|shell $SELECTED_SHELL|" "$KITTY_CONF"
else
  echo "shell $SELECTED_SHELL" >>"$KITTY_CONF"
fi

echo
echo "Done, Kitty.conf updated"
echo "backup created at Kitty.conf.bak"
echo
echo "Restart kitty to view changes"
