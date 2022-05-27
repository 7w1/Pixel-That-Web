extends Control

const HEADERS = ["Authorization: Client-ID {id here}"]

# image stuff
var image = null
var tex = null
var preload_image = null
var url = null
var data = {"data":[]}
var image_type = null
var image_link = ""
var preload_image_link = ""
var old_text_box = ""
var gen_image = false
var completed_animation = false
# pixel data stuff
var unrevealed_pixels = []
var process_mouse = false
var mouse_pos = Vector2()
var height
var width
# saved game data stuff
var start_pixels = 0
var start_pixels_per_pixel = 1
var start_res = 10
var start_auto_cursors = 0
var start_auto_cursor_power = 1
var start_regen_pixels = 0
var start_image_completion_multi = 2
var start_icm_increment = 1
var start_completed_images = 0
var start_locked_achievements = [
 "completed_images_1",
 "completed_images_5",
 "completed_images_10",
 "completed_images_25",
 "completed_images_50",
 "completed_images_69",
 "completed_images_75",
 "completed_images_100",
 "completed_images_250",
 "completed_images_500",
 "completed_images_1000",
 "completed_images_2000",
 "completed_images_3000",
 "completed_images_4000",
 "completed_images_5000",
 "completed_images_6000",
 "completed_images_7000",
 "completed_images_8000",
 "completed_images_9000",
 "completed_images_10000"
]
var start_prestiges = 0
var start_party_pixel_multi = 5
var start_party_pixel_multi_num = 0
var start_party_pixel_max_wait_time = 600
var start_party_pixel_max_wait_time_num = 0
var start_party_pixel_length = 10
var start_glitch_pixel_multi = 100
var start_glitch_pixel_multi_num = 0
var start_glitch_pixel_max_wait_time = 1200
var start_glitch_pixel_max_wait_time_num = 0
var start_glitch_pixel_length = 10

var lifetime_pixels = 0
var time_played = 0
var pixels
var pixels_per_pixel
var res = 10
var auto_cursors
var auto_cursor_power
var regen_pixels
var image_completion_multi
var icm_increment
var completed_images
var locked_achievements
var prestiges
var party_pixel_multi
var party_pixel_multi_num
var party_pixel_max_wait_time
var party_pixel_max_wait_time_num
var party_pixel_length
var glitch_pixel_multi
var glitch_pixel_multi_num
var glitch_pixel_max_wait_time
var glitch_pixel_max_wait_time_num
var glitch_pixel_length
var auto_cursor_update_speed = 1
var spawn_pattern = 0
var hover_to_uncover = false
var game_version = "0.0.3"

# unsaved data
var auto_cursor_cost_multi = 1.5
var auto_cursor_power_increment = 1
var auto_cursor_empower_cost_multi = 1.07
var auto_cursor_empower_power = 1
var image_completion_cost_multi = 2.2
var regen_pixel_multi = 2
var current_party_multi = 1
var current_glitch_multi = 1
var move_party_pixel = false
var party_active = false
var move_glitch_pixel = false
var glitch_active = false
var party_pixel_multi_cost_multi = 1.9
var party_pixel_multi_multi = 2
var party_pixel_length_cost_multi = 1.5
var party_pixel_length_increment = 5
var party_pixel_max_wait_time_cost_multi = 2.1
var party_pixel_wait_time_multi = 0.95
var glitch_pixel_multi_cost_multi = 2.1
var glitch_pixel_multi_multi = 2
var glitch_pixel_length_cost_multi = 1.6
var glitch_pixel_length_increment = 5
var glitch_pixel_max_wait_time_cost_multi = 2.3
var glitch_pixel_wait_time_multi = 0.95
var past_images = []
var page = 1
var achievement_boost = 1.00
var buy_amount = 10

func _ready():
	randomize()
	load_data()
	$SidePanel/Panel/Menu/VBoxContainer/HBoxContainer2/OptionButton.select(spawn_pattern)
	$AutoCursorTimer.stop()
	$AutoCursorTimer.wait_time = auto_cursor_update_speed
	$SidePanel/Panel/Menu/VBoxContainer/HBoxContainer/LineEdit.text = str(auto_cursor_update_speed)
	$AutoCursorTimer.start()
	$AchievementCheck.start()
	$UIUpdate.start()
	$SidePanel/Panel/Menu/VBoxContainer/HBoxContainer3/CheckBox.pressed = hover_to_uncover
	new_image()
	# Party Pixel
	$PartyTimer.wait_time = rand_range(10, party_pixel_max_wait_time)
	$PartyTimer.start()
	$PartyPixel.position.x = -80
	# Glitch Pixel
	$GlitchTimer.wait_time = rand_range(10, glitch_pixel_max_wait_time)
	$GlitchTimer.start()
	$GlitchPixel.position.x = -80
	
	update_ui_buttons()
	
	for i in start_locked_achievements:
		if not locked_achievements.has(i):
			display_achievement(i)

func alert(text: String, text2: String) -> void:
	$Achievement/Label.text = text
	$Achievement/Label2.text = text2
	$Achievement.popup()
	$AchievementHide.start()

func _on_Achivement_popup_hide():
	$AchievementHide.stop()

func _on_AchivementHide_timeout():
	$Achievement.hide()

func save_data():
	var save_game = File.new()
	save_game.open("user://save.file", File.WRITE)
	save_game.store_line(to_json({
		"pixels": pixels,
		"pixels_per_pixel": pixels_per_pixel,
		"res": res,
		"auto_cursors": auto_cursors,
		"auto_cursor_power": auto_cursor_power,
		"regen_pixels": regen_pixels,
		"image_completion_multi": image_completion_multi,
		"icm_increment": icm_increment,
		"completed_images": completed_images,
		"locked_achievements": locked_achievements,
		"prestiges": prestiges,
		"party_pixel_multi": party_pixel_multi,
		"party_pixel_multi_num": party_pixel_multi_num,
		"party_pixel_max_wait_time": party_pixel_max_wait_time,
		"party_pixel_max_wait_time_num": party_pixel_max_wait_time_num,
		"party_pixel_length": party_pixel_length,
		"glitch_pixel_multi": glitch_pixel_multi,
		"glitch_pixel_multi_num": glitch_pixel_multi_num,
		"glitch_pixel_max_wait_time": glitch_pixel_max_wait_time,
		"glitch_pixel_max_wait_time_num": glitch_pixel_max_wait_time_num,
		"glitch_pixel_length": glitch_pixel_length,
		"lifetime_pixels": lifetime_pixels,
		"time_played": time_played,
		"auto_cursor_update_speed": auto_cursor_update_speed,
		"spawn_pattern": spawn_pattern,
		"hover_to_uncover": hover_to_uncover,
		"game_version": game_version,
		"save_time": OS.get_system_time_msecs()
	}))
	save_game.close()
