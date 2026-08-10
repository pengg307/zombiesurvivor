extends Node
class_name StatsManager

var stats = {
	"total_kills": 0,
	"total_boss_kills": 0,
	"total_wins": 0,
	"total_games": 0,
	"max_kills_per_game": 0,
	"total_damage_dealt": 0,
	"total_time_played": 0.0,
	"headshots": 0,
	"grenades_used": 0
}

var current_game_stats = {
	"kills": 0,
	"boss_kills": 0,
	"damage_dealt": 0,
	"start_time": 0.0
}

func _ready():
	_load_stats()

func _load_stats():
	var config = ConfigFile.new()
	var err = config.load("user://stats.cfg")
	if err == OK:
		for key in stats:
			if config.has_section_key("stats", key):
				stats[key] = config.get_value("stats", key)

func _save_stats():
	var config = ConfigFile.new()
	for key in stats:
		config.set_value("stats", key, stats[key])
	config.save("user://stats.cfg")

func start_game():
	current_game_stats["kills"] = 0
	current_game_stats["boss_kills"] = 0
	current_game_stats["damage_dealt"] = 0
	current_game_stats["start_time"] = Time.get_ticks_msec() / 1000.0
	stats["total_games"] += 1

func add_kill(is_boss = false):
	current_game_stats["kills"] += 1
	stats["total_kills"] += 1
	
	if is_boss:
		current_game_stats["boss_kills"] += 1
		stats["total_boss_kills"] += 1

func add_damage(amount: float):
	current_game_stats["damage_dealt"] += amount
	stats["total_damage_dealt"] += amount

func add_headshot():
	current_game_stats["headshots"] += 1
	stats["headshots"] += 1

func add_grenade():
	stats["grenades_used"] += 1

func end_game(won: bool):
	var end_time = Time.get_ticks_msec() / 1000.0
	var game_time = end_time - current_game_stats["start_time"]
	stats["total_time_played"] += game_time
	
	if won:
		stats["total_wins"] += 1
	
	if current_game_stats["kills"] > stats["max_kills_per_game"]:
		stats["max_kills_per_game"] = current_game_stats["kills"]
	
	_save_stats()

func get_win_rate() -> float:
	if stats["total_games"] == 0:
		return 0.0
	return float(stats["total_wins"]) / float(stats["total_games"]) * 100.0

func get_average_kills() -> float:
	if stats["total_games"] == 0:
		return 0.0
	return float(stats["total_kills"]) / float(stats["total_games"])

func get_current_kills() -> int:
	return current_game_stats["kills"]

func get_current_damage() -> float:
	return current_game_stats["damage_dealt"]

func reset_stats():
	stats = {
		"total_kills": 0,
		"total_boss_kills": 0,
		"total_wins": 0,
		"total_games": 0,
		"max_kills_per_game": 0,
		"total_damage_dealt": 0,
		"total_time_played": 0.0,
		"headshots": 0,
		"grenades_used": 0
	}
	current_game_stats = {
		"kills": 0,
		"boss_kills": 0,
		"damage_dealt": 0,
		"start_time": 0.0
	}
	_save_stats()
