#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
下载Kenney免费素材包（尝试不同URL）
"""

import requests
import os
from pathlib import Path

# 代理配置
PROXY = "http://127.0.0.1:10808"

# 尝试不同的URL格式
ASSETS = {
    "topdown_shooter": [
        "https://kenney.nl/assets/top-down-shooter/download",
        "https://cdn.kenney.nl/assets/top-down-shooter.zip",
        "https://kenney.nl/assets/top-down-shooter",
    ],
    "roguelike": [
        "https://kenney.nl/assets/roguelike-dungeon-crawler/download",
        "https://cdn.kenney.nl/assets/roguelike-dungeon-crawler.zip",
    ],
}

def download_asset(name, urls, output_dir):
    """下载单个素材包"""
    for url in urls:
        print(f"\n尝试: {name}")
        print(f"URL: {url}")
        
        try:
            proxies = {
                "http": PROXY,
                "https": PROXY,
            }
            
            response = requests.get(url, timeout=30, proxies=proxies, allow_redirects=True, verify=False)
            
            print(f"状态码: {response.status_code}")
            print(f"内容类型: {response.headers.get('Content-Type', 'unknown')}")
            print(f"内容长度: {len(response.content)} bytes")
            
            if response.status_code == 200 and len(response.content) > 1000:
                # 保存文件
                output_path = output_dir / f"{name}.zip"
                with open(output_path, 'wb') as f:
                    f.write(response.content)
                print(f"✅ 下载成功: {output_path}")
                return True
            
        except Exception as e:
            print(f"❌ 错误: {e}")
    
    return False

def main():
    """主函数"""
    output_dir = Path(__file__).parent / "assets" / "downloads"
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("=" * 60)
    print("🎮 Kenney素材包下载（尝试不同URL）")
    print("=" * 60)
    
    for name, urls in ASSETS.items():
        download_asset(name, urls, output_dir)
    
    print("\n" + "=" * 60)
    print(f"📁 保存位置: {output_dir.absolute()}")
    print("=" * 60)

if __name__ == "__main__":
    main()