func load_data():
	var save_game = File.new()
	if not save_game.file_exists("user://save.file"):
		data = {"data":[]}
		pixels = start_pixels
		pixels_per_pixel = start_pixels_per_pixel
		res = start_res
		auto_cursors = start_auto_cursors
		auto_cursor_power = start_auto_cursor_power
		regen_pixels = start_regen_pixels
		image_completion_multi = start_image_completion_multi
		icm_increment = start_icm_increment
		completed_images = start_completed_images
		locked_achievements = start_locked_achievements
		prestiges = start_prestiges
		party_pixel_multi = start_party_pixel_multi
		party_pixel_multi_num = start_party_pixel_multi_num
		party_pixel_max_wait_time = start_party_pixel_max_wait_time
		party_pixel_max_wait_time_num = start_party_pixel_max_wait_time_num
		party_pixel_length = start_party_pixel_length
		glitch_pixel_multi = start_glitch_pixel_multi
		glitch_pixel_multi_num = start_glitch_pixel_multi_num
		glitch_pixel_max_wait_time = start_glitch_pixel_max_wait_time
		glitch_pixel_max_wait_time_num = start_glitch_pixel_max_wait_time_num
		glitch_pixel_length = start_glitch_pixel_length
		lifetime_pixels = 0
		time_played = 0
		auto_cursor_update_speed = 1
		spawn_pattern = 0
		hover_to_uncover = false
		save_data()
		return
	save_game.open("user://save.file", File.READ)
	var save_data = parse_json(save_game.get_line())
	pixels = save_data["pixels"]
	pixels_per_pixel = save_data["pixels_per_pixel"]
	res = save_data["res"]
	auto_cursors = save_data["auto_cursors"]
	auto_cursor_power = save_data["auto_cursor_power"]
	regen_pixels = save_data["regen_pixels"]
	image_completion_multi = save_data["image_completion_multi"]
	icm_increment = save_data["icm_increment"]
	completed_images = save_data["completed_images"]
	if save_data.has("locked_achivements"):
		locked_achievements = save_data["locked_achivements"]
	else:
		locked_achievements = save_data["locked_achievements"]
	prestiges = save_data["prestiges"]
	party_pixel_multi = save_data["party_pixel_multi"]
	party_pixel_multi_num = save_data["party_pixel_multi_num"]
	party_pixel_max_wait_time = save_data["party_pixel_max_wait_time"]
	party_pixel_max_wait_time_num = save_data["party_pixel_max_wait_time_num"]
	party_pixel_length = save_data["party_pixel_length"]
	glitch_pixel_multi = save_data["glitch_pixel_multi"]
	glitch_pixel_multi_num = save_data["glitch_pixel_multi_num"]
	glitch_pixel_max_wait_time = save_data["glitch_pixel_max_wait_time"]
	glitch_pixel_max_wait_time_num = save_data["glitch_pixel_max_wait_time_num"]
	glitch_pixel_length = save_data["glitch_pixel_length"]
	lifetime_pixels = save_data["lifetime_pixels"]
	time_played = save_data["time_played"]
	if save_data.has("auto_cursor_update_speed"):
		auto_cursor_update_speed = save_data["auto_cursor_update_speed"]
	else:
		auto_cursor_update_speed = 1
	if save_data["game_version"] == "0.0.2":
		spawn_pattern = 0
	else:
		spawn_pattern = save_data["spawn_pattern"]
	if save_data.has("hover_to_uncover"):
		hover_to_uncover = save_data["hover_to_uncover"]
	else:
		hover_to_uncover = false
	# calculate offline production
	pixels += ((auto_cursors*auto_cursor_power)-regen_pixels)*((OS.get_system_time_msecs()-int(save_data["save_time"]))/1000)*pixels_per_pixel*achievement_boost
	save_game.close()
	
func _on_Button_pressed():
	new_image()

func _on_HTTPRequest_request_completed(_result, response_code, headers, body):
	if int(response_code) != 200:
		var error = "Unknown error, contact 7w1."
		if response_code == 400:
			error = "A parameter is missing or something like that, contact 7w1 and send him this data:\n"+Marshalls.utf8_to_base64(url+"-----"+HEADERS)
		elif response_code == 401:
			error = "We're not authorized for some reason, contact 7w1 and send him this data:\n"+Marshalls.utf8_to_base64(headers)
		elif response_code == 403:
			error = "We're not authorized for some reason, contact 7w1 and send him this data:\n"+Marshalls.utf8_to_base64(headers)
		elif response_code == 404:
			error = "The image doesn't exists! Not sure how this happened but if you can't figure it out, contact 7w1."
		elif response_code == 429:
			error = "Oh no! We might have hit a rate limit, contact 7w1 and send him this data:\n"+Marshalls.utf8_to_base64(headers)
		elif response_code == 500:
			error = "Looks like imgur's api is broken :( Try again in a few minutes, maybe it'll be fixed."
		push_error("Response Code: "+response_code+"\n"+error)
	else:
		# Convert response to dictionary
		data = JSON.parse(body.get_string_from_utf8()).result
		print("Got images...")
		new_image()
	
func new_image():
	gen_image = true
	$NewImageWait.start()
	
func new_preload_image():
	pass

func _on_HTTPRequest2_request_completed(_result, _response_code, _headers, body):
	# Load image
	if image_type == "image/png":
		image.load_png_from_buffer(body)
	elif image_type == "image/jpeg":
		image.load_jpg_from_buffer(body)
	else:
		print("Skipped, incompatible image type.")
#		image = preload_image
#		image_link = preload_image_link
#		new_preload_image()
		new_image()
		return
	# Downscale/upscale
	var width_difference = res - image.get_width()
	var height_difference = res - image.get_height()
	height
	width
	if width_difference < height_difference:
		height = ceil(float(image.get_height())/(float(image.get_width())/res))
		width = res
	else:
		width = ceil(float(image.get_width())/(float(image.get_height())/res))
		height = res
	image.resize(width,height,1)
	# Put on screen
	tex = ImageTexture.new()
	tex.create_from_image(image)
	tex.set_flags(3)
	$Picture/Container/TextureRect.rect_min_size = Vector2(width,height)
	$Picture/Container/TextureRect.texture = tex
	$Picture/Container/TextureRect.visible = false
	# Create and show overlay
	var temp_image = Image.new()
	temp_image.create(width,height,false,Image.FORMAT_LA8)
	temp_image.lock()
	for i in range(width):
		for j in range(height):
			temp_image.set_pixel(i,j,Color8(0,0,0,255))
	temp_image.unlock()
	var temp_tex = ImageTexture.new()
	temp_tex.create_from_image(temp_image, 0)
	$Picture/Container/TextureOverlay.rect_min_size = Vector2(width,height)
	$Picture/Container/TextureOverlay.texture = temp_tex
	$Picture/Container/TextureOverlay.visible = false
	# Rescale container
	var scale = ceil(float(500)/res)
	$Picture/Container.rect_scale.x = scale
	$Picture/Container.rect_scale.y = scale
	$Picture/Container/TextureRect.visible = true
	$Picture/Container/TextureOverlay.visible = true
	$Picture/Container.hide()
	$Picture/Container.show()
	unrevealed_pixels = []
	for y in range(0,height):
		for x in range(0,width):
			unrevealed_pixels.append(Vector2(x,y))
	if $SidePanel/Panel/Menu/VBoxContainer/HBoxContainer2/OptionButton.selected == 1:
		unrevealed_pixels.invert()
	elif $SidePanel/Panel/Menu/VBoxContainer/HBoxContainer2/OptionButton.selected == 2:
		unrevealed_pixels.shuffle()
	$"Picture/New Image".disabled = false
	$Picture/ConsoleInfo.hide()
	$Picture/Container/TextureRect.show()
	$Picture/Container/TextureOverlay.show()
	$Bottom/RichTextLabel.bbcode_text = "                           Game by 7w1\n[url="+image_link+"]Current Image[/url]  Concept by 1WithBacon"
	gen_image = false
	print("Image displayed successfully.")

