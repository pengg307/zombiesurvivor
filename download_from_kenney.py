#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
从Kenney页面提取下载链接并下载素材包
"""

import requests
import re
import zipfile
from pathlib import Path

# 代理配置
PROXY = "http://127.0.0.1:10808"

def get_download_link(asset_name):
    """从Kenney页面提取下载链接"""
    base_url = f"https://kenney.nl/assets/{asset_name}"
    
    print(f"\n正在获取: {asset_name}")
    print(f"URL: {base_url}")
    
    try:
        proxies = {
            "http": PROXY,
            "https": PROXY,
        }
        
        # 获取页面
        response = requests.get(base_url, timeout=30, proxies=proxies, allow_redirects=True, verify=False)
        
        if response.status_code != 200:
            print(f"❌ 页面获取失败: HTTP {response.status_code}")
            return None
        
        # 提取下载链接
        # 尝试多种模式
        patterns = [
            r'href="([^"]*download[^"]*\.zip)"',
            r'href="([^"]*\.zip)"',
            r'data-download="([^"]*)"',
            r'action="([^"]*)"',
        ]
        
        for pattern in patterns:
            matches = re.findall(pattern, response.text)
            if matches:
                print(f"找到链接: {matches[0]}")
                return matches[0]
        
        # 如果没有找到，尝试其他方法
        print("❌ 未找到下载链接")
        return None
        
    except Exception as e:
        print(f"❌ 错误: {e}")
        return None

def download_file(url, output_path):
    """下载文件"""
    try:
        proxies = {
            "http": PROXY,
            "https": PROXY,
        }
        
        response = requests.get(url, timeout=60, proxies=proxies, allow_redirects=True, verify=False)
        
        if response.status_code == 200 and len(response.content) > 1000:
            with open(output_path, 'wb') as f:
                f.write(response.content)
            print(f"✅ 下载成功: {output_path} ({len(response.content) / 1024:.1f} KB)")
            return True
        else:
            print(f"❌ 下载失败: HTTP {response.status_code}, 大小: {len(response.content)} bytes")
            return False
        
    except Exception as e:
        print(f"❌ 下载错误: {e}")
        return False

def main():
    """主函数"""
    output_dir = Path(__file__).parent / "assets" / "downloads"
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("=" * 60)
    print("🎮 Kenney素材包下载器（从页面提取链接）")
    print("=" * 60)
    
    # 素材包列表
    assets = [
        "top-down-shooter",
        "roguelike-dungeon-crawler",
        "space-shooters",
    ]
    
    downloaded = []
    
    for asset in assets:
        # 获取下载链接
        download_url = get_download_link(asset)
        
        if download_url:
            # 下载文件
            output_path = output_dir / f"{asset}.zip"
            if download_file(download_url, output_path):
                downloaded.append(asset)
    
    print("\n" + "=" * 60)
    print(f"✅ 成功下载: {len(downloaded)}/{len(assets)} 个素材包")
    print(f"📁 保存位置: {output_dir.absolute()}")
    print("=" * 60)
    
    if downloaded:
        print("\n下一步：")
        print("1. 解压下载的zip文件")
        print("2. 将素材复制到 assets/sprites/ 目录")
        print("3. 告诉我素材路径，我帮你导入到Godot")

if __name__ == "__main__":
    main()
