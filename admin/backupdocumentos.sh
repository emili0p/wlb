#!/usr/bin/env bash
# este archivo hace backup de la carpeta im a mi pc usando scp
# emilio izquierdo montero
# 31 de mayo de 2025
# requiere scp

REMOTE_HOST="arch"
REMOTE_DIR="Documentos/" # Copiar dentro de Documentos
LOCAL_DIR="$HOME/Documentos/"

# colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Origen:${NC} $LOCAL_DIR"
echo -e "${BLUE}Destino:${NC} $REMOTE_HOST:$REMOTE_DIR"
echo ""

# Contar archivos antes de copiar
total_archivos=$(find "$LOCAL_DIR" -type f 2>/dev/null | wc -l)
tamaño_total=$(du -sh "$LOCAL_DIR" 2>/dev/null | cut -f1)

echo -e "${BLUE}Archivos a copiar:${NC} $total_archivos"
echo -e "${BLUE}Tamaño total:${NC} $tamaño_total"
echo ""

# Crear directorio remoto
echo -e "${YELLOW}Creando directorio remoto...${NC}"
ssh "$REMOTE_HOST" "mkdir -p '$REMOTE_DIR'" 2>/dev/null

# Copiar TODO de una vez con scp -r
echo -e "${YELLOW}Copiando todos los archivos...${NC}"
echo ""

# Medir tiempo
start_time=$(date +%s)

if scp -r "$LOCAL_DIR" "$REMOTE_HOST:$REMOTE_DIR"; then
  end_time=$(date +%s)
  elapsed=$((end_time - start_time))

  echo ""
  echo -e "${GREEN}Copia completada exitosamente${NC}"
  echo -e "${BLUE}Tiempo total:${NC} ${elapsed} segundos"

  # Verificar archivos remotos
  echo -e "${BLUE}Verificando archivos en remoto...${NC}"
  total_remoto=$(ssh "$REMOTE_HOST" "find '$REMOTE_DIR' -type f 2>/dev/null | wc -l")
  echo -e "${BLUE}Total archivos en remoto:${NC} $total_remoto"
else
  echo ""
  echo -e "${RED} Error durante la copia${NC}"
  exit 1
fi