func _process(delta):
	# Tutorial
	if completed_images == 0:
		$Picture/Search.hide()
		$"Picture/New Image".hide()
		$Picture/Pixels.hide()
		$Picture/Pixels2.hide()
		$Picture/Pixels3.hide()
		$SidePanel.hide()
	elif completed_images == 1:
		$"Picture/New Image".show()
	elif completed_images == 2:
		$Picture/Pixels.show()
	elif completed_images == 3:
		$Picture/Search.show()
	elif completed_images == 4:
		$Picture/Pixels2.show()
		$Picture/Pixels3.show()
	elif completed_images == 5:
		$SidePanel.show()
		$SidePanel/Buttons/PrestigeButton.hide()
		$SidePanel/Buttons/AchievementsButton.hide()
		$SidePanel/Buttons/StatsButton.hide()
		$SidePanel/Buttons/MenuButton.hide()
	elif completed_images == 10:
		$SidePanel/Buttons/PrestigeButton.show()
	elif completed_images == 25:
		$SidePanel/Buttons/AchievementsButton.show()
		$SidePanel/Buttons/StatsButton.show()
		$SidePanel/Buttons/MenuButton.show()
		
	# Work around for mouse position collision with textures because godot is broken as f with this
	var rect_check = Rect2(Vector2(0,0), $Picture/Container/TextureOverlay.get_global_rect().size)
	var local_mouse_pos = $Picture/Container/TextureOverlay.get_local_mouse_position()
	if rect_check.has_point(local_mouse_pos):
		process_mouse = true
	else:
		process_mouse = false
	# Check if the user is drawing on the overlay
	var held = false
	if hover_to_uncover == true:
		held = true
	elif Input.is_action_pressed("mouse_button"):
		held = true
	if process_mouse and not gen_image and held:
		# Get mouse and overlay data
		mouse_pos = $Picture/Container/TextureOverlay.get_local_mouse_position()
		var temp_image = $Picture/Container/TextureOverlay.texture.get_data()
		# If the current pixel hasn't been revealed...
		temp_image.lock()
		if temp_image.get_pixel(mouse_pos.x,mouse_pos.y) == Color8(0,0,0,255):
			# Reveal it, add it to array, and increase pixels
			temp_image.set_pixel(mouse_pos.x,mouse_pos.y,Color8(0,0,0,0))
			var temp_tex = ImageTexture.new()
			temp_tex.create_from_image(temp_image, 0)
			$Picture/Container/TextureOverlay.texture = temp_tex
			
			unrevealed_pixels.erase(Vector2(floor(mouse_pos.x), floor(mouse_pos.y)))
			pixels += pixels_per_pixel*current_party_multi*achievement_boost
			lifetime_pixels += pixels_per_pixel*current_party_multi*achievement_boost
		temp_image.unlock()
	# Update text
	$Picture/Pixels.text = "Pixels: "+format_val(pixels)
	$Picture/Pixels2.text = "PPS: "+format_val(auto_cursors*auto_cursor_power)+" - PPP: "+format_val(pixels_per_pixel*achievement_boost)
	$Picture/Pixels3.text = "DIFF: "+format_val(auto_cursors*auto_cursor_power-regen_pixels)+" - ICM: "+format_val(image_completion_multi)+"x"
	# Check if image is complete
	if unrevealed_pixels.size() <= 0 and gen_image == false:
		completed_images += 1
		if auto_cursors*auto_cursor_power-regen_pixels >=0 or glitch_active:
			pixels += width*height*image_completion_multi*pixels_per_pixel*current_party_multi*achievement_boost*current_glitch_multi
			lifetime_pixels += width*height*image_completion_multi*pixels_per_pixel*current_party_multi*achievement_boost*current_glitch_multi
		else:
			pixels += width*height*pixels_per_pixel*current_party_multi*achievement_boost
			lifetime_pixels += width*height*pixels_per_pixel*current_party_multi*achievement_boost
		new_image()
	# Party Pixel Detection and stuff
	if move_party_pixel:
		$PartyPixel.position.x += 100*delta
		# Check if clicked
		rect_check = Rect2(Vector2(0,0), $PartyPixel/Control.get_global_rect().size)
		local_mouse_pos = $PartyPixel/Control.get_local_mouse_position()
		if rect_check.has_point(local_mouse_pos) and Input.is_action_pressed("mouse_button"):
			$PartyPixel.position.x = -80
			move_party_pixel = false
			party_active = true
			current_party_multi = party_pixel_multi
			$PartyLengthTiemr.start()
		# Check if out of screen
		if $PartyPixel.position.x > OS.get_window_size().x:
			$PartyPixel.position.x = -80
			move_party_pixel = false
			$PartyTimer.start()
	if party_active: 
		VisualServer.set_default_clear_color(Color("b36d44"))
	# Glitch Pixel Detection and stuff
	if move_glitch_pixel:
		$GlitchPixel.position.x += 100*delta
		# Check if clicked
		rect_check = Rect2(Vector2(0,0), $GlitchPixel/Control.get_global_rect().size)
		local_mouse_pos = $GlitchPixel/Control.get_local_mouse_position()
		if rect_check.has_point(local_mouse_pos) and Input.is_action_pressed("mouse_button"):
			$GlitchPixel.position.x = -80
			move_glitch_pixel = false
			glitch_active = true
			current_glitch_multi = glitch_pixel_multi
			$GlitchLengthTimer.start()
		# Check if out of screen
		if $GlitchPixel.position.x > OS.get_window_size().x:
			$GlitchPixel.position.x = -80
			move_glitch_pixel = false
			$GlitchTimer.start()
	if glitch_active: 
		VisualServer.set_default_clear_color(Color("009933"))

func _input(event):
	if event.is_action("buyautocursors"):
		var cost = auto_cursor_start_cost
		for _i in range(0,auto_cursors):
			cost *= auto_cursor_cost_multi
		if pixels >= floor(cost):
			pixels -= floor(cost)
			auto_cursors += 1
			# Update gui buttons
			$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/Amount/Label.text = format_val(auto_cursors)
			$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/BuyAutoCursor.text = "Buy for "+format_val(floor(cost*auto_cursor_cost_multi))+" pixels"


func format_val_small(_sign: int, value: float) -> String:
	if value < 10:
		return String(stepify(_sign * value, .01)) # 5.43
	return String(stepify(_sign * value, .1)) # 22.8
 
 
func format_val_medium(_sign: int, value) -> String:   
	value = String(_sign * round(value))
	var output := ""
	for i in range(0, value.length()):
		if i != 0 and i % 3 == value.length() % 3:
			output += ","
		output += value[i]
	return output # 342,945
	
func format_val_sci(_sign: int, value: float) -> String:
	var _exp := String(value).split(".")[0].length() - 1
	var coefficient := value / pow(10, _exp)
	return String(stepify(_sign * coefficient, .01)) + "e" + String(_exp)
	
func format_val(value: float) -> String:
	if value == 0.0:
		return "0"
	var _sign := sign(value)
	value = abs(value)
	if value >= 1000000.0:
		return format_val_sci(_sign, value) # 2e7
	if value < 100.0:
		return format_val_small(_sign, value) # 10.0
	if value < 1000.0:
		return String(round(_sign * value)) # 100
	return format_val_medium(_sign, value) # 100,000

