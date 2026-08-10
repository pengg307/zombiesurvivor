extends Node
class_name FloatingText

var lifetime = 1.0
var velocity = Vector2(0, -100)

func _ready():
	pass

func _process(delta):
	lifetime -= delta
	position += velocity * delta
	velocity.y -= 50 * delta  # 重力效果
	modulate.a = lifetime
	if lifetime <= 0:
		queue_free()
