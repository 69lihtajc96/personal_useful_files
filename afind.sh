#!/bin/bash

# Функция для логирования действий
log_action() {
    local message="$1"
    logger -t file_search "$message"
}

# Функция поиска файлов
search_files() {
    local path=$1
    local name=$2
    local type=$3
    local size=$4
    local mtime=$5

    find "$path" \
        ${name:+-name "$name"} \
        ${type:+-type "$type"} \
        ${size:+-size "$size"} \
        ${mtime:+-mtime "$mtime"} \
        2>/dev/null
}

# Функция для вывода и выбора файлов
select_file() {
    local file_list=$1
    local selected_file

    selected_file=$(echo "$file_list" | fzf --header="Выберите файл или начните поиск" --ansi)

    if [ -z "$selected_file" ]; then
        echo "Выбор отменён."
        exit 0
    fi

    echo "$selected_file"
}

# Главная функция
main() {
    local path name type size mtime file_list selected_file

    # Запрос параметров у пользователя
    read -p "Введите путь для поиска (по умолчанию /): " path
    path=${path:-/}

    read -p "Введите имя файла (с маской, например *.txt): " name
    read -p "Введите тип файла (f для файлов, d для директорий): " type
    read -p "Введите размер файла (например +1M или -500k): " size
    read -p "Введите возраст файла в днях (например -7 для менее 7 дней): " mtime

    # Поиск файлов
    file_list=$(search_files "$path" "$name" "$type" "$size" "$mtime")

    if [ -z "$file_list" ]; then
        echo "Файлы не найдены."
        exit 0
    fi

    # Выбор файла
    selected_file=$(select_file "$file_list")

    echo -e "\033[32mВы выбрали файл: $selected_file\033[0m"
    log_action "Файл $selected_file выбран пользователем."

    # Дополнительные действия с файлом
    read -p "Хотите открыть файл? (y/n): " open_file
    if [[ "$open_file" == "y" ]]; then
        xdg-open "$selected_file" 2>/dev/null || echo "Не удалось открыть файл."
        log_action "Файл $selected_file открыт."
    fi
}

# Запуск основной функции
main