func _on_Timer_timeout():
	if height != null:
		var temp_image = $Picture/Container/TextureOverlay.texture.get_data()
		temp_image.lock()
		var loop_amount
		if floor(rand_range(0,2)) == 0:
			loop_amount = ceil(((auto_cursors*auto_cursor_power)-regen_pixels)*float(auto_cursor_update_speed))
		else:
			loop_amount = floor(((auto_cursors*auto_cursor_power)-regen_pixels)*float(auto_cursor_update_speed))
		if loop_amount < 0:
			return
		for _i in range(0, loop_amount):
			if unrevealed_pixels.size() == 0:
				var temp_tex = ImageTexture.new()
				temp_tex.create_from_image(temp_image, 0)
				$Picture/Container/TextureOverlay.texture = temp_tex
				temp_image.unlock()
				return
			if gen_image == true:
				return
			var item = unrevealed_pixels[unrevealed_pixels.size()-1]
			unrevealed_pixels.pop_back()
			temp_image.set_pixel(item.x,item.y,Color8(0,0,0,0))
			pixels += pixels_per_pixel*current_party_multi*achievement_boost
		var temp_tex = ImageTexture.new()
		temp_tex.create_from_image(temp_image, 0)
		$Picture/Container/TextureOverlay.texture = temp_tex
		temp_image.unlock()

func _on_AutoSaveTimer_timeout():
	save_data()

func _on_GuiScaleUpdateSpeed_timeout():
	update_gui_scale()

func update_gui_scale():
	# scale picture
	$Picture.rect_scale = Vector2(OS.get_window_size().y/750,OS.get_window_size().y/750)
	# scale side panel
	var temp_button_x = $SidePanel/Panel.rect_position.x-28
	$SidePanel/Buttons/UpgradesButton.rect_position.x = temp_button_x
	$SidePanel/Buttons/PrestigeButton.rect_position.x = temp_button_x
	$SidePanel/Buttons/AchievementsButton.rect_position.x = temp_button_x
	$SidePanel/Buttons/StatsButton.rect_position.x = temp_button_x
	$SidePanel/Buttons/MenuButton.rect_position.x = temp_button_x
	var temp_button_size = (OS.get_window_size().y-50)/5
	$SidePanel/Buttons/UpgradesButton.rect_size.x = temp_button_size
	$SidePanel/Buttons/PrestigeButton.rect_size.x = temp_button_size
	$SidePanel/Buttons/AchievementsButton.rect_size.x = temp_button_size
	$SidePanel/Buttons/StatsButton.rect_size.x = temp_button_size
	$SidePanel/Buttons/MenuButton.rect_size.x = temp_button_size
	var temp_button_y = OS.get_window_size().y-20
	$SidePanel/Buttons/MenuButton.rect_position.y = temp_button_y
	temp_button_y -= temp_button_size+2
	$SidePanel/Buttons/StatsButton.rect_position.y = temp_button_y
	temp_button_y -= temp_button_size+2
	$SidePanel/Buttons/AchievementsButton.rect_position.y = temp_button_y
	temp_button_y -= temp_button_size+2
	$SidePanel/Buttons/PrestigeButton.rect_position.y = temp_button_y
	temp_button_y -= temp_button_size+2
	$SidePanel/Buttons/UpgradesButton.rect_position.y = temp_button_y


func _on_ForceUI_pressed():
	update_gui_scale()


func _on_ForceSave_pressed():
	save_data()

func _on_NewImageWait_timeout():
	$Picture/ConsoleInfo.show()
	$Picture/Container/TextureRect.hide()
	$Picture/Container/TextureOverlay.hide()
	$"Picture/New Image".disabled = true
	if data["data"].size() == 0 or old_text_box != $Picture/Search.text:
		if $Picture/Search.text == "" or $Picture/Search.text == "Search...":
			url = 'https://api.imgur.com/3/gallery/random/random/'+str(page)
			page += 1
			if page >= 10:
				page = 1
			old_text_box = $Picture/Search.text
		else:
			old_text_box = $Picture/Search.text
			url = 'https://api.imgur.com/3/gallery/search/time/top/'+str(page)+'?q='+$Picture/Search.text
			page += 1
			if page >= 10:
				page = 1
		$HTTPRequest.request(url,HEADERS,true,HTTPClient.METHOD_GET)
		print("Requesting new images from imgur...")
	else:
		print("Displaying image...")
		# Get random image from data
		var rand_gallery = rand_range(0,data["data"].size()-1)
		if data["data"][rand_gallery].has("images"):
			var rand_image = rand_range(0,data["data"][rand_gallery]["images"].size()-1)
			image_type = data["data"][rand_gallery]["images"][rand_image]["type"]
			image_link = data["data"][rand_gallery]["images"][rand_image]["link"]
			# Erase image from data
			data["data"][rand_gallery]["images"].erase(rand_image)
			if data["data"][rand_gallery]["images"].size() == 0:
				data["data"].erase(rand_gallery)
			# Check if its been seen
			if image_link in past_images:
				new_image()
				return
			else:
				past_images.append(image_link)
				if past_images.size() >= 10:
					past_images.pop_front()
			# Display image
			image = Image.new()
			if image_type == "image/png" or image_type == "image/jpeg":
				$HTTPRequest2.request(image_link)
				return
			else:
				print("Skipped, incompatible image type.")
				new_image()
				return
		else:
			image_type = data["data"][rand_gallery]["type"]
			image_link = data["data"][rand_gallery]["link"]
			data["data"].erase(rand_gallery)
			# Check if its been seen
			if image_link in past_images:
				new_image()
				return
			else:
				past_images.append(image_link)
				if past_images.size() >= 10:
					past_images.pop_front()
			# Display image
			image = Image.new()
			if image_type == "image/png" or image_type == "image/jpeg":
				$HTTPRequest2.request(image_link)
				return
			else:
				print("Skipped, incompatible image type.")
				new_image()
				return


