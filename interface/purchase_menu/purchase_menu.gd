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
	query = "SELECT * FROM `purchase` where `id_departament` = {id_departament} and `status` = 0;"
	query = query.format({
		'id_departament': Global.selected_departament.id
	})
	db.query(query);
	result = db.query_result
	var element: PackedScene = preload("res://interface/element/element.tscn")
	for row in result:
		var purchase: Purchase = Purchase.new_from_dict(row)
		
		
		var new_element: Element = element.instantiate()
		%elements_list.add_child(new_element)
		
		new_element.set_data("purchase", purchase)
		new_element.set_main_lable(purchase.chancellery.name)
		new_element.set_desc_lable(purchase.summa_description)
		if not 'error' in purchase.chancellery.image_metadata:
			new_element.set_image(purchase.chancellery.image, purchase.chancellery.image_metadata)
		new_element.add_button("Delete", 'delete', self._del_pur)
		
		
	var new_element: Element = element.instantiate()
	%elements_list.add_child(new_element)
	new_element.set_main_lable("Add new purchase")
	new_element.set_desc_lable("Press \"Add\" button, to add new purchase")
	new_element.add_button("Add", 'add', self._open_add_pur_menu)
	
func _del_pur(element: Element, action: String):
	if not "purchase" in element.data:
		assert(true, "ERROR: not purchase_element")
		return
	var purchase: Purchase = element.data["purchase"]
	purchase.delete()
	element.queue_free()
	

func _open_add_pur_menu(element: Element, action: String):
	get_tree().change_scene_to_file("res://interface/add_purchase_menu/add_purchase_menu.tscn")
	queue_free()


func _on_back_pressed():
	get_tree().change_scene_to_file("res://interface/department_menu/department_menu.tscn")
	queue_free()
	pass # Replace with function body.
