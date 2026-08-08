// 粒子着色器 - 血迹效果
shader_type canvas_item;

void fragment() {
	// 红色血迹颜色
	COLOR.rgb = vec3(0.7, 0.2, 0.2);
	// 透明度基于ALPHA_TEXTURE
	COLOR.a = 0.8;
}
