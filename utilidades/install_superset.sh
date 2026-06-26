#!/usr/bin/env bash

set -e
VENV_NAME="superset-venv"
SUPERSET_PORT=8088

echo
echo "[1/8] Instalando dependencias del sistema..."

if command -v apt >/dev/null; then
  sudo apt update
  sudo apt install -y \
    python3 \
    python3-venv \
    python3-pip \
    build-essential \
    libssl-dev \
    libffi-dev \
    libsasl2-dev \
    libldap2-dev \
    default-libmysqlclient-dev \
    pkg-config
elif command -v pacman >/dev/null; then
  sudo pacman -Sy --needed \
    python \
    python-pip \
    base-devel
else
  echo "Distribucin no soportada"
  exit 1
fi

echo
echo "[2/8] Creando entorno virtual..."

python3 -m venv "$VENV_NAME"

echo
echo "[3/8] Activando entorno..."

source "$VENV_NAME/bin/activate"

echo
echo "[4/8] Actualizando pip..."

pip install --upgrade pip setuptools wheel

echo
echo "[5/8] Instalando Apache Superset..."

pip install apache-superset

echo
echo "[6/8] Inicializando base de datos..."

superset db upgrade

echo
echo "[7/8] Creando usuario administrador..."

superset fab create-admin \
  --username admin \
  --firstname Admin \
  --lastname User \
  --email admin@example.com \
  --password admin

echo
echo "[8/8] Inicializando Superset..."

superset init

echo
echo " Instalación completada"
echo
echo "Para iniciar Superset:"
echo
echo "source $VENV_NAME/bin/activate"
echo "superset run -p $SUPERSET_PORT --with-threads --reload --debugger"
echo
echo "Abrir:"
echo "http://localhost:$SUPERSET_PORT"
echo
echo "Usuario : admin"
echo "Contraseña : admin"
