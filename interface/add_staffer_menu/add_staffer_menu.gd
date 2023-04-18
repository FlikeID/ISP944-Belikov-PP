extends CenterContainer

@onready var dep_image: TextureRect = %dep_image
var selected_image: Dictionary

func _on_select_image_pressed():
	%FileDialog.popup_centered()


func _on_file_dialog_file_selected(path):
	var img = Image.load_from_file(path)
	selected_image = img.data
	var imgtex = ImageTexture.create_from_image(img)
	dep_image.texture = imgtex


func _on_add_pressed():
	%error_lable.visible = false
		# Open database
	if (!Global.db.open_db()):
		print("Cannot open database.");
		return;
	
	var row_array : Array = []
	var row_dict : Dictionary = Dictionary()
	if %name_input.text.is_empty():
		%error_lable.text = "Name must be set"
		%error_lable.visible = true
		return
	row_dict["name"] = %name_input.text
	
	if %surname_input.text.is_empty():
		%error_lable.text = "Surname must be set"
		%error_lable.visible = true
		return
	row_dict["surname"] = %surname_input.text
	
	row_dict["unit"] = Global.selected_unit.id
	
	if selected_image.is_empty():
		row_dict["image_metadata"] = JSON.stringify({'error': "image not set"})
	else:
		row_dict["image"] = selected_image['data']
		selected_image.erase('data')
		row_dict["image_metadata"] = JSON.stringify(selected_image)
	# Insert a new row in the table
	Global.db.insert_row("staffers", row_dict)
	row_dict.clear()
	if Global.db.error_message != "not an error":
		%error_lable.text = Global.db.error_message
		%error_lable.visible = true
	else:
		%add_menu.visible = false
		%ok_menu.visible = true
	Global.db.close_db()
	
	pass # Replace with function body.


func _on_cancel_pressed():
	if Global.user.is_admin:
		get_tree().change_scene_to_file("res://interface/admin_menu/admin_menu.tscn")
		queue_free()
		return
	get_tree().change_scene_to_file("res://interface/staffers_menu/staffers_menu.tscn")
	queue_free()
	pass # Replace with function body.


func _on_add_another_pressed():
	get_tree().change_scene_to_file("res://interface/add_unit_menu/add_unit_menu.tscn")
	queue_free()
	pass # Replace with function body.
