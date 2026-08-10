extends CharacterBody2D
class_name Bullet

var damage = 10.0
var direction = Vector2(0, -1)
var current_speed = 600.0
var kills_for_speed = 0
var is_pierce = false
var max_distance = 1200.0
var traveled_distance = 0.0

func _ready():
	add_to_group("bullets")
	# collision_layer and collision_mask are inherited from CharacterBody2D

func _physics_process(delta):
	var move = direction * current_speed * delta
	position += move
	traveled_distance += move.length()
	
	if traveled_distance >= max_distance:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("zombies"):
		var final_damage = damage
		var is_critical = randf() < 0.15
		if is_critical:
			final_damage *= 2.0
		body.take_damage(final_damage)
		_show_damage_number(body, final_damage, is_critical)
		if not is_pierce:
			queue_free()

func _show_damage_number(target, damage, is_critical):
	var number = Label.new()
	number.text = str(int(damage))
	if is_critical:
		number.text = str(int(damage)) + "!"
	number.add_theme_font_size_override("font_size", 16 if not is_critical else 24)
	number.modulate = Color(1, 1, 0.2) if is_critical else Color(1, 1, 1)
	number.position = target.position + Vector2(0, -40)
	number.z_index = 100
	get_parent().add_child(number)
	
	var tween = create_tween()
	tween.tween_property(number, "position:y", number.position.y - 50, 0.8)
	tween.tween_property(number, "modulate:a", 0, 0.8)
	tween.tween_callback(number.queue_free)
