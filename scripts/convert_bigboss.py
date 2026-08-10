from PIL import Image
import os

# 读取 bigboss.jpg
img = Image.open('assets/downloads/bigboss.jpg')
print(f"原始尺寸: {img.size}, 模式: {img.mode}")

# 转换为 RGBA PNG（Godot 不支持动态加载 JPG）
img_rgba = img.convert('RGBA')
output_path = 'assets/downloads/bigboss.png'
img_rgba.save(output_path)
print(f"保存为: {output_path}")
print(f"新尺寸: {img_rgba.size}, 模式: {img_rgba.mode}")
