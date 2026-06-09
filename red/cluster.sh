#!/bin/bash

WORKER1="nodo1"
WORKER2="nodo2"

USER_WORKER1="zurdoman"
PORT_WORKER1=2222

function trabajo_pesado() {

  NODE=$1

  if [ "$NODE" == "$WORKER1" ]; then
    SSH_CMD="ssh -p $PORT_WORKER1 $USER_WORKER1@$WORKER1"
  else
    SSH_CMD="ssh $WORKER2"
  fi

  echo "Enviando trabajo pesado a $NODE..."

  $SSH_CMD '
echo "Nodo:" $(hostname)
echo "Iniciando carga CPU..."

PIDS=()

for i in {1..4}
do
    (while true; do
        echo $RANDOM | sha256sum > /dev/null
    done) &
    PIDS+=($!)
done

sleep 15

echo "Terminando procesos..."

for p in "${PIDS[@]}"
do
    kill $p 2>/dev/null
done

wait

echo "Trabajo terminado en" $(hostname)
'
}

function estado() {

  echo ""
  echo "Estado nodos"
  echo "-------------"

  ssh -p $PORT_WORKER1 $USER_WORKER1@$WORKER1 "echo Worker1: \$(hostname); uptime"
  echo ""
  ssh $WORKER2 "echo Worker2: \$(hostname); uptime"

}

while true; do
  echo ""
  echo "===== CLUSTER MASTER ====="
  echo "1) Trabajo pesado Worker1"
  echo "2) Trabajo pesado Worker2"
  echo "3) Trabajo pesado ambos"
  echo "4) Ver estado nodos"
  echo "5) Salir"
  echo ""

  read -p "Opcion: " op

  case $op in

  1)
    trabajo_pesado $WORKER1
    ;;

  2)
    trabajo_pesado $WORKER2
    ;;

  3)
    trabajo_pesado $WORKER1 &
    trabajo_pesado $WORKER2 &
    wait
    ;;

  4)
    estado
    ;;

  5)
    exit
    ;;

  *)
    echo "Opcion invalida"
    ;;

  esac

done
