extends Node

const GAME_VERSION = "alpha-v0.1.0"

var tutorial_stage = 0

var money = Num.new("0")
var pixels = Num.new("0")

var pixels_per_pixel = Num.new("1")

func _ready():
	var save_game = File.new()
	
	if not save_game.file_exists("user://save.file"):
		save_data()
		
	save_game.open("user://save.file", File.READ)
	var data = parse_json(save_game.get_line())
	save_game.close()
	
	load_data(data)

func save_data():
	var save_game = File.new()
	save_game.open("user://save.file", File.WRITE)
	save_game.store_line(to_json({
		"tutorial_stage": tutorial_stage,
		
		"money": money.get_raw(),
		"pixels": pixels.get_raw(),
		
		"pixels_per_pixel": pixels_per_pixel.get_raw(),
		
		"game_version": GAME_VERSION,
		"save_time": OS.get_system_time_msecs()
	}))
	save_game.close()
	return true
	
func load_data(data):
	if data["game_version"] == "0.0.1" or data["game_version"] == "0.0.2" or data["game_version"] == "0.0.3":
		return false
	# Load data
	tutorial_stage = data["tutorial_stage"]
	
	money.load_raw(data["money"])
	pixels.load_raw(data["pixels"])
	
	pixels_per_pixel.load_raw(data["pixels_per_pixel"])
	# calculate offline production
	
	save_data()
	return true
	
func get_base_64_data():
	var save_game = File.new()
	
	if not save_game.file_exists("user://save.file"):
		save_data()
		
	save_game.open("user://save.file", File.READ)
	var data = save_game.get_line()
	save_game.close()
	
	return Marshalls.utf8_to_base64(data)
	
func load_base_64_data(data):
	return load_data(parse_json(Marshalls.base64_to_utf8(data)))
