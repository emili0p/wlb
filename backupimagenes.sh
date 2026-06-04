#!/usr/bin/env bash
# este archivo hace backup de las imagenes de mi laptop a mi pc usando scp
# emilio izquierdo montero
# 31 de mayo de 2025
# requiere scp

REMOTE_HOST="arch"
REMOTE_DIR="Imágenes"
LOCAL_DIR="$HOME/Imágenes"

# colors sss
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'
# counters for files
total_copiados=0
total_existentes=0
total_renombrados=0
total_bytes=0

human_size() {
  local size=$1
  if [ $size -ge 1073741824 ]; then
    echo "$(echo "scale=2; $size/1073741824" | bc) GB"
  elif [ $size -ge 1048576 ]; then
    echo "$(echo "scale=2; $size/1048576" | bc) MB"
  elif [ $size -ge 1024 ]; then
    echo "$(echo "scale=2; $size/1024" | bc) KB"
  else
    echo "${size} B"
  fi
}

get_unique_name() {
  local remote_path="$1"
  local dir=$(dirname "$remote_path")
  local base=$(basename "$remote_path")
  local name="${base%.*}"
  local ext="${base##*.}"
  local counter=1

  # Si es archivo sin extensión
  if [ "$name" = "$base" ]; then
    ext=""
  fi

  while ssh -n "$REMOTE_HOST" "[ -f \"$dir/$name${ext:+.}$ext\" ]" 2>/dev/null; do
    name="${base%.*}-$counter"
    ((counter++))
  done

  if [ $counter -gt 1 ]; then
    echo "$dir/$name${ext:+.}$ext"
  else
    echo ""
  fi
}

echo -e "${BLUE}=== backup  ===${NC}"
echo "Origen: $LOCAL_DIR"
echo "Destino: $REMOTE_HOST:$REMOTE_DIR"
echo ""

# buscar imagenes
while IFS= read -r archivo; do
  relativo="${archivo#$HOME/}"
  size=$(stat -f%z "$archivo" 2>/dev/null || stat -c%s "$archivo" 2>/dev/null)
  size_human=$(human_size $size)

  # check si existe en remoto
  if ssh -n "$REMOTE_HOST" "[ -f \"$relativo\" ]" 2>/dev/null; then
    # get tamaño remoto
    remote_size=$(ssh -n "$REMOTE_HOST" "stat -c%s \"$relativo\" 2>/dev/null" 2>/dev/null)

    if [ "$size" = "$remote_size" ]; then
      echo -e "${GREEN}[EXISTE]${NC} $relativo ($size_human) - idéntico"
      ((total_existentes++))
    else
      # si mismo nombre =/  tamaño diferente = renombrar
      echo -e "${YELLOW}[DIFERENTE]${NC} $relativo ($size_human local / $(human_size $remote_size) remoto)"
      nuevo_nombre=$(get_unique_name "$relativo")

      if [ -n "$nuevo_nombre" ]; then
        echo -e "${YELLOW}[RENOMBRANDO]${NC} a: $nuevo_nombre"

        ssh -n "$REMOTE_HOST" "mkdir -p \"$(dirname "$nuevo_nombre")\"" 2>/dev/null

        if scp -q "$archivo" "$REMOTE_HOST:$nuevo_nombre"; then
          echo -e "${GREEN}[COPIADO]${NC} $nuevo_nombre ($size_human)"
          ((total_copiados++))
          total_bytes=$((total_bytes + size))
        else
          echo -e "${RED}[ERROR]${NC} Falló la copia de $archivo"
        fi
      fi
    fi
  else
    echo -e "${BLUE}[NUEVO]${NC} $relativo ($size_human)"

    ssh -n "$REMOTE_HOST" "mkdir -p \"$(dirname "$relativo")\"" 2>/dev/null

    # Copiar archivo
    if scp -q "$archivo" "$REMOTE_HOST:$relativo"; then
      echo -e "${GREEN}[COPIADO]${NC} $relativo ($size_human)"
      ((total_copiados++))
      total_bytes=$((total_bytes + size))
    else
      echo -e "${RED}[ERROR]${NC} Falló la copia de $archivo"
    fi
  fi
done < <(find "$LOCAL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" -o -iname "*.svg" -o -iname "*.tiff" \))

echo ""
echo -e "${BLUE}=== Resumen ===${NC}"
echo -e "Archivos nuevos copiados: $total_copiados"
echo -e "Archivos ya existentes: $total_existentes"
echo -e "Total transferido: $(human_size $total_bytes)"
