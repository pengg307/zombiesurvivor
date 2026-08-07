extends Node2D

const SCREEN_WIDTH = 720.0
const SCREEN_HEIGHT = 1280.0

func _ready():
	# 加载街道背景图片
	var bg = Sprite2D.new()
	bg.name = "StreetBackground"
	var texture = load("res://assets/downloads/street.png")
	if texture:
		bg.texture = texture
		# 居中并调整大小以匹配屏幕
		bg.position = Vector2(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
		bg.scale = Vector2(SCREEN_WIDTH / texture.get_width(), SCREEN_HEIGHT / texture.get_height())
		bg.z_index = 0  # 最底层
		add_child(bg)
		print("✅ 街道背景加载完成")
	else:
		# 如果加载失败，使用默认背景
		_create_default_background()
		print("⚠️ 街道图片加载失败，使用默认背景")

func _create_default_background():
	# 默认渐变背景
	var sky = ColorRect.new()
	sky.name = "Sky"
	sky.size = Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)
	sky.color = Color(0.4, 0.4, 0.4)
	add_child(sky)
	print("⚠️ 使用默认灰色背景")
