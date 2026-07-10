#!/bin/bash

THRESHOLD=500
INTERVAL=5

echo

while true; do

  clear
  echo "$(date)"
  echo

  printf "%-10s %-15s %-10s %-10s %-10s\n" \
    "PID" "PROCESO" "RAM(MB)" "OOM_SCORE" "ADJ"

  for pid in /proc/[0-9]*; do

    pid=${pid##*/}

    if [ -r /proc/$pid/status ] && [ -r /proc/$pid/oom_score ]; then

      name=$(cat /proc/$pid/comm 2>/dev/null)
      score=$(cat /proc/$pid/oom_score 2>/dev/null)
      adj=$(cat /proc/$pid/oom_score_adj 2>/dev/null)

      rss=$(awk '/VmRSS/ {print $2}' /proc/$pid/status 2>/dev/null)

      if [ -z "$rss" ]; then
        rss=0
      fi

      ram=$((rss / 1024))

      if [ "$score" -ge "$THRESHOLD" ]; then
        printf "%-10s %-15s %-10s %-10s %-10s\n" \
          "$pid" "$name" "$ram" "$score" "$adj"
      fi
    fi
  done

  sleep $INTERVAL

done
