extends MarginContainer
var db = Global.db

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in %elements_list.get_children():
		node.queue_free()
	
	# Open database
	if (!db.open_db()):
		print("Cannot open database.");
		return;
	
	var query = "";
	var result = null;
	
	# Fetch rows
	query = "SELECT * FROM `units`;"
	db.query(query);
	result = db.query_result
	var element: PackedScene = preload("res://interface/element/element.tscn")
	for row in result:
		var unit: Unit = Unit.new_from_dict(row)
		
		
		var new_element: Element = element.instantiate()
		%elements_list.add_child(new_element)
		
		new_element.set_data("unit", unit)
		new_element.set_main_lable(unit.name)
		var desc_text = ""
		new_element.set_desc_lable("")
		if not 'error' in unit.image_metadata:
			new_element.set_image(unit.image, unit.image_metadata)
		new_element.add_button("Open", 'open', self._unit)
		new_element.add_button("Delete", 'delete', self._unit)
		
		
		
	var new_element: Element = element.instantiate()
	%elements_list.add_child(new_element)
	new_element.set_main_lable("Add new units")
	new_element.set_desc_lable("Press \"Add\" button, to add new units")
	new_element.add_button("Add", 'add', self._open_add_unit_menu)

func _unit(element: Element, action: String):
	if not "unit" in element.data:
		assert(true, "ERROR: not units_element")
		return
	var unit: Unit = element.data['unit']
	match action:
		'open':
			self._open_unit(unit)
		'delete':
			self._delete_unit(element, unit)
	
func _open_unit(unit: Unit):
	Global.selected_unit = unit
	get_tree().change_scene_to_file("res://interface/staffers_menu/staffers_menu.tscn")
	queue_free()

func _delete_unit(element: Element, unit: Unit):
	unit.delete()
	element.queue_free()

func _open_add_unit_menu(element: Element, action: String):
	get_tree().change_scene_to_file("res://interface/add_unit_menu/add_unit_menu.tscn")
	queue_free()


func _on_back_pressed():
	if Global.user.is_admin == true:
		get_tree().change_scene_to_file("res://interface/admin_menu/admin_menu.tscn")
		queue_free()
		return
	get_tree().change_scene_to_file("res://interface/login_menu/login_menu.tscn")
	queue_free()
	pass # Replace with function body.
