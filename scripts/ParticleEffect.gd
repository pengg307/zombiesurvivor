extends Node2D
class_name ParticleEffect

enum ParticleType {
	KILL,
	HIT,
	BossDeath,
	LevelUp
}

var particles = []
var lifetime = 0.5

func _ready():
	pass

func spawn_kill_effect(position: Vector2):
	spawn_particles(position, Color(1, 0.5, 0), 10)

func spawn_hit_effect(position: Vector2):
	spawn_particles(position, Color(1, 1, 1), 5)

func spawn_boss_death_effect(position: Vector2):
	spawn_particles(position, Color(1, 0.2, 0.2), 30)

func spawn_levelup_effect(position: Vector2):
	spawn_particles(position, Color(1, 1, 0.2), 20)

func spawn_particles(position: Vector2, color: Color, count: int):
	for i in range(count):
		var particle = Sprite2D.new()
		particle.texture = _get_particle_texture()
		particle.position = position
		particle.modulate = color
		particle.scale = Vector2(0.5, 0.5) * randf_range(0.5, 1.5)
		get_parent().add_child(particle)
		particles.append(particle)
		
		# 随机方向
		var angle = randf() * TAU
		var speed = randf_range(50, 150)
		var velocity = Vector2(cos(angle), sin(angle)) * speed
		
		# 动画
		var tween = create_tween()
		tween.tween_property(particle, "position", particle.position + velocity * 0.5, lifetime)
		tween.tween_property(particle, "scale", Vector2(0, 0), lifetime)
		tween.tween_property(particle, "modulate:a", 0, lifetime)
		tween.tween_callback(particle.queue_free)

func _get_particle_texture():
	# 创建简单的圆形粒子
	var canvas = CanvasItem.new()
	var rect = ColorRect.new()
	rect.size = Vector2(8, 8)
	rect.color = Color(1, 1, 1)
	canvas.add_child(rect)
	
	var texture = ImageTexture.create_from_image(rect.get_texture().get_data())
	return texture