func _on_AchivementCheck_timeout():
	# update stats
	update_stats()
	# boost
	achievement_boost = (start_locked_achievements.size() - locked_achievements.size())*0.01 + 1
	$SidePanel/Panel/Achievements/VBoxContainer/Label3.text = "Current: "+format_val((achievement_boost-1)*100)+"%"
	# display them
	for i in start_locked_achievements:
		if not locked_achievements.has(i):
			display_achievement(i)
	# Images completed
	if completed_images >= 1 and locked_achievements.has("completed_images_1"):
		alert("Completed your first image image!", "1 image completed!")
		locked_achievements.erase("completed_images_1")
	if completed_images >= 5 and locked_achievements.has("completed_images_5"):
		alert("The start of a journey.", "5 images completed!")
		locked_achievements.erase("completed_images_5")
	if completed_images >= 10 and locked_achievements.has("completed_images_10"):
		alert("Becoming an artist...", "10 images completed!")
		locked_achievements.erase("completed_images_10")
	if completed_images >= 25 and locked_achievements.has("completed_images_25"):
		alert("Getting somewhere...", "25 images completed!")
		locked_achievements.erase("completed_images_25")
	if completed_images >= 50 and locked_achievements.has("completed_images_50"):
		alert("Halfway to a lot", "50 images completed!")
		locked_achievements.erase("completed_images_50")
	if completed_images >= 69 and locked_achievements.has("completed_images_69"):
		alert("nice", "69 images completed!")
		locked_achievements.erase("completed_images_69")
	if completed_images >= 75 and locked_achievements.has("completed_images_75"):
		alert("Nearly there...", "75 images completed!")
		locked_achievements.erase("completed_images_75")
	if completed_images >= 100 and locked_achievements.has("completed_images_100"):
		alert("Triple digits!!!!!!", "100 images completed!")
		locked_achievements.erase("completed_images_100")
	if completed_images >= 250 and locked_achievements.has("completed_images_250"):
		alert("Running out of names...", "250 images completed!")
		locked_achievements.erase("completed_images_250")
	if completed_images >= 200 and locked_achievements.has("completed_images_500"):
		alert("Famous", "500 images completed!")
		locked_achievements.erase("completed_images_500")
	if completed_images >= 1000 and locked_achievements.has("completed_images_1000"):
		alert("Unstoppable", "1000 images completed!")
		locked_achievements.erase("completed_images_1000")
	if completed_images >= 2000 and locked_achievements.has("completed_images_2000"):
		alert("Lots of pictures", "2000 images completed!")
		locked_achievements.erase("completed_images_2000")
	if completed_images >= 3000 and locked_achievements.has("completed_images_3000"):
		alert("I hope these aren't all nsfw...", "3000 images completed!")
		locked_achievements.erase("completed_images_3000")
	if completed_images >= 4000 and locked_achievements.has("completed_images_4000"):
		alert("4kkkkkkk", "4000 images completed!")
		locked_achievements.erase("completed_images_4000")
	if completed_images >= 5000 and locked_achievements.has("completed_images_5000"):
		alert("half way to 5 digits", "5000 images completed!")
		locked_achievements.erase("completed_images_5000")
	if completed_images >= 6000 and locked_achievements.has("completed_images_6000"):
		alert("add 969 and you have double nice", "6000 images completed!")
		locked_achievements.erase("completed_images_6000")
	if completed_images >= 7000 and locked_achievements.has("completed_images_7000"):
		alert("nana thousand", "7000 images completed!")
		locked_achievements.erase("completed_images_7000")
	if completed_images >= 8000 and locked_achievements.has("completed_images_8000"):
		alert("ba ling ling ling", "8000 images completed!")
		locked_achievements.erase("completed_images_8000")
	if completed_images >= 9000 and locked_achievements.has("completed_images_9000"):
		alert("nearly there", "9000 images completed!")
		locked_achievements.erase("completed_images_9000")
	if completed_images >= 10000 and locked_achievements.has("completed_images_10000"):
		alert("You might want to touch some grass.", "10000 images completed!")
		locked_achievements.erase("completed_images_10000")

func display_achievement(achievement):
	if achievement == "completed_images_1":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/1Image".show()
	elif achievement == "completed_images_5":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/5Image".show()
	elif achievement == "completed_images_10":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/10Image".show()
	elif achievement == "completed_images_25":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/25Image".show()
	elif achievement == "completed_images_50":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/50Image".show()
	elif achievement == "completed_images_69":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/69Image".show()
	elif achievement == "completed_images_75":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/75Image".show()
	elif achievement == "completed_images_100":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/100Image".show()
	elif achievement == "completed_images_250":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/250Image".show()
	elif achievement == "completed_images_500":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/500Image".show()
	elif achievement == "completed_images_1000":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/1kImage".show()
	elif achievement == "completed_images_2000":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/2kImage".show()
	elif achievement == "completed_images_3000":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/3kImage".show()
	elif achievement == "completed_images_4000":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/4kImage".show()
	elif achievement == "completed_images_5000":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/5kImage".show()
	elif achievement == "completed_images_6000":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/6kImage".show()
	elif achievement == "completed_images_7000":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/7kImage".show()
	elif achievement == "completed_images_8000":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/8kImage".show()
	elif achievement == "completed_images_9000":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/9kImage".show()
	elif achievement == "completed_images_10000":
		$"SidePanel/Panel/Achievements/VBoxContainer/ScrollContainer/FlexGridContainer/10kImage".show()


var auto_cursor_start_cost = 200
func _on_BuyAutoCursor_pressed():
	var cost = auto_cursor_start_cost
	for _i in range(0,auto_cursors):
		cost *= auto_cursor_cost_multi
	if pixels >= floor(cost):
		pixels -= floor(cost)
		auto_cursors += 1
		# Update gui buttons
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/Amount/Label.text = format_val(auto_cursors)
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/BuyAutoCursor.text = "Buy for "+format_val(floor(cost*auto_cursor_cost_multi))+" pixels"


func _on_EmpowerAutoCursor_pressed():
	var cost = 5
	for _i in range(0,auto_cursor_power):
		cost *= auto_cursor_empower_cost_multi
	if auto_cursors >= floor(cost):
		auto_cursors -= floor(cost)
		auto_cursor_power += 1
		# Update gui buttons
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/Power/Label.text = format_val(auto_cursor_power)
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/EmpowerAutoCursor.text = "Empower for "+format_val(floor(cost*auto_cursor_empower_cost_multi))+" auto cursors"
		cost = auto_cursor_start_cost
		for _i in range(0,auto_cursors):
			cost *= auto_cursor_cost_multi
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/Amount/Label.text = format_val(auto_cursors)
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/BuyAutoCursor.text = "Buy for "+format_val(floor(cost))+" pixels"



func _on_BuyICM_pressed():
	var cost = 1000
	for _i in range(0,(image_completion_multi-2)/icm_increment):
		cost *= image_completion_cost_multi
	if pixels >= floor(cost) and auto_cursors*auto_cursor_power >= regen_pixels*regen_pixel_multi:
		pixels -= floor(cost)
		image_completion_multi += icm_increment
		if regen_pixels == 0:
			regen_pixels = 1
		regen_pixels *= regen_pixel_multi
		# Update gui buttons
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/ICM/Regen/Label.text = format_val(regen_pixels)
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/ICM/Amount/Label.text = format_val(image_completion_multi) + "x"
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/ICM/BuyICM.text = "Buy for "+format_val(floor(cost*image_completion_cost_multi))+" pixels"


func _on_BuyICM2_pressed():
	if image_completion_multi <= 2:
		return
	regen_pixels /= regen_pixel_multi
	if regen_pixels == 1:
		regen_pixels = 0
	image_completion_multi -= icm_increment
	
	var cost = 309
	for _i in range(0,image_completion_multi):
		cost *= image_completion_cost_multi
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/ICM/Regen/Label.text = format_val(regen_pixels)
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/ICM/Amount/Label.text = format_val(image_completion_multi) + "x"
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/ICM/BuyICM.text = "Buy for "+format_val(floor(cost))+" pixels"
	


