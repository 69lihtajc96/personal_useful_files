#!/bin/bash

# MAC-адреса устройств
DEVICE1="6F:39:31:CB:8D:09"
DEVICE2="40:58:99:47:45:4B"

# Включаем Bluetooth
bluetoothctl power on

# Проверяем статус подключения
if bluetoothctl info $DEVICE1 | grep -q "Connected: yes"; then
    echo "Устройство 1 уже подключено."
elif bluetoothctl info $DEVICE2 | grep -q "Connected: yes"; then
    echo "Устройство 2 уже подключено."
else
    # Если ни одно устройство не подключено, пытаемся подключить
    if bluetoothctl connect $DEVICE1; then
        echo "Подключено к устройству 1."
    elif bluetoothctl connect $DEVICE2; then
        echo "Подключено к устройству 2."
    else
        echo "Не удалось подключиться ни к одному устройству."
    fi
fi
