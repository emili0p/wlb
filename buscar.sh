#!/bin/bash

# Archivo de salida en HDFS
HFDS_OUTPUT="/user/emilio/output/part-00000"

# Pedir la palabra al usuario
read -p "Ingresa la palabra a buscar: " PALABRA

# Buscar y obtener el conteo directamente desde HDFS
CONTEO=$(hdfs dfs -cat "$HFDS_OUTPUT" | grep -P "^${PALABRA}\t" | awk -F'\t' '{print $2}')

# Mostrar resultado
if [ -z "$CONTEO" ]; then
  echo "La palabra '$PALABRA' no se encontró."
else
  echo "La palabra '$PALABRA' aparece $CONTEO veces."
fi
