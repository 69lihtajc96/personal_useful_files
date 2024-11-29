#!/bin/bash

# Папка по умолчанию для сохранения таблиц
DEFAULT_OUTPUT_DIR="$HOME/Sync/Obsidian/1 Инструменты/1 CHAT GPT/3 Ответы от GPT/Интересные ответы/Таблицы качества печати/"

# Проверка аргументов
if [ "$#" -lt 1 ]; then
  echo "Использование: $0 {input_file.csv} [output_file.md]"
  exit 1
fi

# Переменные
input_file="$1"
output_file="${2:-$DEFAULT_OUTPUT_DIR/$(basename "$input_file" .csv).md}"

# Создаем папку по умолчанию, если она не существует
mkdir -p "$DEFAULT_OUTPUT_DIR"

# Проверяем, что входной файл существует
if [ ! -f "$input_file" ]; then
  echo "Ошибка: Файл '$input_file' не найден!"
  exit 1
fi

# Выбор порядка столбцов
echo "Выберите порядок столбцов для таблицы:"
echo "1) Дата | Время | Фаза Луны | WPM | Accuracy | Raw WPM | Consistency | Язык (Флаг)"
echo "2) WPM | Accuracy | Язык (Флаг) | Raw WPM | Дата | Время | Фаза Луны"
echo "3) Custom order (выберите вручную)"
read -p "Введите номер (1, 2 или 3): " column_choice

case $column_choice in
  1)
    columns="date,time,moon_phase,wpm,acc,rawWpm,consistency,language_flag"
    ;;
  2)
    columns="wpm,acc,language_flag,rawWpm,date,time,moon_phase"
    ;;
  3)
    read -p "Введите названия столбцов через запятую (например, date,time,moon_phase,wpm,acc): " columns
    ;;
  *)
    echo "Неправильный выбор. Используем вариант 1 по умолчанию."
    columns="date,time,moon_phase,wpm,acc,rawWpm,consistency,language_flag"
    ;;
esac

# Выбор столбца и направления сортировки
echo "Выберите столбец для сортировки:"
echo "1) WPM"
echo "2) Accuracy"
echo "3) Consistency"
echo "4) Raw WPM"
read -p "Введите номер столбца для сортировки (1-4): " sort_column

case $sort_column in
  1) sort_column_name="wpm";;
  2) sort_column_name="acc";;
  3) sort_column_name="consistency";;
  4) sort_column_name="rawWpm";;
  *)
    echo "Неправильный выбор. Используем WPM по умолчанию."
    sort_column_name="wpm"
    ;;
esac

read -p "Выберите направление сортировки ('asc' для возрастания или 'desc' для убывания): " sort_order
if [[ "$sort_order" != "asc" && "$sort_order" != "desc" ]]; then
  echo "Неправильный выбор. Используем убывание по умолчанию."
  sort_order="desc"
fi

# Python код для создания таблицы и улучшенного графика
python3 << END
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime
import base64
from io import BytesIO

# Загрузка данных
df = pd.read_csv("$input_file")

# Преобразование timestamp в формат даты и времени
df['timestamp'] = pd.to_datetime(df['timestamp'], unit='ms')
df['date'] = df['timestamp'].dt.strftime('%d-%m-%Y')
df['time'] = df['timestamp'].dt.strftime('%H:%M')

# Функция для добавления эмодзи по времени суток
def add_time_emoji(time_str):
    hour = int(time_str.split(":")[0])
    if 5 <= hour < 12:
        return f"{time_str} 🌞"
    elif 12 <= hour < 17:
        return f"{time_str} 🌤️"
    elif 17 <= hour < 21:
        return f"{time_str} 🌆"
    else:
        return f"{time_str} 🌙"

df['time'] = df['time'].apply(add_time_emoji)

# Функция для фазы Луны
def moon_phase(date):
    diff = (datetime.strptime(date, '%d-%m-%Y') - datetime(2000, 1, 6)).days
    lunations = diff / 29.53058867
    phase_index = lunations % 1
    if phase_index < 0.03 or phase_index > 0.97:
        return "🌑 Новолуние"
    elif 0.22 < phase_index < 0.28:
        return "🌓 Первая четверть"
    elif 0.47 < phase_index < 0.53:
        return "🌕 Полнолуние"
    elif 0.72 < phase_index < 0.78:
        return "🌗 Последняя четверть"
    else:
        return ""

df['moon_phase'] = df['date'].apply(moon_phase)

# Преобразование языка в флаг
def language_to_flag(language):
    return '🇷🇺' if language == 'russian' else '🇺🇸' if language == 'english' else ''

df['language_flag'] = df['language'].apply(language_to_flag)

# Сортировка по выбранному столбцу и направлению
df = df.sort_values(by="$sort_column_name", ascending=(True if "$sort_order" == "asc" else False))

# Порядок столбцов
columns = "$columns".split(',')

# Генерация улучшенного графика
plt.figure(figsize=(14, 8), dpi=150)  # Увеличен размер графика и четкость
sns.lineplot(data=df, x='timestamp', y='wpm', label='WPM', color='deepskyblue', linewidth=3, marker='o', markersize=6)
sns.lineplot(data=df, x='timestamp', y='acc', label='Accuracy', color='limegreen', linewidth=3, marker='s', markersize=6)
plt.fill_between(df['timestamp'], df['wpm'], color='deepskyblue', alpha=0.1)
plt.fill_between(df['timestamp'], df['acc'], color='limegreen', alpha=0.1)

# Настройки осей и фона
plt.xlabel('Дата', fontsize=14)
plt.ylabel('Значения', fontsize=14)
plt.title('Скорость печати (WPM) и точность (Accuracy)', fontsize=18, pad=20)
plt.grid(color='gray', linestyle='--', linewidth=0.5, alpha=0.5)
plt.xticks(rotation=45)
plt.gca().spines['top'].set_visible(False)
plt.gca().spines['right'].set_visible(False)

# Сохранение графика в base64
buffer = BytesIO()
plt.savefig(buffer, format='png', transparent=True)
buffer.seek(0)
img_base64 = base64.b64encode(buffer.read()).decode('utf-8')
buffer.close()

# Создание Markdown таблицы с графиком
with open("$output_file", 'w') as f:
    f.write('# Скорость печати\n\n')
    f.write(f'![График скорости и точности](data:image/png;base64,{img_base64})\n\n')  # Вставка графика
    f.write('| ' + ' | '.join(columns) + ' |\n')
    f.write('| ' + ' | '.join(['---'] * len(columns)) + ' |\n')
    for _, row in df[columns].iterrows():
        row_data = [str(row[col]) for col in columns]
        f.write('| ' + ' | '.join(row_data) + ' |\n')

print(f"Таблица сохранена в: $output_file")
END
