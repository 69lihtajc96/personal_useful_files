import cv2
import time
import asyncio
import signal
import os
from datetime import datetime
from aiogram import Bot, Dispatcher, types
from aiogram.fsm.storage.memory import MemoryStorage
from aiogram.types import FSInputFile
from aiogram import Router
from aiogram.filters import Command

# Telegram bot setup
TOKEN = ''
CHAT_ID = ''
PASSWORD = ''  # Пароль для авторизации



authorized_chats = set()
bot = Bot(token=TOKEN)
storage = MemoryStorage()
dp = Dispatcher(storage=storage)
router = Router()
start_time = time.time()

# Graceful shutdown function
async def shutdown():
    await bot.session.close()
    print("Бот успешно остановлен.")

# Function to handle shutdown signals
def shutdown_signal_handler(loop):
    print("Получен сигнал остановки, завершаем работу...")
    for task in asyncio.all_tasks(loop):
        task.cancel()
    loop.stop()

# Function to send photo
async def send_photo(photo_path, chat_id, reason):
    try:
        photo = FSInputFile(photo_path)
        reason_message = f"📸 *Фото отправлено по причине*: _{reason}_"
        await bot.send_photo(chat_id=chat_id, photo=photo)
        await bot.send_message(chat_id=chat_id, text=reason_message, parse_mode='Markdown')
    except Exception as e:
        print(f"Ошибка отправки фото: {e}")

# Function to capture image asynchronously
async def capture_image(prefix):
    try:
        cap = cv2.VideoCapture(0, cv2.CAP_V4L2)
        if not cap.isOpened():
            raise Exception("Не удалось открыть камеру.")
        
        ret, frame = cap.read()
        if ret:
            img_name = f"{prefix}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.png"
            cv2.imwrite(img_name, frame)
            cap.release()
            return img_name, frame
        cap.release()
        return None, None
    except Exception as e:
        print(f"Ошибка при захвате изображения: {e}")
        return None, None

# Function to check camera availability
def is_camera_available():
    cap = cv2.VideoCapture(0, cv2.CAP_V4L2)
    if cap.isOpened():
        cap.release()
        return True
    return False

# Command handlers
@router.message(Command(commands=["help"]))
async def help_command(message: types.Message):
    help_text = (
        "👋 *Добро пожаловать!*\n\n"
        "Чтобы начать использовать бота, вам нужно авторизоваться.\n"
        "Используйте команду `/auth <пароль>` для авторизации.\n\n"
        "Доступные команды после авторизации:\n"
        "/photo - Сделать фото вручную\n"
        "/uptime - Показать время работы программы\n"
    )
    await message.answer(help_text, parse_mode='Markdown')

@router.message(Command(commands=["photo"]))
async def photo_command(message: types.Message):
    if message.chat.id not in authorized_chats:
        await message.answer("❌ Доступ запрещён. Пройдите авторизацию.")
        return
    
    img_name, _ = await capture_image("manual_photo")
    if img_name:
        await send_photo(img_name, message.chat.id, "Запрос команды /photo")
    else:
        await message.answer("❌ Не удалось сделать снимок.")

@router.message(Command(commands=["uptime"]))
async def uptime_command(message: types.Message):
    if message.chat.id not in authorized_chats:
        await message.answer("❌ Доступ запрещён. Пройдите авторизацию.")
        return

    current_time = time.time()
    uptime_seconds = int(current_time - start_time)
    uptime_message = f"🕒 *Время работы программы*: {uptime_seconds} секунд."
    await message.answer(uptime_message, parse_mode='Markdown')

@router.message(Command(commands=["auth"]))
async def auth_command(message: types.Message):
    if len(message.text.split()) < 2:
        await message.answer("❌ Пожалуйста, укажите пароль: `/auth <пароль>`.")
        return

    entered_password = message.text.split()[1]
    if entered_password == PASSWORD:
        authorized_chats.add(message.chat.id)
        await message.answer("✅ Авторизация успешна! Теперь вы можете пользоваться ботом.")
    else:
        await message.answer("❌ Неверный пароль! Попробуйте снова.")

# Motion detection variables
prev_frame = None
motion_threshold = 50000  # Пороговое значение для обнаружения движения

# Periodic photo capture with motion detection
async def periodic_photo_capture():
    global prev_frame
    last_sent_time = time.time()

    if not is_camera_available():
        print("Камера недоступна. Прерывание выполнения.")
        return

    cap = cv2.VideoCapture(0, cv2.CAP_V4L2)
    if not cap.isOpened():
        print("Не удалось открыть камеру.")
        return

    while True:
        try:
            ret, frame = cap.read()
            if not ret:
                print("Не удалось получить кадр с камеры.")
                break

            gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            gray_frame = cv2.GaussianBlur(gray_frame, (21, 21), 0)

            if prev_frame is None:
                prev_frame = gray_frame
                continue

            frame_delta = cv2.absdiff(prev_frame, gray_frame)
            thresh = cv2.threshold(frame_delta, 25, 255, cv2.THRESH_BINARY)[1]
            motion_score = cv2.countNonZero(thresh)

            if motion_score > motion_threshold and time.time() - last_sent_time > 10:
                img_name = f"motion_{datetime.now().strftime('%Y%m%d_%H%M%S')}.png"
                cv2.imwrite(img_name, frame)
                await send_photo(img_name, CHAT_ID, "Обнаружено движение")
                last_sent_time = time.time()

            prev_frame = gray_frame
        except Exception as e:
            print(f"Ошибка в цикле обнаружения движения: {e}")
            break

        await asyncio.sleep(0.1)

    cap.release()

# Main function
async def main():
    dp.include_router(router)
    await asyncio.gather(dp.start_polling(bot), periodic_photo_capture())

if __name__ == '__main__':
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)

    for sig in (signal.SIGINT, signal.SIGTERM, signal.SIGTSTP):  # Добавляем SIGTSTP для Ctrl+Z
        loop.add_signal_handler(sig, lambda: asyncio.create_task(shutdown()))
    
    try:
        loop.run_until_complete(main())
    except (KeyboardInterrupt, SystemExit):
        print("Программа завершена.")
    finally:
        loop.run_until_complete(shutdown())
