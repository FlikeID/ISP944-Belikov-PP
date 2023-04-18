extends PanelContainer

class_name Element

@onready var main_lable: Label = %main_lable
@onready var desc_lable: RichTextLabel = %desc_lable
@onready var image: TextureRect = %image
var data: Dictionary = {}

func set_main_lable(text: String):
	main_lable.text = text

func set_desc_lable(text: String):
	desc_lable.text = text


func set_image(bytes: PackedByteArray, metadata: Dictionary):
	var data = metadata
	data['data'] = bytes
	var img = Image.new()
	img.data = data
	var imgtex = ImageTexture.create_from_image(img)
	image.texture = imgtex


	
func set_data(key: String, value):
	self.data[key] = value

func greenlight():
	self_modulate.r = 0
	self_modulate.g = 5
	self_modulate.b = 0

func add_button(text: String, action: String, function: Callable):
	var button: PackedScene = preload("res://interface/element/button.tscn")
	var button_instance: Action_button = button.instantiate()
	%button_container.add_child(button_instance)
	button_instance.text = text
	button_instance.action = action
	button_instance.parent = self
	button_instance.link_signal(function)
