extends Control
class_name StatsPanel

var stats_manager = null

func _ready():
	hide()
	var sm = get_tree().get_first_node_in_group("stats_manager")
	if sm:
		stats_manager = sm

func show_panel():
	visible = true
	_update_stats()

func hide_panel():
	visible = false

func _update_stats():
	if not stats_manager:
		return
	
	# 更新统计显示
	var total_kills_label = get_node_or_null("PanelContainer/VBoxContainer/TotalKillsLabel")
	if total_kills_label:
		total_kills_label.text = "总击杀: " + str(stats_manager.stats["total_kills"])
	
	var total_wins_label = get_node_or_null("PanelContainer/VBoxContainer/TotalWinsLabel")
	if total_wins_label:
		total_wins_label.text = "总胜利: " + str(stats_manager.stats["total_wins"])
	
	var win_rate_label = get_node_or_null("PanelContainer/VBoxContainer/WinRateLabel")
	if win_rate_label:
		win_rate_label.text = "胜率: %.1f%%" % stats_manager.get_win_rate()
	
	var max_kills_label = get_node_or_null("PanelContainer/VBoxContainer/MaxKillsLabel")
	if max_kills_label:
		max_kills_label.text = "单局最高: " + str(stats_manager.stats["max_kills_per_game"])
	
	var avg_kills_label = get_node_or_null("PanelContainer/VBoxContainer/AvgKillsLabel")
	if avg_kills_label:
		avg_kills_label.text = "平均击杀: %.1f" % stats_manager.get_average_kills()

func _on_reset_pressed():
	if stats_manager:
		stats_manager.reset_stats()
		_update_stats()
		print("📊 统计数据已重置")
