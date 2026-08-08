extends Node

# Create boss animation sprite sheet at startup
func _ready():
	print("🎨 Creating boss animation sprite sheet...")
	_create_boss_spritesheet()

func _create_boss_spritesheet():
	# Load boss.png
	var boss_path = "res://assets/downloads/boss.png"
	var boss_tex = load(boss_path)
	
	if not boss_tex:
		print("❌ Failed to load boss.png")
		return
	
	var src_img = boss_tex.get_image()
	print("📊 Source: " + str(src_img.get_width()) + "x" + str(src_img.get_height()))
	
	# Create 4x1 sprite sheet (256x128) - 4 frames of 64x128
	var frame_w = 64
	var frame_h = 128
	var cols = 4
	var rows = 1
	var sheet_w = frame_w * cols
	var sheet_h = frame_h * rows
	
	var sheet = Image.create(sheet_w, sheet_h, false, Image.FORMAT_RGBA8)
	
	# Downsample and arrange frames
	for frame in range(cols):
		var src_x_start = frame * (src_img.get_width() / cols)
		var src_y_start = 0
		var src_w = src_img.get_width() / cols
		var src_h = src_img.get_height()
		
		for dst_x in range(frame * frame_w, (frame + 1) * frame_w):
			for dst_y in range(frame_h):
				var src_x = src_x_start + int((dst_x - frame * frame_w) * src_w / frame_w)
				var src_y = src_y_start + int(dst_y * src_h / frame_h)
				
				if src_x < src_img.get_width() and src_y < src_img.get_height():
					var col = src_img.get_pixel(src_x, src_y)
					sheet.set_pixel(dst_x, dst_y, col)
	
	# Save to file
	var save_path = "res://assets/downloads/boss_anim_4frames.png"
	sheet.save_png(save_path)
	print("✅ Saved: " + save_path + " (" + str(sheet_w) + "x" + str(sheet_h) + ")")
