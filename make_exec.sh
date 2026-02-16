#!/usr/bin/env bash

# shell script to make all the .sh scripts in a folder executable

#takes a directoy as an input, if not input takes the current one as input
TARGER_DIR="${1:-.}"

SCRIPTS=$(find "$TARGER_DIR" -maxdepth 1 -type f -name "*.sh")

if [ -z "$SCRIPTS" ]; then
  echo "No scripts (.sh) found in $TARGER_DIR"
fi

echo "making the following executable:"
echo "$SCRIPTS"
echo

for script in $SCRIPTS; do
  chmod +x "$script"
  echo "done $script"
done

echo
echo "all scripts in $TARGER_DIR are executable now !!"
echo "have fun hacking :)"
