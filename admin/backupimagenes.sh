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

echo "Origen: $LOCAL_DIR"
echo "Destino: $REMOTE_HOST:$REMOTE_DIR"
echo ""

echo "Obteniendo información de archivos remotos..."
remote_files=$(ssh "$REMOTE_HOST" "find '$REMOTE_DIR' -type f -exec stat -c '%n|%s' {} \;" 2>/dev/null)

# Procesar archivos locales
while IFS= read -r archivo; do
  relativo="${archivo#$HOME/}"
  size=$(stat -f%z "$archivo" 2>/dev/null || stat -c%s "$archivo" 2>/dev/null)
  size_human=$(human_size $size)

  # Buscar archivo en la lista remota
  remote_entry=$(echo "$remote_files" | grep "^$relativo|")

  if [ -n "$remote_entry" ]; then
    remote_size=$(echo "$remote_entry" | cut -d'|' -f2)

    if [ "$size" = "$remote_size" ]; then
      echo -e "${GREEN}[EXISTE]${NC} $relativo ($size_human) - idéntico"
      ((total_existentes++))
    else
      echo -e "${YELLOW}[DIFERENTE]${NC} $relativo ($size_human local / $(human_size $remote_size) remoto)"

      dir=$(dirname "$relativo")
      base=$(basename "$relativo")
      name="${base%.*}"
      ext="${base##*.}"

      if [ "$name" = "$base" ]; then
        ext=""
      fi

      counter=1
      nuevo_relativo="$dir/$name${ext:+.}$ext"

      while echo "$remote_files" | grep -q "^$nuevo_relativo|"; do
        nuevo_relativo="$dir/$name-$counter${ext:+.}$ext"
        ((counter++))
      done

      echo -e "${YELLOW}[RENOMBRANDO]${NC} a: $nuevo_relativo"

      ssh "$REMOTE_HOST" "mkdir -p '$(dirname "$nuevo_relativo")'" 2>/dev/null

      if scp -q "$archivo" "$REMOTE_HOST:$nuevo_relativo"; then
        echo -e "${GREEN}[COPIADO]${NC} $nuevo_relativo ($size_human)"
        ((total_copiados++))
        ((total_renombrados++))
        total_bytes=$((total_bytes + size))
        remote_files="$remote_files"$'\n'"$nuevo_relativo|$size"
      else
        echo -e "${RED}[ERROR]${NC} Falló la copia de $archivo"
      fi
    fi
  else
    echo -e "${BLUE}[NUEVO]${NC} $relativo ($size_human)"

    ssh "$REMOTE_HOST" "mkdir -p '$(dirname "$relativo")'" 2>/dev/null

    # copy za file
    if scp -q "$archivo" "$REMOTE_HOST:$relativo"; then
      echo -e "${GREEN}[COPIADO]${NC} $relativo ($size_human)"
      ((total_copiados++))
      total_bytes=$((total_bytes + size))
      remote_files="$remote_files"$'\n'"$relativo|$size"
    else
      echo -e "${RED}[ERROR]${NC} Falló la copia de $archivo"
    fi
  fi
done < <(find "$LOCAL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" -o -iname "*.svg" -o -iname "*.tiff" \))

echo ""
echo -e "Archivos nuevos copiados: $total_copiados"
echo -e "Archivos ya existentes: $total_existentes"
echo -e "Total transferido: $(human_size $total_bytes)"
