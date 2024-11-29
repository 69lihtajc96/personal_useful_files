#!/bin/bash

# Проверка, запущен ли скрипт с привилегиями root
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите этот скрипт с правами администратора (sudo)"
  exit
fi

echo "Сбор информации о системе..."

# Функция для красивого вывода секций
section() {
  echo -e "\n=== $1 ===\n"
}

# Получение информации о процессоре
section "Процессор"
lscpu | grep -E 'Model name|Architecture|CPU\(s\)|Thread|Core'

# Получение информации об оперативной памяти
section "Оперативная память"
free -h | grep -E 'Mem|Swap'

# Информация о дисковой системе
section "Дисковая система"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

# Информация о сетевых интерфейсах
section "Сетевые интерфейсы"
sudo lshw -C network | grep -A 15 -i "network"

# Информация о драйверах сетевых интерфейсов
section "Драйверы сетевых интерфейсов"
lsmod | grep -E '8814au|cfg80211|rtw89'

# Информация об установленных драйверах видеокарты
section "Видеокарта"
lspci | grep -E 'VGA|3D|Display'
lsmod | grep -E 'nvidia|amdgpu|radeon|i915'

# Информация о версии ядра и операционной системы
section "Система"
echo "ОС:" $(lsb_release -d | cut -f2)
echo "Версия ядра:" $(uname -r)
echo "Архитектура системы:" $(uname -m)

# Вывод текущих подключений и их IP-адресов
section "Подключенные сетевые интерфейсы"
ip -brief addr show | grep -E 'UP|LOWER_UP'

# Проверка на использование swap
section "Использование Swap"
swapon --show

# Информация о времени работы системы
section "Время работы системы"
uptime -p

# Информация о загрузке системы
section "Загрузка системы"
top -b -n1 | head -n 10

# Вывод завершения сбора данных
echo -e "\nСбор информации завершен. Данные собраны для анализа состояния системы."
