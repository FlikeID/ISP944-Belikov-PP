extends CenterContainer

func _on_add_pressed():
	%error_lable.visible = false
		# Open database
	if (!Global.db.open_db()):
		print("Cannot open database.");
		return;
	
	var row_array : Array = []
	var row_dict : Dictionary = Dictionary()
	if %key_input.text.is_empty():
		%error_lable.text = "Key must be set"
		%error_lable.visible = true
		return
	row_dict["key"] = %key_input.text
	
	row_dict["product"] = Global.selected_product.id
	
	# Insert a new row in the table
	Global.db.insert_row("keys", row_dict)
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
