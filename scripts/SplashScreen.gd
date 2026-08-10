extends CanvasLayer
class_name SplashScreen

var logo_timer = 0.0
var fade_timer = 0.0
var show_content = false

@onready var logo_label = $ColorRect/VBoxContainer/LogoLabel
@onready var tagline_label = $ColorRect/VBoxContainer/TaglineLabel
@onready var loading_label = $ColorRect/VBoxContainer/LoadingLabel
@onready var version_label = $ColorRect/VBoxContainer/VersionLabel

func _ready():
	hide()
	print("🎬 启动画面系统启动")

func show():
	visible = true
	show_content = true
	logo_timer = 0.0
	fade_timer = 0.0
	print("🎬 显示启动画面")

func _process(delta):
	if not visible or not show_content:
		return
	
	logo_timer += delta
	fade_timer += delta
	
	# Logo 淡入效果
	if logo_timer < 1.0:
		$ColorRect.modulate.a = logo_timer
		logo_label.modulate.a = logo_timer
		tagline_label.modulate.a = logo_timer
	
	# 显示加载提示
	if logo_timer > 1.5:
		loading_label.visible = true
		loading_label.modulate.a = min(1.0, loading_label.modulate.a + delta * 2)
	
	# 淡出并转到游戏
	if fade_timer > 3.0:
		if $ColorRect.modulate.a > 0:
			$ColorRect.modulate.a = max(0, $ColorRect.modulate.a - delta * 2)
			logo_label.modulate.a = $ColorRect.modulate.a
			tagline_label.modulate.a = $ColorRect.modulate.a
			loading_label.modulate.a = $ColorRect.modulate.a
			version_label.modulate.a = $ColorRect.modulate.a
		else:
			print("🎬 启动画面结束，进入游戏")
			hide()
			get_tree().get_root().get_node("Game").start_game()

func start_game():
	get_tree().call_deferred("reload_current_scene")
