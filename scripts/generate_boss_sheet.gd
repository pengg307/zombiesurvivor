extends SceneTree

func _init():
	# Create boss sprite sheet
	var boss_path = "res://assets/downloads/boss.png"
	var boss_tex = load(boss_path)
	
	if not boss_tex:
		print("ERROR: Failed to load boss.png")
		quit(1)
		return
	
	var src_img = boss_tex.get_image()
	print("Source: " + str(src_img.get_width()) + "x" + str(src_img.get_height()))
	
	# Create 4x1 sprite sheet (256x128)
	var frame_w = 64
	var frame_h = 128
	var cols = 4
	var sheet = Image.create(frame_w * cols, frame_h, false, Image.FORMAT_RGBA8)
	
	# Downsample boss (512x512) to 4 frames of 64x128
	var src_w = src_img.get_width()
	var src_h = src_img.get_height()
	var slice_w = src_w / cols
	
	for frame in range(cols):
		var src_x_start = frame * slice_w
		for dst_x in range(frame * frame_w, (frame + 1) * frame_w):
			for dst_y in range(frame_h):
				var src_x = src_x_start + int((dst_x - frame * frame_w) * slice_w / frame_w)
				var src_y = int(dst_y * src_h / frame_h)
				
				if src_x < src_w and src_y < src_h:
					var col = src_img.get_pixel(src_x, src_y)
					sheet.set_pixel(dst_x, dst_y, col)
	
	# Save
	var save_path = "res://assets/downloads/boss_anim_4frames.png"
	sheet.save_png(save_path)
	print("Saved: " + save_path + " (" + str(frame_w * cols) + "x" + str(frame_h) + ")")
	
	quit(0)
