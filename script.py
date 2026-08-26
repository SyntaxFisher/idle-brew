import time
from datetime import datetime, timedelta
import sys
import math

from AppKit import NSApplication, NSApplicationActivationPolicyProhibited

# Hide the Python rocket icon from the Dock while the script runs
NSApplication.sharedApplication().setActivationPolicy_(NSApplicationActivationPolicyProhibited)

import pyautogui

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

def wiggle_mouse():
    pyautogui.moveRel(1, 0, _pause=False)
    pyautogui.moveRel(-1, 0, _pause=False)

try:
    if unlimited:
        i = 0
        while True:
            i += 1
            min = math.floor(i / 60)
            sec = i % 60
            print(f"\r{min} minutes, {sec} seconds", end="")
            time.sleep(1)
            if i % 30 == 0:
                wiggle_mouse()
    else:
        for i in range(1, total_seconds + 1):
            print(f"\r{i}/{total_seconds} seconds", end="")
            time.sleep(1)
            if i % 30 == 0:
                wiggle_mouse()
        print()
except KeyboardInterrupt:
    print("\nSTOPPED BY USER")

if not unlimited:
    current_time = datetime.now().strftime("%H:%M")
    print(f"Script finished at {current_time}")
print("Exiting...")