func _on_Prestige_pressed():
	var cost_0 = 3
	var cost_1 = 5
	var cost_2 = 25000
	var cost_3 = 50
	for _i in range(0,prestiges):
		cost_0 += 2
		cost_1 *= 1.7
		cost_2 *= 3
		cost_3 *= 1.2
	if auto_cursor_power >= cost_0 and image_completion_multi >= cost_1 and pixels >= cost_2 and auto_cursors*auto_cursor_power-regen_pixels >= cost_3:
		res += 5
		pixels_per_pixel *= 2
		prestiges += 1
		icm_increment *= 2
		pixels = start_pixels
		auto_cursors = start_auto_cursors
		auto_cursor_power = start_auto_cursor_power
		regen_pixels = start_regen_pixels
		image_completion_multi = start_image_completion_multi
		party_pixel_multi = start_party_pixel_multi
		party_pixel_multi_num = start_party_pixel_multi_num
		party_pixel_max_wait_time = start_party_pixel_max_wait_time
		party_pixel_max_wait_time_num = start_party_pixel_max_wait_time_num
		party_pixel_length = start_party_pixel_length
		glitch_pixel_multi = start_glitch_pixel_multi
		glitch_pixel_multi_num = start_glitch_pixel_multi_num
		glitch_pixel_max_wait_time = start_glitch_pixel_max_wait_time
		glitch_pixel_max_wait_time_num = start_glitch_pixel_max_wait_time_num
		glitch_pixel_length = start_glitch_pixel_length
		
		$SidePanel/Panel/Prestige/VBoxContainer/Prestige/AutoCursorPower.text = format_val(cost_0+2)+" auto cursor power"
		$SidePanel/Panel/Prestige/VBoxContainer/Prestige/ICM.text = format_val(cost_1*1.7)+" image completion multiplier"
		$SidePanel/Panel/Prestige/VBoxContainer/Prestige/Pixels.text = format_val(cost_2*3)+" pixels"
		$SidePanel/Panel/Prestige/VBoxContainer/Prestige/DIFF.text = format_val(cost_3*1.2)+" DIFF"
		
		current_party_multi = 1
		party_active = false
		$PartyTimer.stop()
		$PartyTimer.wait_time = rand_range(10, party_pixel_max_wait_time)
		$PartyLengthTiemr.wait_time = party_pixel_length
		$PartyPixel.position.y = rand_range(0,OS.get_window_size().y)
		$PartyTimer.start()

		current_glitch_multi = 1
		glitch_active = false
		$GlitchTimer.stop()
		VisualServer.set_default_clear_color(Color("0d0c17"))
		$GlitchTimer.wait_time = rand_range(10, glitch_pixel_max_wait_time)
		$GlitchLengthTimer.wait_time = glitch_pixel_length
		$GlitchPixel.position.y = rand_range(0,OS.get_window_size().y)
		$GlitchTimer.start()

		
		update_ui_buttons()

func _on_PartyTimer_timeout():
	$PartyTimer.wait_time = rand_range(10, party_pixel_max_wait_time)
	$PartyLengthTiemr.wait_time = party_pixel_length
	$PartyPixel.position.y = rand_range(0,OS.get_window_size().y)
	move_party_pixel = true

func _on_GlitchTimer_timeout():
	$GlitchTimer.wait_time = rand_range(10, glitch_pixel_max_wait_time)
	$GlitchLengthTimer.wait_time = glitch_pixel_length
	$GlitchPixel.position.y = rand_range(0,OS.get_window_size().y)
	move_glitch_pixel = true

func _on_PartyLengthTiemr_timeout():
	current_party_multi = 1
	party_active = false
	VisualServer.set_default_clear_color(Color("0d0c17"))
	$PartyTimer.start()

func _on_GlitchLengthTimer_timeout():
	current_glitch_multi = 1
	glitch_active = false
	VisualServer.set_default_clear_color(Color("0d0c17"))
	$GlitchTimer.start()


func _on_PartyPixelMulti_pressed():
	var cost = 10000
	for _i in range(0,party_pixel_multi_num):
		cost *= party_pixel_multi_cost_multi
	if pixels >= floor(cost):
		pixels -= floor(cost)
		party_pixel_multi *= party_pixel_multi_multi
		party_pixel_multi_num += 1
		# Update gui buttons
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelMulti/Amount/Label.text = format_val(party_pixel_multi)+"x"
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelMulti/PartyPixelMulti.text = "Buy for "+format_val(floor(cost*party_pixel_multi_cost_multi))+" pixels"


func _on_PartyPixelLength_pressed():
	var cost = 10000
	for _i in range(0,(party_pixel_length-10)/party_pixel_length_increment):
		cost *= party_pixel_length_cost_multi
	if pixels >= floor(cost):
		pixels -= floor(cost)
		party_pixel_length += party_pixel_length_increment
		# Update gui buttons
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelLength/Amount/Label.text = format_val(party_pixel_length)+"s"
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelLength/PartyPixelLength.text = "Buy for "+format_val(floor(cost*party_pixel_length_cost_multi))+" pixels"


func _on_PartyPixelTime_pressed():
	if party_pixel_max_wait_time <= 30.0:
		party_pixel_max_wait_time = 30.0
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelTime/Amount/Label.text = format_val(party_pixel_max_wait_time)+"s"
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelTime/PartyPixelTime.text = "Maxed"
		return
	var cost = 10000
	for _i in range(0,party_pixel_max_wait_time_num):
		cost *= party_pixel_max_wait_time_cost_multi
	if pixels >= floor(cost):
		pixels -= floor(cost)
		party_pixel_max_wait_time *= party_pixel_wait_time_multi
		party_pixel_max_wait_time_num += 1
		update_ui_buttons()

func _on_GlitchPixelMulti_pressed():
	var cost = 25000
	for _i in range(0,glitch_pixel_multi_num):
		cost *= glitch_pixel_multi_cost_multi
	if pixels >= floor(cost):
		pixels -= floor(cost)
		glitch_pixel_multi *= glitch_pixel_multi_multi
		glitch_pixel_multi_num += 1
		# Update gui buttons
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelMulti/Amount/Label.text = format_val(glitch_pixel_multi)+"x"
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelMulti/GlitchPixelMulti.text = "Buy for "+format_val(floor(cost*glitch_pixel_multi_cost_multi))+" pixels"

func _on_GlitchPixelLength_pressed():
	var cost = 25000
	for _i in range(0,(glitch_pixel_length-10)/glitch_pixel_length_increment):
		cost *= glitch_pixel_length_cost_multi
	if pixels >= floor(cost):
		pixels -= floor(cost)
		glitch_pixel_length += glitch_pixel_length_increment
		# Update gui buttons
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelLength/Amount/Label.text = format_val(glitch_pixel_length)+"s"
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelLength/GlitchPixelLength.text = "Buy for "+format_val(floor(cost*glitch_pixel_length_cost_multi))+" pixels"

func _on_GlitchPixelTime_pressed():
	if glitch_pixel_max_wait_time <= 30.0:
		glitch_pixel_max_wait_time = 30.0
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelTime/Amount/Label.text = format_val(glitch_pixel_max_wait_time)+"s"
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelTime/GlitchPixelTime.text = "Maxed"
		return
	var cost = 25000
	for _i in range(0,glitch_pixel_max_wait_time_num):
		cost *= glitch_pixel_max_wait_time_cost_multi
	if pixels >= floor(cost):
		pixels -= floor(cost)
		glitch_pixel_max_wait_time *= glitch_pixel_wait_time_multi
		glitch_pixel_max_wait_time_num += 1
		update_ui_buttons()
	
func update_ui_buttons():
	# Set ui button stuff
	# WIP buy multiple
