#!/usr/bin/env python3
"""
僵尸素材背景透明化处理脚本
将黑色背景转换为透明背景
"""

from PIL import Image
import os

# 输入文件
input_file = r"E:\godot\zombiesurvivor\assets\downloads\zombie_front_4frames_game.png"
# 输出文件
output_file = r"E:\godot\zombiesurvivor\assets\sprites\zombie\僵尸_正面_4帧.png"

def make_background_transparent(input_path, output_path):
    """
    将图片的黑色背景转换为透明
    """
    print(f"📂 读取图片: {input_path}")
    img = Image.open(input_path)
    
    # 转换为RGBA模式（支持透明）
    img = img.convert("RGBA")
    datas = img.getdata()
    
    print(f"📊 图片尺寸: {img.size}")
    print(f"🎨 处理 {len(datas)} 个像素...")
    
    new_data = []
    transparent_count = 0
    
    for item in datas:
        r, g, b, a = item
        
        # 检查是否为黑色背景（RGB值都很低）
        if r < 30 and g < 30 and b < 30:
            # 设置为透明
            new_data.append((255, 255, 255, 0))
            transparent_count += 1
        else:
            # 保持原样
            new_data.append(item)
    
    print(f"✅ 处理完成！透明像素: {transparent_count}")
    
    # 更新图片数据
    img.putdata(new_data)
    
    # 确保输出目录存在
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    # 保存为PNG
    img.save(output_path, "PNG")
    print(f"💾 保存成功: {output_path}")
    
    return output_path

if __name__ == "__main__":
    try:
        make_background_transparent(input_file, output_file)
        print("\n🎉 处理完成！")
    except Exception as e:
        print(f"\n❌ 错误: {e}")
        import traceback
        traceback.print_exc()
