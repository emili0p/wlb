#!/bin/bash

read -rp "Introduzca el nombre de su carpeta: " NOMBRECARPETA
read -rp "Introduzca el nombre de su archivo: " NOMBREARCHIVO
echo "" # espacio en blanco

mkdir $NOMBRECARPETA                                                       # creamos la carpeta
touch $NOMBREARCHIVO                                                       # creamos el archivo
echo "Se ha creado la carpeta $NOMBRECARPETA, y su archivo $NOMBREARCHIVO" #MENSAJE FINAL
