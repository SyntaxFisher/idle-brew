import time
from datetime import datetime, timedelta
import pyautogui
import sys
import math

if len(sys.argv) > 1:
    duration = int(sys.argv[1])
    total_seconds = duration * 60
    unlimited = False
else:
    unlimited = True

if not unlimited:
    start_time = datetime.now()
    end_time = start_time + timedelta(minutes=duration)
    print(f"Running for {duration} minutes, end time: {end_time.strftime('%H:%M')}")

try:
    if unlimited:
        i = 50
        while True:
            i += 1
            min = math.floor(i / 60)
            sec = i % 60
            print(f"\r{min} minutes, {sec} seconds", end="")
            time.sleep(1)
            pyautogui.press("space")
            pyautogui.press("backspace")
    else:
        for i in range(1, total_seconds + 1):
            print(f"\r{i}/{total_seconds} seconds", end="")
            time.sleep(1)
            pyautogui.press("space")
            pyautogui.press("backspace")
        print()
except KeyboardInterrupt:
    print("\nSTOPPED BY USER")

if not unlimited:
    current_time = datetime.now().strftime("%H:%M")
    print(f"Script finished at {current_time}")
print("Exiting...")
