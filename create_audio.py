#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
生成游戏音效（使用简单的音频合成）
"""

import wave
import struct
import math
import random
from pathlib import Path

SAMPLE_RATE = 44100

def generate_sine_wave(frequency, duration, volume=0.3):
    """生成正弦波"""
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        envelope = 1.0 - (i / num_samples) * 0.5
        value = int(32767 * volume * envelope * 
                   math.sin(2 * math.pi * frequency * i / SAMPLE_RATE))
        samples.append(struct.pack('h', value))
    return b''.join(samples)

def generate_noise(duration, volume=0.3):
    """生成白噪声"""
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for _ in range(num_samples):
        value = int(32767 * volume * (random.random() * 2 - 1))
        samples.append(struct.pack('h', value))
    return b''.join(samples)

def generate_impact(frequency, duration, volume=0.5):
    """生成撞击音效（频率下降）"""
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        envelope = 1.0 - (i / num_samples)
        freq = frequency * (1 - i / num_samples * 0.5)
        value = int(32767 * volume * envelope * 
                   math.sin(2 * math.pi * freq * i / SAMPLE_RATE))
        samples.append(struct.pack('h', value))
    return b''.join(samples)

def generate_pew():
    """生成激光/射击音效"""
    samples = []
    for i in range(5000):
        freq = 800 + i * 2
        value = int(32767 * 0.4 * math.sin(2 * math.pi * freq * i / SAMPLE_RATE))
        samples.append(struct.pack('h', value))
    return b''.join(samples)

def generate_explosion():
    """生成爆炸音效（噪声+低频）"""
    noise = generate_noise(0.4, 0.6)
    bass = generate_impact(100, 0.4, 0.5)
    # 混合
    min_len = min(len(noise), len(bass))
    mixed = bytearray()
    for i in range(0, min_len, 2):
        n = struct.unpack('h', noise[i:i+2])[0]
        b = struct.unpack('h', bass[i:i+2])[0]
        mixed.extend(struct.pack('h', int((n + b) / 2)))
    return bytes(mixed)

def generate_hit():
    """生成受伤音效"""
    return generate_impact(300, 0.15, 0.4)

def generate_level_up():
    """生成升级音效（上升音阶）"""
    samples = b''
    notes = [523, 659, 784, 1047]
    for note in notes:
        samples += generate_sine_wave(note, 0.15, 0.4)
    return samples

def generate_victory():
    """生成胜利音效"""
    samples = b''
    notes = [523, 659, 784, 1047, 784, 1047]
    for note in notes:
        samples += generate_sine_wave(note, 0.2, 0.5)
    return samples

def generate_boss():
    """生成Boss出现音效（恐怖低频）"""
    samples = b''
    for i in range(20):
        samples += generate_impact(80 + i*5, 0.1, 0.4)
    return samples

def save_wav(filename, audio_data):
    """保存为WAV文件"""
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(audio_data)

def main():
    output_dir = Path("E:/godot/zombiesurvivor/assets/audio/sfx")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("🎵 生成游戏音效...")
    
    # 射击音效
    save_wav(str(output_dir / "shoot.wav"), generate_pew())
    print("✅ shoot.wav - 激光射击")
    
    # 爆炸音效
    save_wav(str(output_dir / "explosion.wav"), generate_explosion())
    print("✅ explosion.wav - 爆炸")
    
    # 受伤音效
    save_wav(str(output_dir / "hit.wav"), generate_hit())
    print("✅ hit.wav - 受伤")
    
    # 升级音效
    save_wav(str(output_dir / "upgrade.wav"), generate_level_up())
    print("✅ upgrade.wav - 升级")
    
    # 手雷投掷
    save_wav(str(output_dir / "grenade.wav"), generate_sine_wave(200, 0.15, 0.3))
    print("✅ grenade.wav - 手雷")
    
    # Boss出现
    save_wav(str(output_dir / "boss.wav"), generate_boss())
    print("✅ boss.wav - Boss出现")
    
    # 游戏结束
    save_wav(str(output_dir / "game_over.wav"), generate_impact(150, 0.5, 0.4))
    print("✅ game_over.wav - 游戏结束")
    
    # 胜利
    save_wav(str(output_dir / "victory.wav"), generate_victory())
    print("✅ victory.wav - 胜利")
    
    # 背景音乐
    bgm = b''
    melody = [440, 494, 523, 587, 659, 587, 523, 494,
              440, 392, 440, 494, 523, 494, 440, 392]
    for note in melody:
        bgm += generate_sine_wave(note, 0.3, 0.15)
    save_wav(str(output_dir / "bgm.wav"), bgm)
    print("✅ bgm.wav - 背景音乐")
    
    print(f"\n✅ 所有音效已保存到: {output_dir}")
    wav_files = list(output_dir.glob('*.wav'))
    print(f"共生成 {len(wav_files)} 个音效文件")

if __name__ == "__main__":
    main()
