#!/usr/bin/env bash

set -e

if ! command -v macchanger >/dev/null 2>&1; then
  echo "No tienes instalado macchanger."
  echo "Instalalo con tu pm e inténtalo de nuevo."
  exit 1
fi

mapfile -t interfaces < <(ip -o link show | awk -F': ' '{print $2}' | grep -v '^lo$')

if [ ${#interfaces[@]} -eq 0 ]; then
  echo "No se encontraron interfaces"
  exit 1
fi

echo "Seleccione la interfaz:"
select iface in "${interfaces[@]}"; do
  if [[ -n "$iface" ]]; then
    break
  fi
  echo "Opción inválida."
done

echo "Cambiando la MAC de $iface..."

sudo ip link set "$iface" down
sudo macchanger -r "$iface"
sudo ip link set "$iface" up

echo "MAC cambiada"
