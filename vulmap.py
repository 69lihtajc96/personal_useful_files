import os
import subprocess

def validate_ip(ip):
    # Простая проверка на формат IP-адреса
    octets = ip.split('.')
    if len(octets) == 4 and all(octet.isdigit() and 0 <= int(octet) <= 255 for octet in octets):
        return True
    return False

def run_nmap(ip, output_file="scan_results.txt"):
    # Проверка существования файла и запроса на перезапись
    if os.path.exists(output_file):
        overwrite = input(f"Файл {output_file} уже существует. Перезаписать? (y/n): ").strip().lower()
        if overwrite != 'y':
            print("Отмена операции.")
            return

    # Выполнение команды nmap
    try:
        command = ["nmap", "-sV", "-Pn", "--script=vulscan/vulscan.nse", ip]
        with open(output_file, "w") as file:
            subprocess.run(command, stdout=file, stderr=subprocess.STDOUT)
        print(f"Сканирование завершено. Результаты записаны в {output_file}")
    except FileNotFoundError:
        print("Ошибка: nmap не установлен или недоступен. Установите nmap и повторите попытку.")
    except Exception as e:
        print(f"Произошла ошибка: {e}")

if __name__ == "__main__":
    # Запрос IP-адреса у пользователя
    ip_address = input("Введите IP для сканирования: ").strip()
    if validate_ip(ip_address):
        run_nmap(ip_address)
    else:
        print("Ошибка: Введён неверный IP-адрес.")
