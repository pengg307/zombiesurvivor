extends Control
class_name ShopPanel

var player = null
var spawner = null

# 商店物品
const SHOP_ITEMS = {
	"weapon_unlock": {"name": "解锁霰弹枪", "cost": 50, "icon": "🔫", "type": "unlock"},
	"weapon_unlock2": {"name": "解锁步枪", "cost": 100, "icon": "🔫", "type": "unlock2"},
	"hp_up": {"name": "生命上限+20", "cost": 30, "icon": "❤️", "type": "hp"},
	"damage_up": {"name": "伤害+10%", "cost": 25, "icon": "⚔️", "type": "damage"},
	"speed_up": {"name": "移速+10%", "cost": 20, "icon": "👟", "type": "speed"}
}

var purchased_items = []

func _ready():
	hide()

func show_panel(p, sp):
	player = p
	spawner = sp
	purchased_items.clear()
	_populate_shop()
	visible = true

func hide_panel():
	visible = false

func _populate_shop():
	# 清空旧物品
	for child in get_children():
		if child.name != "PanelContainer":
			child.queue_free()
	
	var container = get_node("PanelContainer/VBoxContainer")
	if not container:
		return
	
	for item_key in SHOP_ITEMS:
		var item = SHOP_ITEMS[item_key]
		var btn = Button.new()
		btn.text = item.icon + " " + item.name + " (" + str(item.cost) + "击杀)"
		btn.disabled = player.kills < item.cost or item_key in purchased_items
		btn.pressed.connect(_on_item_purchased.bind(item_key, item))
		container.add_child(btn)

func _on_item_purchased(item_key, item):
	if player.kills >= item.cost and not (item_key in purchased_items):
		purchased_items.append(item_key)
		player.kills -= item.cost
		_apply_item(item)
		_populate_shop()
		print("🛒 购买成功: " + item.name)

func _apply_item(item):
	match item.type:
		"unlock":
			if player:
				player.unlocked_shotgun = true
		"unlock2":
			if player:
				player.unlocked_rifle = true
		"hp":
			if player:
				player.MAX_HEALTH += 20
				player.current_health += 20
		"damage":
			if player:
				player.damage_per_shot *= 1.1
		"speed":
			if player:
				player.MOVE_SPEED *= 1.1
