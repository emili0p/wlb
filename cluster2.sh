#!/bin/bash

#colores
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
ENDCOLOR='\e[0m'

MASTER="master"
WORKER1="vmzurdo"
WORKER2="alpine"

function trabajo_montecarlo() {

  NODE=$1

  if [ "$NODE" == "$MASTER" ]; then

    echo -e "${BLUE}Ejecutando Monte Carlo en nodo maestro...${ENDCOLOR}"
    echo -e "${GREEN}Nodo:${ENDCOLOR} $(hostname)"
    echo -e "${YELLOW}Iniciando Monte Carlo...${ENDCOLOR}"

    python3 ~/montecarlo.py

    echo -e "${GREEN}Trabajo terminado en${ENDCOLOR} $(hostname)"

  else

    echo -e "${BLUE}Enviando Monte Carlo a $NODE...${ENDCOLOR}"

    ssh $NODE '

cd ~

echo -e "\e[32mNodo:\e[0m $(hostname)"
echo -e "\e[33mIniciando Monte Carlo...\e[0m"

python3 ~/montecarlo.py

echo -e "\e[32mTrabajo terminado en\e[0m $(hostname)"

'

  fi
}

function estado() {

  echo ""
  echo -e "${BLUE}Estado nodos${ENDCOLOR}"
  echo -e "${BLUE}-------------${ENDCOLOR}"

  echo -e "${YELLOW}Nodo maestro:${ENDCOLOR}"
  echo "Master: $(hostname)"
  uptime

  echo ""

  echo -e "${YELLOW}Worker1:${ENDCOLOR}"
  ssh $WORKER1 "echo Nodo: \$(hostname); uptime"

  echo ""

  echo -e "${YELLOW}Worker2:${ENDCOLOR}"
  ssh $WORKER2 "echo Nodo: \$(hostname); uptime"

}

while true; do
  echo ""
  echo -e "${GREEN}===== CLUSTER MASTER =====${ENDCOLOR}"
  echo -e "${YELLOW}1) Monte Carlo Master${ENDCOLOR}"
  echo -e "${YELLOW}2) Monte Carlo Worker1 (vmzurdo)${ENDCOLOR}"
  echo -e "${YELLOW}3) Monte Carlo Worker2 (alpine)${ENDCOLOR}"
  echo -e "${YELLOW}4) Monte Carlo TODOS${ENDCOLOR}"
  echo -e "${BLUE}5) Ver estado nodos${ENDCOLOR}"
  echo -e "${RED}6) Salir${ENDCOLOR}"
  echo ""

  read -p "Opcion: " op

  case $op in

  1)
    trabajo_montecarlo $MASTER
    ;;

  2)
    trabajo_montecarlo $WORKER1
    ;;

  3)
    trabajo_montecarlo $WORKER2
    ;;

  4)
    trabajo_montecarlo $MASTER &
    trabajo_montecarlo $WORKER1 &
    trabajo_montecarlo $WORKER2 &
    wait
    ;;

  5)
    estado
    ;;

  6)
    echo -e "${RED}Saliendo...${ENDCOLOR}"
    exit
    ;;

  *)
    echo -e "${RED}Opcion invalida${ENDCOLOR}"
    ;;

  esac

done
