extends CenterContainer



export var node_image_texture_: NodePath
onready var image_texture: = get_node(node_image_texture_) as Node

export var node_image_overlay_: NodePath
onready var image_overlay: = get_node(node_image_overlay_) as Node

export var node_image_container_: NodePath
onready var image_container: = get_node(node_image_container_) as Node

export var node_new_image_timer_: NodePath
onready var new_image_timer: = get_node(node_new_image_timer_) as Node

export var node_new_image_button_: NodePath
onready var new_image_button: = get_node(node_new_image_button_) as Node

export var node_search_bar_: NodePath
onready var search_bar: = get_node(node_search_bar_) as Node

export var node_api_selection_: NodePath
onready var api_selection: = get_node(node_api_selection_) as Node

export var node_http_request_one_: NodePath
onready var http_request_one: = get_node(node_http_request_one_) as Node

export var node_http_request_two_: NodePath
onready var http_request_two: = get_node(node_http_request_two_) as Node

var image = null
var tex = null
var unrevealed_pixels = []
var url = null
var data = null
var image_type = null
var image_link = ""
var old_search_term = ""
var past_images = []
var page = 1
var res = 10
var scale = 1
var width = res
var height = res
var old_selected_api = -1

func _ready():
	api_selection.add_item("Imgur")
	api_selection.add_item("The Cat API")
	
func _process(_delta):
	image_container.rect_scale.x = scale
	image_container.rect_scale.y = scale

func new_image():
	new_image_timer.start()
	
func _on_NewImageTimer_timeout():
	image_texture.hide()
	image_overlay.hide()
	new_image_button.disabled = true
	var selected_api = api_selection.get_selected_id()
	
	if selected_api == 0: # IMGUR
		if old_selected_api != 0 or data == null or data["data"].size() == 0 or old_search_term != search_bar.text:
			old_selected_api = 0
			old_search_term = search_bar.text
			if search_bar.text == "" or search_bar.text == "Search...":
				url = 'https://api.imgur.com/3/gallery/random/random/'+str(page)
				page += 1
				if page >= 10: page = 1
			else:
				url = 'https://api.imgur.com/3/gallery/search/time/top/'+str(page)+'?q='+search_bar.text
				page += 1
				if page >= 10:
					page = 1
			http_request_one.request(url,IMGUR_HEADERS,true,HTTPClient.METHOD_GET)
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
					http_request_two.request(image_link)
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
					http_request_two.request(image_link)
					return
				else:
					print("Skipped, incompatible image type.")
					new_image()
					return
	elif selected_api == 1: # THE CAT API
		if old_selected_api != 1 or data == null or data.size() == 0:
			old_selected_api = 1
			# Request new image
			url = 'https://api.thecatapi.com/v1/images/search?mime_types=jpg'
			http_request_one.request(url,CAT_HEADERS,true,HTTPClient.METHOD_GET)
			print("Requesting new image from the cat api...")
		else:
			print("Displaying image...")
			image_type = "image/jpeg"
			image_link = data[0]["url"]
			data = null
			# Check if image has been seen recently
			if image_link in past_images:
					new_image()
					return
			else:
				past_images.append(image_link)
				if past_images.size() >= 10:
					past_images.pop_front()
			# Display image
			image = Image.new()
			http_request_two.request(image_link)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if int(response_code) != 200:
		var error = "Error code 200. Unknown."
		if response_code == 400:
			error = "Error code 400. A parameter is missing."
		elif response_code == 401:
			error = "Error code 401. Probably not authorized."
		elif response_code == 403:
			error = "Error code 403. Probably not authorized."
		elif response_code == 404:
			error = "Error code 404. Image doesn't exist."
		elif response_code == 429:
			error = "Error code 429. Ratelimit :/"
		elif response_code == 500:
			error = "Error code 500. Imgur's api is probably broken. Try again later."
		push_error(error)
	else:
		# Convert response to dictionary
		data = JSON.parse(body.get_string_from_utf8()).result
		print("Got image(s)...")
		new_image()

func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
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
	image_texture.rect_min_size = Vector2(width,height)
	image_texture.texture = tex
	image_texture.visible = false
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
	image_overlay.rect_min_size = Vector2(width,height)
	image_overlay.texture = temp_tex
	image_overlay.visible = false
	# Rescale container
	scale = ceil(float(500)/res)
	image_container.rect_scale.x = scale
	image_container.rect_scale.y = scale
	image_texture.visible = true
	#image_overlay.visible = true
	unrevealed_pixels = []
	for y in range(0,height):
		for x in range(0,width):
			unrevealed_pixels.append(Vector2(x,y))
	new_image_button.disabled = false
#	$Bottom/RichTextLabel.bbcode_text = "                           Game by 7w1\n[url="+image_link+"]Current Image[/url]  Concept by 1WithBacon"
	print("Image displayed successfully.")


func _on_New_Image_pressed():
	new_image()
