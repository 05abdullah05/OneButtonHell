"""Generates all sound effects and music for One Button Hell.
Run: python make_sounds.py   -> writes .wav files into ./audio/
Everything is synthesized from basic waveforms (square, triangle, noise),
so there are no licensing issues.
"""
import os
import wave
import numpy as np

RATE = 22050
OUT = "audio"
rng = np.random.default_rng(7)


def save(name, signal, peak=0.8):
    signal = np.asarray(signal, dtype=np.float64)
    m = np.max(np.abs(signal))
    if m > 0:
        signal = signal / m * peak
    data = (signal * 32767).astype(np.int16)
    os.makedirs(OUT, exist_ok=True)
    with wave.open(os.path.join(OUT, name), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(data.tobytes())


def t_axis(seconds):
    return np.arange(int(seconds * RATE)) / RATE


def phase_from_freq(freq):
    # Integrate frequency over time so pitch slides are smooth.
    return 2 * np.pi * np.cumsum(freq) / RATE


def square(phase, duty=0.5):
    return np.where((phase / (2 * np.pi)) % 1.0 < duty, 1.0, -1.0)


def triangle(phase):
    x = (phase / (2 * np.pi)) % 1.0
    return 4 * np.abs(x - 0.5) - 1


def envelope(n, attack=0.005, release=0.05):
    env = np.ones(n)
    a = max(1, int(attack * RATE))
    r = max(1, int(release * RATE))
    env[:a] = np.linspace(0, 1, a)
    env[-r:] *= np.linspace(1, 0, r)
    return env


# --- Jump: quick rising square chirp -------------------------------------
t = t_axis(0.16)
freq = np.linspace(280, 720, len(t))
jump = square(phase_from_freq(freq), 0.25) * np.exp(-t * 14)
save("jump.wav", jump * envelope(len(t)), 0.6)

# --- Spike death: noise crunch + falling "pheww" -------------------------
t = t_axis(0.55)
crunch = rng.uniform(-1, 1, len(t)) * np.exp(-t * 35)
freq = 700 * np.exp(-t * 4.5) + 90
pheww = square(phase_from_freq(freq), 0.5) * np.exp(-t * 4)
save("death.wav", (crunch * 0.9 + pheww * 0.6) * envelope(len(t)), 0.75)

# --- Fall into pit: slide whistle down, fading into silence --------------
t = t_axis(1.1)
freq = 1100 * np.exp(-t * 1.9) + 60
freq = freq * (1 + 0.02 * np.sin(2 * np.pi * 7 * t))     # slight wobble
fade = np.clip(1 - t / 1.1, 0, 1) ** 1.5                 # gets quieter as you fall
fall = (np.sin(phase_from_freq(freq)) * 0.7 + triangle(phase_from_freq(freq)) * 0.3) * fade
save("fall.wav", fall * envelope(len(t), 0.01, 0.1), 0.7)

# --- Coin: two quick notes (B5 -> E6) ------------------------------------
parts = []
for f, d in [(988, 0.06), (1319, 0.22)]:
    t = t_axis(d)
    parts.append(square(2 * np.pi * f * t, 0.25) * np.exp(-t * 9) * envelope(len(t), 0.002, 0.02))
save("coin.wav", np.concatenate(parts), 0.55)

# --- Goal: rising fanfare C5 E5 G5 C6 ------------------------------------
parts = []
for f, d in [(523, 0.1), (659, 0.1), (784, 0.1), (1047, 0.45)]:
    t = t_axis(d)
    tone = square(2 * np.pi * f * t, 0.5) * 0.6 + triangle(2 * np.pi * f / 2 * t) * 0.4
    parts.append(tone * np.exp(-t * 3) * envelope(len(t), 0.003, 0.03))
save("goal.wav", np.concatenate(parts), 0.65)

# --- Music: 16-bar chiptune loop (Am - F - C - G), 150 BPM ---------------
BPM = 150
beat = 60 / BPM
step = beat / 2                      # eighth notes
NOTE = {"A3": 220.0, "C4": 261.63, "D4": 293.66, "E4": 329.63, "F4": 349.23,
        "G4": 392.0, "A4": 440.0, "B4": 493.88, "C5": 523.25, "D5": 587.33,
        "E5": 659.25, "F3": 174.61, "G3": 196.0, "C3": 130.81, "E3": 164.81,
        "A2": 110.0, "F2": 87.31, "C2": 65.41, "G2": 98.0, "-": 0.0}

chords = [  # (bass root, arpeggio notes)
    ("A2", ["A3", "C4", "E4", "A4"]),
    ("F2", ["F3", "A3", "C4", "F4"]),
    ("C2", ["C3", "E3", "G3", "C4"]),
    ("G2", ["G3", "B4", "D4", "G4"]),
]
# Melody: 8 eighth-notes per bar, two variations alternating.
melody_a = [
    ["E5", "-", "C5", "D5", "E5", "-", "A4", "-"],
    ["C5", "-", "A4", "C5", "F4", "-", "A4", "-"],
    ["G4", "-", "C5", "E5", "D5", "C5", "G4", "-"],
    ["B4", "-", "D5", "-", "G4", "A4", "B4", "-"],
]
melody_b = [
    ["A4", "C5", "E5", "-", "D5", "C5", "B4", "A4"],
    ["C5", "-", "F4", "A4", "C5", "-", "D5", "C5"],
    ["E5", "-", "D5", "C5", "G4", "-", "C5", "-"],
    ["D5", "C5", "B4", "-", "G4", "-", "-", "-"],
]
form = [melody_a, melody_b, melody_a, melody_b]   # 16 bars

bar_len = int(8 * step * RATE)
total = np.zeros(bar_len * 16)


def note(freq, seconds, kind, decay):
    t = t_axis(seconds)
    if freq == 0:
        return np.zeros(len(t))
    ph = 2 * np.pi * freq * t
    w = square(ph, 0.25) if kind == "lead" else (triangle(ph) if kind == "bass" else square(ph, 0.5))
    return w * np.exp(-t * decay) * envelope(len(t), 0.003, 0.02)


bar_index = 0
for section in form:
    for b in range(4):
        start = bar_index * bar_len
        root, arp = chords[b]
        for i in range(8):
            s = start + int(i * step * RATE)
            # bass on every quarter note
            if i % 2 == 0:
                n = note(NOTE[root], beat * 0.9, "bass", 2.0)
                total[s:s + len(n)] += n * 0.55
            # soft arpeggio
            n = note(NOTE[arp[i % 4]], step * 0.9, "arp", 8.0)
            total[s:s + len(n)] += n * 0.12
            # lead melody
            n = note(NOTE[section[b][i]], step * 1.6, "lead", 5.0)
            end = min(len(total), s + len(n))
            total[s:end] += n[:end - s] * 0.35
            # hi-hat noise on off-beats
            if i % 2 == 1:
                h = rng.uniform(-1, 1, int(0.03 * RATE)) * np.exp(-t_axis(0.03) * 120)
                total[s:s + len(h)] += h * 0.08
        bar_index += 1

save("music.wav", total, 0.7)
print("Done:", sorted(os.listdir(OUT)))
