#!/usr/bin/env python3
"""Write seven short synthetic drum hits (48 kHz mono) to ./samples for the desktop
stress test. On a real norns stress.lua uses dust/audio/common/808 instead."""
import math, os, random, struct, wave

random.seed(1)
SR = 48000
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "samples")
os.makedirs(OUT, exist_ok=True)

def write(name, f):
    with wave.open(os.path.join(OUT, name), "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, f(i / SR))) * 20000)) for i in range(int(SR * 0.4))))

noise = lambda: random.uniform(-1, 1)
write("808-BD.wav", lambda t: math.sin(2 * math.pi * (50 + 100 * math.exp(-t * 30)) * t) * math.exp(-t * 8))
write("808-SD.wav", lambda t: (noise() * 0.7 + 0.3 * math.sin(2 * math.pi * 180 * t)) * math.exp(-t * 15))
write("808-CH.wav", lambda t: noise() * math.exp(-t * 60))
write("808-OH.wav", lambda t: noise() * math.exp(-t * 8))
write("808-CP.wav", lambda t: noise() * math.exp(-(t % 0.02) * 200) * math.exp(-t * 10))
write("808-LT.wav", lambda t: math.sin(2 * math.pi * 120 * t) * math.exp(-t * 10))
write("808-CY.wav", lambda t: noise() * math.exp(-t * 4))
print("wrote samples to", OUT)
