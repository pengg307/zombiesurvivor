#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
下载Kenney免费音效素材
"""

import requests
import ssl
import os
from pathlib import Path

# 代理配置
PROXY = "http://127.0.0.1:10808"

# Kenney音效包下载链接
SOUNDS = {
    "sound-effects": "https://cdn.kenney.nl/assets/sound-effects.kenney.zip",
    "free-music-pack": "https://cdn.kenney.nl/assets/free-music-pack.kenney.zip"
}

def download_with_proxy(url, output_path):
    """使用代理下载文件"""
    try:
        # 禁用SSL验证
        ssl_context = ssl.create_default_context()
        ssl_context.check_hostname = False
        ssl_context.verify_mode = ssl.CERT_NONE
        
        response = requests.get(
            url, 
            proxies={"http": PROXY, "https": PROXY},
            verify=False,
            timeout=60
        )
        
        if response.status_code == 200:
            with open(output_path, 'wb') as f:
                f.write(response.content)
            print(f"✅ 下载成功: {output_path} ({len(response.content)} bytes)")
            return True
        else:
            print(f"❌ 下载失败: {url} (状态码: {response.status_code})")
            return False
    except Exception as e:
        print(f"❌ 下载异常: {e}")
        return False

def main():
    # 创建素材目录
    assets_dir = Path("E:/godot/zombiesurvivor/assets/audio")
    assets_dir.mkdir(parents=True, exist_ok=True)
    
    print("🎵 开始下载音效素材...")
    
    # 下载音效包
    sound_zip = assets_dir / "sound-effects.zip"
    if download_with_proxy(SOUNDS["sound-effects"], str(sound_zip)):
        print("✅ 音效包下载成功")
    
    # 下载音乐包
    music_zip = assets_dir / "free-music-pack.zip"
    if download_with_proxy(SOUNDS["free-music-pack"], str(music_zip)):
        print("✅ 音乐包下载成功")
    
    print("\n📁 素材目录:", assets_dir)
    print("完成！")

if __name__ == "__main__":
    main()
