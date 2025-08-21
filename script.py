import time
from datetime import datetime, timedelta
import pyautogui

duration = int(input("Duration in minutes: "))
total_seconds = duration * 60

start_time = datetime.now()
end_time = start_time + timedelta(minutes=duration)
print(f"Running for {duration} minutes, end time: {end_time.strftime('%H:%M')}")

for i in range(1, total_seconds + 1):
    print(f"\rProgress: {i}/{total_seconds} seconds", end="")
    time.sleep(1)
    pyautogui.press("space")
    pyautogui.press("backspace")

current_time = datetime.now().strftime("%H:%M")
print(f"\nScript finished at {current_time}")
print("Exiting...")
