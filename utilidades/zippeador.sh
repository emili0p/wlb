#!/usr/bin/env bash

mapfile -t ITEMS < <(find . -maxdepth 1 ! -name "." -printf "%f\n" | sort)

echo "Archivos y carpetas disponibles:"
echo

for i in "${!ITEMS[@]}"; do
  printf "%2d) %s\n" "$((i + 1))" "${ITEMS[$i]}"
done

echo
read -rp "Selecciona un rango (ej. 3-8) o nmeros separados por espacios (ej. 1 4 7): " SELECCION

SELECCIONADOS=()

if [[ "$SELECCION" =~ ^([0-9]+)-([0-9]+)$ ]]; then
  INICIO=${BASH_REMATCH[1]}
  FIN=${BASH_REMATCH[2]}

  for ((i = INICIO; i <= FIN; i++)); do
    if ((i >= 1 && i <= ${#ITEMS[@]})); then
      SELECCIONADOS+=("${ITEMS[$((i - 1))]}")
    fi
  done
else
  for n in $SELECCION; do
    if [[ "$n" =~ ^[0-9]+$ ]] && ((n >= 1 && n <= ${#ITEMS[@]})); then
      SELECCIONADOS+=("${ITEMS[$((n - 1))]}")
    fi
  done
fi

if [ ${#SELECCIONADOS[@]} -eq 0 ]; then
  echo "No se selecciono ningn elemento valido."
  exit 1
fi

echo
echo "Se comprimiran:"
printf " - %s\n" "${SELECCIONADOS[@]}"

echo
read -rp "Nombre del ZIP (sin .zip): " ZIPNAME

zip -r "${ZIPNAME}.zip" "${SELECCIONADOS[@]}"

echo
echo "Archivo creado: ${ZIPNAME}.zip"