#	var cost = 100
#	var temp_cost = cost
#	for i in buy_amount-1:
#		for _i in range(0,auto_cursors+i):
#			temp_cost *= auto_cursor_cost_multi
#		cost += floor(temp_cost)
#		temp_cost = 100
	var cost = auto_cursor_start_cost
	for _i in range(0,auto_cursors):
		cost *= auto_cursor_cost_multi
	if cost <= pixels:
		if $SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/BuyAutoCursor.disabled:
			$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/BuyAutoCursor.disabled = false
	else:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/BuyAutoCursor.disabled = true
		process_buy = false
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/Amount/Label.text = format_val(auto_cursors)
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/BuyAutoCursor.text = "Buy for "+format_val(floor(cost))+" pixels"
	
	cost = 5
	for _i in range(0,auto_cursor_power):
		cost *= auto_cursor_empower_cost_multi
	if cost <= auto_cursors:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/EmpowerAutoCursor.disabled = false
	else:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/EmpowerAutoCursor.disabled = true
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/Power/Label.text = format_val(auto_cursor_power)
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/EmpowerAutoCursor.text = "Empower for "+format_val(floor(cost))+" auto cursors"

	cost = 1000
	for _i in range(0,(image_completion_multi-2)/icm_increment):
		cost *= image_completion_cost_multi
	if cost <= pixels:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/ICM/BuyICM.disabled = false
	else:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/ICM/BuyICM.disabled = true
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/ICM/Regen/Label.text = format_val(regen_pixels)
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/ICM/Amount/Label.text = format_val(image_completion_multi) + "x"
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/ICM/BuyICM.text = "Buy for "+format_val(floor(cost))+" pixels"
	
	cost = 10000
	for _i in range(0,party_pixel_max_wait_time_num):
		cost *= party_pixel_max_wait_time_cost_multi
	# Update gui buttons
	if cost <= pixels:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelTime/PartyPixelTime.disabled = false
	else:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelTime/PartyPixelTime.disabled = true
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelTime/Amount/Label.text = format_val(party_pixel_max_wait_time)+"s"
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelTime/PartyPixelTime.text = "Buy for "+format_val(floor(cost))+" pixels"
	if party_pixel_max_wait_time <= 30.0:
		party_pixel_max_wait_time = 30.0
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelTime/Amount/Label.text = format_val(party_pixel_max_wait_time)+"s"
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelTime/PartyPixelTime.text = "Maxed"
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelTime/PartyPixelTime.disabled = true
	
	cost = 10000
	for _i in range(0,((party_pixel_length-10)/party_pixel_length_increment)):
		cost *= party_pixel_length_cost_multi
	if cost <= pixels:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelLength/PartyPixelLength.disabled = false
	else:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelLength/PartyPixelLength.disabled = true
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelLength/Amount/Label.text = format_val(party_pixel_length)+"s"
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelLength/PartyPixelLength.text = "Buy for "+format_val(floor(cost))+" pixels"

	cost = 10000
	for _i in range(0,party_pixel_multi_num):
		cost *= party_pixel_multi_cost_multi
	if cost <= pixels:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelMulti/PartyPixelMulti.disabled = false
	else:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelMulti/PartyPixelMulti.disabled = true
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelMulti/Amount/Label.text = format_val(party_pixel_multi)+"x"
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/PartyPixelMulti/PartyPixelMulti.text = "Buy for "+format_val(floor(cost))+" pixels"

	cost = 25000
	for _i in range(0,glitch_pixel_max_wait_time_num):
		cost *= glitch_pixel_max_wait_time_cost_multi
	# Update gui buttons
	if cost <= pixels:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelTime/GlitchPixelTime.disabled = false
	else:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelTime/GlitchPixelTime.disabled = true
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelTime/Amount/Label.text = format_val(glitch_pixel_max_wait_time)+"s"
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelTime/GlitchPixelTime.text = "Buy for "+format_val(floor(cost))+" pixels"
	if glitch_pixel_max_wait_time <= 30.0:
		glitch_pixel_max_wait_time = 30.0
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelTime/Amount/Label.text = format_val(glitch_pixel_max_wait_time)+"s"
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelTime/GlitchPixelTime.text = "Maxed"
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelTime/GlitchPixelTime.disabled = true
	
	cost = 25000
	for _i in range(0,((glitch_pixel_length-10)/glitch_pixel_length_increment)):
		cost *= glitch_pixel_length_cost_multi
	if cost <= pixels:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelLength/GlitchPixelLength.disabled = false
	else:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelLength/GlitchPixelLength.disabled = true
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelLength/Amount/Label.text = format_val(glitch_pixel_length)+"s"
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelLength/GlitchPixelLength.text = "Buy for "+format_val(floor(cost))+" pixels"

	cost = 25000
	for _i in range(0,glitch_pixel_multi_num):
		cost *= glitch_pixel_multi_cost_multi
	if cost <= pixels:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelMulti/GlitchPixelMulti.disabled = false
	else:
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelMulti/GlitchPixelMulti.disabled = true
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelMulti/Amount/Label.text = format_val(glitch_pixel_multi)+"x"
	$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/GlitchPixelMulti/GlitchPixelMulti.text = "Buy for "+format_val(floor(cost))+" pixels"

	
	var cost_0 = 3
	var cost_1 = 5
	var cost_2 = 25000
	var cost_3 = 50
	for _i in range(0,prestiges):
		cost_0 += 2
		cost_1 *= 1.7
		cost_2 *= 3
		cost_3 *= 1.2
	if auto_cursor_power >= cost_0 and image_completion_multi >= cost_1 and pixels >= cost_2 and auto_cursors*auto_cursor_power-regen_pixels >= cost_3:
		$SidePanel/Panel/Prestige/VBoxContainer/Prestige.disabled = false
	else:
		$SidePanel/Panel/Prestige/VBoxContainer/Prestige.disabled = true
	$SidePanel/Panel/Prestige/VBoxContainer/Prestige/AutoCursorPower.text = format_val(cost_0)+" auto cursor power"
	$SidePanel/Panel/Prestige/VBoxContainer/Prestige/ICM.text = format_val(cost_1)+" image completion multiplier"
	$SidePanel/Panel/Prestige/VBoxContainer/Prestige/Pixels.text = format_val(cost_2)+" pixels"
	$SidePanel/Panel/Prestige/VBoxContainer/Prestige/DIFF.text = format_val(cost_3)+" DIFF"

func update_stats():
	time_played += 1
	$SidePanel/Panel/Stats/ScrollContainer/RichTextLabel.bbcode_text = "Images Completed: "+format_val(completed_images)+"\nLifetime pixels: "+format_val(lifetime_pixels)+"\nTime played: "+format_val(time_played)+" seconds\n"+"[url="+image_link+"]Current Image (click me)[/url]\n"+"More coming soon...(suggest ideas please)"

func _on_Export_pressed():
	var exportdata = Marshalls.utf8_to_base64(to_json({
		"pixels": pixels,
		"pixels_per_pixel": pixels_per_pixel,
		"res": res,
		"auto_cursors": auto_cursors,
		"auto_cursor_power": auto_cursor_power,
		"regen_pixels": regen_pixels,
		"image_completion_multi": image_completion_multi,
		"icm_increment": icm_increment,
		"completed_images": completed_images,
		"locked_achievements": locked_achievements,
		"prestiges": prestiges,
		"party_pixel_multi": party_pixel_multi,
		"party_pixel_multi_num": party_pixel_multi_num,
		"party_pixel_max_wait_time": party_pixel_max_wait_time,
		"party_pixel_max_wait_time_num": party_pixel_max_wait_time_num,
		"party_pixel_length": party_pixel_length,
		"glitch_pixel_multi": glitch_pixel_multi,
		"glitch_pixel_multi_num": glitch_pixel_multi_num,
		"glitch_pixel_max_wait_time": glitch_pixel_max_wait_time,
		"glitch_pixel_max_wait_time_num": glitch_pixel_max_wait_time_num,
		"glitch_pixel_length": glitch_pixel_length,
		"lifetime_pixels": lifetime_pixels,
		"time_played": time_played,
		"auto_cursor_update_speed": auto_cursor_update_speed,
		"game_version": game_version,
		"spawn_pattern": spawn_pattern,
		"hover_to_uncover": hover_to_uncover,
		"save_time": OS.get_system_time_msecs()
	}))
	$SidePanel/Panel/Menu/VBoxContainer/Exportbox.text = exportdata


