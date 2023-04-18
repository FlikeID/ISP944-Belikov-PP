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
	query = "SELECT * FROM `staffers` WHERE `unit` = {id};"
	query = query.format(Global.selected_unit.dict)
	print(query)
	db.query(query);
	result = db.query_result
	var element: PackedScene = preload("res://interface/element/element.tscn")
	for row in result:
		var staffer: Staffer = Staffer.new_from_dict(row)
		
		
		var new_element: Element = element.instantiate()
		%elements_list.add_child(new_element)
		
		new_element.set_data("staffer", staffer)
		new_element.set_main_lable(staffer.fullname)
		var desc_text = ""
		new_element.set_desc_lable("")
		if not 'error' in staffer.image_metadata:
			new_element.set_image(staffer.image, staffer.image_metadata)
		new_element.add_button("Open keys list", 'open', self._open_key_list)
		new_element.add_button("Add key", 'open', self._open_add_key)
	
	
	
func _staffer(element: Element, action: String):
	if not "staffer" in element.data:
		assert(true, "ERROR: not staffer_element")
		return
	var staffer: Staffer = element.data['staffer']
	match action:
		'open':
			self._open_key_list(staffer)
		'delete':
			self._delete_staffer(element, staffer)
	
func _open_key_list(staffer: Staffer):
	Global.selected_staffer = staffer
	get_tree().change_scene_to_file("res://interface/keys_menu/keys_menu.tscn")
	queue_free()

func _delete_staffer(element: Element, staffer: Staffer):
	staffer.delete()
	element.queue_free()

func _open_add_unit_menu(element: Element, action: String):
	get_tree().change_scene_to_file("res://interface/add_unit_menu/add_unit_menu.tscn")
	queue_free()

func _open_add_key(element: Element, action: String):
	if not "staffer" in element.data:
		assert(true, "ERROR: not staffer_element")
		return
	Global.selected_staffer = element.data['staffer']
	get_tree().change_scene_to_file("res://interface/products_menu/products_menu.tscn")
	queue_free()

func _open_add_staffer_menu(element: Element, action: String):
	get_tree().change_scene_to_file("res://interface/add_staffer_menu/add_staffer_menu.tscn")
	queue_free()


func _on_back_pressed():
	if Global.user.is_admin == true:
		get_tree().change_scene_to_file("res://interface/admin_menu/admin_menu.tscn")
		queue_free()
		return
	get_tree().change_scene_to_file("res://interface/units_menu/units_menu.tscn")
	queue_free()
	pass # Replace with function body.
