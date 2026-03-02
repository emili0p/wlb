#!/bin/env bash

# we got sudo running
sudo -v

# keep it running
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &
echo "Detectando el sistema operativo..."

if grep -iq "Ubuntu" /etc/os-release; then
  DISTRO="Ubuntu"
elif grep -iq "Fedora" /etc/os-release; then
  DISTRO="Fedora"
else
  echo "Sistema operativo no soportado"
  exit 1
fi

echo "Sistema detectado: $DISTRO"

# Instalación según el sistema
if [ "$DISTRO" == "Ubuntu" ]; then
  echo "Actualizando paquetes..."
  sudo apt update -y
  echo "Instalando OpenJDK y wget..."
  sudo apt install -y openjdk-11-jdk wget curl
elif [ "$DISTRO" == "Fedora" ]; then
  echo "Actualizando paquetes..."
  sudo dnf update -y
  echo "Instalando OpenJDK y wget..."
  sudo dnf install -y java-11-openjdk wget curl
fi

# Configurar variables de entorno Java
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "JAVA_HOME=$JAVA_HOME"

# Descargar Hadoop
HADOOP_VERSION="3.4.1"
HADOOP_TGZ="hadoop-$HADOOP_VERSION.tar.gz"
HADOOP_URL="https://downloads.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/$HADOOP_TGZ"

echo "Descargando Hadoop $HADOOP_VERSION..."
wget $HADOOP_URL -P /tmp

echo "Descomprimiendo Hadoop..."
sudo tar -xzf /tmp/$HADOOP_TGZ -C /opt/
sudo mv /opt/hadoop-$HADOOP_VERSION /opt/hadoop

# Configurar variables de entorno Hadoop
echo "Configurando variables de entorno Hadoop..."
echo "export HADOOP_HOME=/opt/hadoop" >>~/.bashrc
echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >>~/.bashrc
echo "export JAVA_HOME=$JAVA_HOME" >>~/.bashrc

echo "Instalación completada. Cierra y vuelve a abrir la terminal para aplicar los cambios."