func _on_Import_pressed():
	var save_data = parse_json(Marshalls.base64_to_utf8($SidePanel/Panel/Menu/VBoxContainer/Importbox.text))
	pixels = save_data["pixels"]
	pixels_per_pixel = save_data["pixels_per_pixel"]
	res = save_data["res"]
	auto_cursors = save_data["auto_cursors"]
	auto_cursor_power = save_data["auto_cursor_power"]
	regen_pixels = save_data["regen_pixels"]
	image_completion_multi = save_data["image_completion_multi"]
	icm_increment = save_data["icm_increment"]
	completed_images = save_data["completed_images"]
	if save_data.has("locked_achivements"):
		locked_achievements = save_data["locked_achivements"]
	else:
		locked_achievements = save_data["locked_achievements"]
	prestiges = save_data["prestiges"]
	party_pixel_multi = save_data["party_pixel_multi"]
	party_pixel_multi_num = save_data["party_pixel_multi_num"]
	party_pixel_max_wait_time = save_data["party_pixel_max_wait_time"]
	party_pixel_max_wait_time_num = save_data["party_pixel_max_wait_time_num"]
	party_pixel_length = save_data["party_pixel_length"]
	glitch_pixel_multi = save_data["glitch_pixel_multi"]
	glitch_pixel_multi_num = save_data["glitch_pixel_multi_num"]
	glitch_pixel_max_wait_time = save_data["glitch_pixel_max_wait_time"]
	glitch_pixel_max_wait_time_num = save_data["glitch_pixel_max_wait_time_num"]
	glitch_pixel_length = save_data["glitch_pixel_length"]
	lifetime_pixels = save_data["lifetime_pixels"]
	time_played = save_data["time_played"]
	if save_data.has("auto_cursor_update_speed"):
		auto_cursor_update_speed = save_data["auto_cursor_update_speed"]
	else:
		auto_cursor_update_speed = 1
	if save_data["game_version"] == "0.0.2":
		spawn_pattern = 0
	else:
		spawn_pattern = save_data["spawn_pattern"]
	if save_data.has("hover_to_uncover"):
		hover_to_uncover = save_data["hover_to_uncover"]
	else:
		hover_to_uncover = false
	save_data()


var hard_reset_conf = false
func _on_HardReset_pressed():
	if hard_reset_conf:
		lifetime_pixels = 0
		time_played = 0
		pixels = start_pixels
		pixels_per_pixel = start_pixels_per_pixel
		res = start_res
		auto_cursors = start_auto_cursors
		auto_cursor_power = start_auto_cursor_power
		regen_pixels = start_regen_pixels
		image_completion_multi = start_image_completion_multi
		icm_increment = start_icm_increment
		completed_images = start_completed_images
		locked_achievements = start_locked_achievements
		prestiges = start_prestiges
		party_pixel_multi = start_party_pixel_multi
		party_pixel_multi_num = start_party_pixel_multi_num
		party_pixel_max_wait_time = start_party_pixel_max_wait_time
		party_pixel_max_wait_time_num = start_party_pixel_max_wait_time_num
		party_pixel_length = start_party_pixel_length
		glitch_pixel_multi = start_glitch_pixel_multi
		glitch_pixel_multi_num = start_glitch_pixel_multi_num
		glitch_pixel_max_wait_time = start_glitch_pixel_max_wait_time
		glitch_pixel_max_wait_time_num = start_glitch_pixel_max_wait_time
		glitch_pixel_length = start_glitch_pixel_length
		# unsaved data
		auto_cursor_cost_multi = 1.07
		auto_cursor_power_increment = 1
		auto_cursor_empower_cost_multi = 1.25
		auto_cursor_empower_power = 1
		image_completion_cost_multi = 1.9
		regen_pixel_multi = 2
		current_party_multi = 1
		current_glitch_multi = 1
		move_party_pixel = false
		party_active = false
		move_glitch_pixel = false
		glitch_active = false
		party_pixel_multi_cost_multi = 2.2
		party_pixel_multi_multi = 2
		party_pixel_length_cost_multi = 1.6
		party_pixel_length_increment = 5
		party_pixel_max_wait_time_cost_multi = 2.6
		party_pixel_wait_time_multi = 0.95
		glitch_pixel_multi_cost_multi = 2.3
		glitch_pixel_multi_multi = 2
		glitch_pixel_length_cost_multi = 1.7
		glitch_pixel_length_increment = 5
		glitch_pixel_max_wait_time_cost_multi = 2.7
		glitch_pixel_wait_time_multi = 0.95
		past_images = []
		page = 1
		achievement_boost = 1.00
		buy_amount = 10
		auto_cursor_update_speed = 1
		save_data()
		load_data()
		$AutoCursorTimer.stop()
		$AutoCursorTimer.wait_time = auto_cursor_update_speed
		$SidePanel/Panel/Menu/VBoxContainer/HBoxContainer/LineEdit.text = str(auto_cursor_update_speed)
		$AutoCursorTimer.start()
		new_image()
		# Party Pixel
		$PartyTimer.stop()
		$PartyTimer.wait_time = rand_range(10, party_pixel_max_wait_time)
		$PartyTimer.start()
		$PartyPixel.position.x = -80
		# Glitch Pixel
		$GlitchTimer.stop()
		$GlitchTimer.wait_time = rand_range(10, glitch_pixel_max_wait_time)
		$GlitchTimer.start()
		$GlitchPixel.position.x = -80
		update_ui_buttons()
	else:
		$SidePanel/Panel/Menu/VBoxContainer/HardReset.text = "Click again to confirm."
		hard_reset_conf = true
		$HardResetTimer.start()

func _on_HardResetTimer_timeout():
	hard_reset_conf = false
	$SidePanel/Panel/Menu/VBoxContainer/HardReset.text = "Hard Reset"


var process_buy = false
func _on_BuyAutoCursor_button_down():
	$QuickBuyTimer.start()
	process_buy = true

func _on_QuickBuyTimer_timeout():
	while process_buy == true:
		if $QuickBuySpeedTimer.is_stopped():
			$QuickBuySpeedTimer.start()
		yield(get_tree(), "idle_frame")
		
func _on_QuickBuySpeedTimer_timeout():
	var cost = auto_cursor_start_cost
	for _i in range(0,auto_cursors):
		cost *= auto_cursor_cost_multi
	if pixels >= floor(cost):
		pixels -= floor(cost)
		auto_cursors += 1
		# Update gui buttons
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/Amount/Label.text = format_val(auto_cursors)
		$SidePanel/Panel/Upgrades/ScrollContainer/Upgrades/AutoCursor/BuyAutoCursor.text = "Buy for "+format_val(floor(cost*auto_cursor_cost_multi))+" pixels"


func _on_BuyAutoCursor_button_up():
	process_buy = false
	$QuickBuyTimer.stop()


func _on_LineEdit_text_changed(new_text):
	if new_text.is_valid_float():
		if float(new_text) == 0 or float(new_text) > 100:
			return
		auto_cursor_update_speed = float(new_text)
		$AutoCursorTimer.stop()
		$AutoCursorTimer.wait_time = auto_cursor_update_speed
		$AutoCursorTimer.start()


func _on_OptionButton_item_selected(index):
	spawn_pattern = index


func _on_CheckBox_toggled(button_pressed):
	hover_to_uncover = $SidePanel/Panel/Menu/VBoxContainer/HBoxContainer3/CheckBox.is_pressed()


func _on_UIUpdate_timeout():
	update_ui_buttons()


func _on_Search_text_entered(new_text):
	$Picture/Search.focus_mode = Control.FOCUS_NONE
	$Picture/Search.focus_mode = Control.FOCUS_CLICK
