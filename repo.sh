#!/usr/bin/env bash

set -e

# Verificar si estamos dentro de un repositorio Git
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[INFO] Repositorio Git detectado"
  echo "[INFO] Actualizando..."
  git pull
else
  echo "[INFO] No es un repositorio Git"
fi

# Aquí continúa el resto de tu script
echo "[INFO] Ejecutando tareas..."
