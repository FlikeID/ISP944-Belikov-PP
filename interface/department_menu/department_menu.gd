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
	query = "SELECT * FROM `departament`;"
	db.query(query);
	result = db.query_result
	var element: PackedScene = preload("res://interface/element/element.tscn")
	for row in result:
		var departament: Departament = Departament.new_from_dict(row)
		
		
		var new_element: Element = element.instantiate()
		%elements_list.add_child(new_element)
		
		new_element.set_data("departament", departament)
		new_element.set_main_lable(departament.name)
		var desc_text = ""
		if departament.address != null:
			desc_text+= departament.address+" | "
		desc_text+= str(departament.count)+" человек"
		new_element.set_desc_lable(desc_text)
		if not 'error' in departament.image_metadata:
			new_element.set_image(departament.image, departament.image_metadata)
		new_element.add_button("Open", 'open', self._open_dep)
		
		
		
	var new_element: Element = element.instantiate()
	%elements_list.add_child(new_element)
	new_element.set_main_lable("Add new departament")
	new_element.set_desc_lable("Press \"Add\" button, to add new departament")
	new_element.add_button("Add", 'add', self._open_add_dep_menu)
	
	
func _open_dep(element: Element, action: String):
	if not "departament" in element.data:
		assert(true, "ERROR: not departament_element")
		return
	Global.selected_departament = element.data['departament']
	get_tree().change_scene_to_file("res://interface/purchase_menu/purchase_menu.tscn")
	queue_free()

func _open_add_dep_menu(element: Element, action: String):
	get_tree().change_scene_to_file("res://interface/add_departament_menu/add_departament_menu.tscn")
	queue_free()


func _on_back_pressed():
	if Global.user.is_admin == true:
		get_tree().change_scene_to_file("res://interface/admin_menu/admin_menu.tscn")
		queue_free()
		return
	get_tree().change_scene_to_file("res://interface/login_menu/login_menu.tscn")
	queue_free()
	pass # Replace with function body.
