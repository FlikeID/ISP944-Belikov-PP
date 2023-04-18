extends MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in %elements_list.get_children():
		node.queue_free()
	
	# Open database
	if (!Global.db.open_db()):
		print("Cannot open database.");
		return;	
	
	if Global.selected_product != null:
		_keys()
	else:
		_purchase()

func _keys():
	
	var query = "";
	var result = null;
	
	# Fetch rows
	query = "SELECT * FROM `keys` WHERE `product` = {id};"
	query = query.format(Global.selected_product.dict)
	Global.db.query(query);
	result = Global.db.query_result
	var element: PackedScene = preload("res://interface/element/element.tscn")
	for row in result:
		
		var key: Key = Key.new_from_dict(row)
		
		
		var new_element: Element = element.instantiate()
		%elements_list.add_child(new_element)
		
		new_element.set_data("key", key)
		new_element.set_main_lable(key.key)
		new_element.set_desc_lable("")
		new_element.add_button("Delete", 'copy', self._copy_key)
		
		
		
	var new_element: Element = element.instantiate()
	%elements_list.add_child(new_element)
	new_element.set_main_lable("Add new keys")
	new_element.set_desc_lable("Press \"Add\" button, to add new keys")
	new_element.add_button("Add", 'add', self._add_key)

func _purchase():

	var query = "";
	var result = null;
	
	# Fetch rows
	query = "SELECT * FROM `purchase` WHERE `staffer_id` = {id};"
	query = query.format(Global.selected_staffer.dict)
	Global.db.query(query);
	result = Global.db.query_result
	var element: PackedScene = preload("res://interface/element/element.tscn")
	for row in result:
		
		var key: Key = Key.get_key(row['key_id'])
		
		
		var new_element: Element = element.instantiate()
		%elements_list.add_child(new_element)
		
		new_element.set_data("key", key)
		new_element.set_main_lable(key.key)
		new_element.set_desc_lable("")
		new_element.add_button("Copy", 'copy', self._copy_key)
		
		
		
	var new_element: Element = element.instantiate()
	%elements_list.add_child(new_element)
	new_element.set_main_lable("Add new keys")
	new_element.set_desc_lable("Press \"Add\" button, to add new keys")
	new_element.add_button("Add", 'add', self._add_key)
	
	
func _copy_key(element: Element, action: String):
	if not "key" in element.data:
		assert(true, "ERROR: not staffer_element")
		return
	var key: Key = element.data["key"]
	DisplayServer.clipboard_set(key.key)


func _add_key(element: Element, action: String):
	get_tree().change_scene_to_file("res://interface/products_menu/products_menu.tscn")
	queue_free()
	
func _on_back_pressed():
	if Global.selected_product != null:
		get_tree().change_scene_to_file("res://interface/products_menu/products_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://interface/staffers_menu/staffers_menu.tscn")
	queue_free()
	pass # Replace with function body.
