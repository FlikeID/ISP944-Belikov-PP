extends MarginContainer
var products_pool: Array
var query_string: String = ""
var loading_status: int = 0
var scroller_pressed: bool = false
var all_count : int = 0
var wait_status : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.user.is_admin:
		var element: PackedScene = preload("res://interface/element/element.tscn")
		var new_element: Element = element.instantiate()
		%elements_list.add_child(new_element)
		
		new_element.set_main_lable("New product")
		new_element.set_desc_lable("Press \"Add\" to add new product")
		new_element.add_button("Add", 'add', self._add_product)
	
	load_data()
	
func load_data(by: String = "name", how: String = "ASC", search: String = ""):
	for node in %elements_list.get_children():
		node.queue_free()
	
	# Open database
	if (!Global.db.open_db()):
		print("Cannot open database.");
		return;
	
	var query = "";
	var result = null;
	
	# Fetch rows
	query = "SELECT * FROM `products` WHERE `name` LIKE '%{search}%' ORDER BY `{by}` {how};"
	query = query.format({
		'by': by,
		'how': how,
		'search': search.replace(' ', '%'),
	})
	
	
	query_string = query

func _process(delta):
	if wait_status > 0:
		wait_status -= 1
		%status_lable.text = "Status: Loading stoped ("+str(abs(wait_status))+")"
		return
	elif wait_status == 0:
		wait_status = -1
		_on_search_text_text_submitted("_")
		
	if scroller_pressed:
		%status_lable.text = "Status: Loading stoped"
	else:
		match loading_status:
			-1:
				if products_pool.size() != 0:
					loading_status=2
			1:
				products_pool.clear()
				%status_lable.text = "Status: Loading.."
				await load_data(Global.OrderBy[%sort_by.selected], Global.OrderHow[%sort_how.selected], %search_text.text)
			2:
				%status_lable.text = "Status: Loading..."
				await Global.db.query(query_string)
				products_pool = Global.db.query_result
				all_count = products_pool.size()
			3:
				%status_lable.text = "Status: Loading...."
				await add_element(products_pool.pop_front())
			4:
				if products_pool.size() != 0:
					loading_status=2
			5:
				%status_lable.text = "Status: Loading complite"
				var count = await get_count()
				%count_lable.text = "Select {elements} items out of {out_of}".format({
					'elements' : all_count,
					'out_of' : count
				})
				loading_status-=1
			_:
				loading_status-=1
				loading_status+=delta
				%status_lable.text = "Status: Loading stoped ("+str(abs(loading_status))+")"
					
		loading_status+=1
		
func get_count():
	var query_s = "SELECT count(*) as 'count' FROM `products`;"
	await Global.db.query(query_s)
	return Global.db.query_result[0]['count']

func add_element(row):
	if row == null:
		return
	var element: PackedScene = preload("res://interface/element/element.tscn")
	var products: Product = Product.new_from_dict(row)
		
		
	var new_element: Element = element.instantiate()
	%elements_list.add_child(new_element)
	
	new_element.set_data("product", products)
	new_element.set_main_lable(products.name)
	new_element.set_desc_lable(products.price_description)
	if not 'error' in products.image_metadata:
		await new_element.set_image(products.image, products.image_metadata)
	if Global.user.is_admin == true:
		new_element.add_button("Delete", 'delete', self._product)
		new_element.add_button("Add key", 'add_key', self._product)
		new_element.add_button("Keys list", 'keys_list', self._product)
	else:
		new_element.add_button("Select", 'select', self._product)

func _product(element: Element, action: String):
	if not "product" in element.data:
		assert(true, "ERROR: not products_element")
		return
	var product: Product = element.data['product']
	match action:
		'add_key':
			self._add_key(product)
		'select':
			self.select_key(product, Global.selected_staffer)
		'delete':
			self._delete_key(element, product)
		'keys_list':
			self._open_keys_list(product)
	
func _add_key(product: Product):
	Global.selected_product = product
	get_tree().change_scene_to_file("res://interface/add_key_menu/add_key_menu.tscn")
	queue_free()

func _delete_key(element: Element, product: Product):
	product.delete()
	element.queue_free()

func _open_add_unit_menu(element: Element, action: String):
	get_tree().change_scene_to_file("res://interface/add_unit_menu/add_unit_menu.tscn")
	queue_free()

func _open_keys_list(product: Product):
	Global.selected_product = product
	get_tree().change_scene_to_file("res://interface/keys_menu/keys_menu.tscn")
	queue_free()

func select_key(product: Product, staffer: Staffer):
	%error_lable.text = " "
	if (!Global.db.open_db()):
		print("Cannot open database.");
		return;
	
	var query = "";
	var result = null;
	
	# Fetch rows
	query = "SELECT * FROM `keys` WHERE `status` = 0 AND `product` = {id} LIMIT 1;"
	query = query.format(product.dict)
	Global.db.query(query);
	result = Global.db.query_result
	
	if result.is_empty():
		%error_lable.text = "No code for this product"
		return
	
	var key: Key = Key.new_from_dict(result[0])

	var row_dict : Dictionary = Dictionary()
	
	row_dict["key_id"] = key.id
	row_dict["staffer_id"] = staffer.id

	# Insert a new row in the table
	Global.db.insert_row("purchase", row_dict)
	Global.db.update_rows("keys", "`id` = {id}".format(key.dict), {"STATUS":1})
	row_dict.clear()
	if Global.db.error_message != "not an error":
		%status_lable.text = Global.Global.db.error_message
	Global.db.close_db()
	get_tree().change_scene_to_file("res://interface/keys_menu/keys_menu.tscn")
	queue_free()
	
func _open_add_chan_menu(element: Element, action: String):
	get_tree().change_scene_to_file("res://interface/add_products_menu/add_products_menu.tscn")
	queue_free()

func _add_product():
	get_tree().change_scene_to_file("res://interface/add_product_menu/add_product_menu.tscn")
	queue_free()

func _on_back_pressed():
	if Global.user.is_admin == true:
		get_tree().change_scene_to_file("res://interface/admin_menu/admin_menu.tscn")
		queue_free()
		return
	get_tree().change_scene_to_file("res://interface/keys_menu/keys_menu.tscn")
	queue_free()
	pass # Replace with function body.


func _execute_load(index):
	loading_status = 1


func _on_discount_scrolling():
	%discount_label.text = "{min_discount}%-{max_discount}%".format({
		'min_discount': %min_discount.value,
		'max_discount': %max_discount.value
	})
	
func _on_min_discount_scrolling():
	if %min_discount.value > %max_discount.value:
		%max_discount.value = %min_discount.value
	_on_discount_scrolling()

func _on_max_discount_scrolling():
	if %max_discount.value < %min_discount.value:
		%min_discount.value = %max_discount.value
	_on_discount_scrolling()


func _on_discount_gui_input(event):
	if event is InputEventMouseButton:
			scroller_pressed = event.pressed


func _on_sort_button_down():
	stop_load()
	

func stop_load():
	loading_status = -100

func _on_discount_value_changed(value):
	await _execute_load(0)


func _on_search_text_text_changed(new_text):
	wait_status = 50


func _on_search_text_text_submitted(new_text):
	loading_status = 1
