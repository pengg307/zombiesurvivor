#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
下载Kenney免费素材包（正确的URL）
"""

import requests
import ssl
import os
from pathlib import Path

# 正确的素材包下载链接（Kenney CDN）
ASSETS = {
    "topdown_shooter": {
        "url": "https://cdn.kenney.nl/assets/top-down-shooter/1.3.1/top-down-shooter-1.3.1.zip",
        "name": "Top-Down Shooter"
    },
    "roguelike": {
        "url": "https://cdn.kenney.nl/assets/roguelike-dungeon-crawler/1.3.1/roguelike-dungeon-crawler-1.3.1.zip",
        "name": "Roguelike Dungeon Crawler"
    },
    "space_shooters": {
        "url": "https://cdn.kenney.nl/assets/space-shooters/1.2.1/space-shooters-1.2.1.zip",
        "name": "Space Shooters"
    },
}

def download_asset(name, url, output_dir):
    """下载单个素材包"""
    output_path = output_dir / f"{name}.zip"
    
    print(f"\n正在下载: {name}")
    print(f"URL: {url}")
    
    try:
        # 创建session，禁用SSL验证
        session = requests.Session()
        session.verify = False
        
        # 发送请求
        response = session.get(url, timeout=60, stream=True)
        
        if response.status_code == 200:
            # 保存文件
            with open(output_path, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            
            file_size = output_path.stat().st_size
            print(f"✅ 下载成功: {file_size / 1024:.1f} KB")
            return True
        else:
            print(f"❌ 下载失败: HTTP {response.status_code}")
            return False
        
    except Exception as e:
        print(f"❌ 下载失败: {e}")
        return False

def main():
    """主函数"""
    # 创建输出目录
    output_dir = Path(__file__).parent / "assets" / "downloads"
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("=" * 60)
    print("🎮 Kenney免费素材包下载器")
    print("=" * 60)
    
    # 下载所有素材
    success_count = 0
    for name, info in ASSETS.items():
        if download_asset(name, info["url"], output_dir):
            success_count += 1
    
    print("\n" + "=" * 60)
    print(f"✅ 成功下载: {success_count}/{len(ASSETS)} 个素材包")
    print(f"📁 保存位置: {output_dir.absolute()}")
    print("=" * 60)
    
    if success_count > 0:
        print("\n下一步：")
        print("1. 解压下载的zip文件")
        print("2. 将素材复制到 assets/sprites/ 目录")
        print("3. 告诉我素材路径，我帮你导入到Godot")

if __name__ == "__main__":
    main()
