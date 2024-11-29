#!/bin/bash

# Функция для логирования действий
log_action() {
    local message="$1"
    logger -t process_manager "$message"
}

# Функция завершения процессов
terminate_process() {
    local pid=$1
    kill "$pid" 2>/dev/null
    if ps -p "$pid" > /dev/null; then
        echo -e "\033[31mОшибка:\033[0m Не удалось завершить процесс $pid."
        read -p "Попробовать с sudo? (y/n): " use_sudo
        if [[ "$use_sudo" == "y" ]]; then
            sudo kill "$pid"
            if ps -p "$pid" > /dev/null; then
                echo -e "\033[31mПроцесс всё ещё работает.\033[0m"
                log_action "Не удалось завершить процесс $pid даже с sudo."
            else
                echo -e "\033[32mПроцесс $pid завершён с sudo.\033[0m"
                log_action "Процесс $pid завершён с использованием sudo."
            fi
        fi
    else
        echo -e "\033[32mПроцесс $pid успешно завершён.\033[0m"
        log_action "Процесс $pid успешно завершён."
    fi
}

# Функция для вывода процессов
list_processes() {
    ps -eo pid,user,%cpu,%mem,etime,cmd --sort=-%cpu | awk '{printf "%-8s %-10s %-5s %-5s %-8s %s\n", $1, $2, $3, $4, $5, $6}'
}

# Главная функция
main() {
    local process_list selected_line pid

    # Вывод всех процессов с фильтром через fzf
    process_list=$(list_processes)
    selected_line=$(echo "$process_list" | fzf --header="Выберите процесс или начните поиск" --ansi)

    if [ -z "$selected_line" ]; then
        echo "Выбор отменён."
        exit 0
    fi

    # Извлечение PID из выбранной строки
    pid=$(echo "$selected_line" | awk '{print $1}')
    if [[ -z "$pid" ]]; then
        echo "Ошибка: не удалось определить PID."
        exit 1
    fi

    # Завершение процесса
    terminate_process "$pid"
}

# Запуск основной функции
main
