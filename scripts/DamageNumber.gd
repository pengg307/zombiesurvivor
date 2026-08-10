extends Node2D

var damage = 10.0
var direction = Vector2(0, -1)
var current_speed = 600.0
var kills_for_speed = 0
var is_pierce = false
var max_distance = 1200.0
var traveled_distance = 0.0

func _ready():
	add_to_group("bullets")
	collision_layer = 3
	collision_mask = 2  # Hit zombies (layer 2)

func _physics_process(delta):
	var move = direction * current_speed * delta
	position += move
	traveled_distance += move.length()
	
	if traveled_distance >= max_distance:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("zombies"):
		var damage = damage
		# 暴击判定
		var is_critical = randf() < 0.15  # 15%暴击率
		if is_critical:
			damage *= 2.0
		body.take_damage(damage)
		_show_damage_number(body, damage, is_critical)
		if not is_pierce:
			queue_free()

func _show_damage_number(target, damage, is_critical):
	var scene = load("res://scenes/DamageNumber.tscn")
	if scene:
		var number = scene.instantiate()
		number.position = target.position + Vector2(0, -30)
		number.damage_value = int(damage)
		number.is_critical = is_critical
		get_parent().add_child(number)
