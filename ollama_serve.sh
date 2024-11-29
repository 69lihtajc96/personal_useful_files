#!/bin/bash

PORT=11434
WAIT_TIME=3

echo "Останавливаю сервис ollama..."
sudo systemctl stop ollama

echo "Ожидаю остановки сервиса..."
sleep $WAIT_TIME

PROCESS=$(sudo lsof -i :$PORT)

if [ -n "$PROCESS" ]; then
  echo "Порт $PORT всё ещё занят следующей программой:"
  echo "$PROCESS"
  echo "Не удалось освободить порт $PORT. Завершение."
  exit 1
else
  echo "Порт $PORT свободен."
fi

export OLLAMA_LAYERS_TO_GPU=10         
export OLLAMA_CPU_BUFFER_SIZE=32GB      
export OLLAMA_GPU_BUFFER_SIZE=4GB       
export OLLAMA_N_BATCH=64               
export OLLAMA_FLASH_ATTENTION=true       

ollama serve
