extends MarginContainer
var db = Global.db
var chancellery_pool: Array
var query_string: String = ""
var loading_status: int = 0
var scroller_pressed: bool = false
var all_count : int = 0
var wait_status : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	load_data()
	
func load_data(by: String = "name", how: String = "ASC", min_discount: int = 0, max_discount: int = 100, search: String = ""):
	for node in %elements_list.get_children():
		node.queue_free()
	
	# Open database
	if (!db.open_db()):
		print("Cannot open database.");
		return;
	
	var query = "";
	var result = null;
	
	# Fetch rows
	query = "SELECT * FROM `chancellery` WHERE `discount` BETWEEN  {min_discount} and {max_discount} and `name` LIKE '%{search}%' ORDER BY `{by}` {how};"
	query = query.format({
		'by': by,
		'how': how,
		'min_discount': min_discount,
		'max_discount': max_discount,
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
				if chancellery_pool.size() != 0:
					loading_status=2
			1:
				chancellery_pool.clear()
				%status_lable.text = "Status: Loading.."
				await load_data(Global.OrderBy[%sort_by.selected], Global.OrderHow[%sort_how.selected], %min_discount.value, %max_discount.value, %search_text.text)
			2:
				%status_lable.text = "Status: Loading..."
				await db.query(query_string)
				chancellery_pool = db.query_result
				all_count = chancellery_pool.size()
			3:
				%status_lable.text = "Status: Loading...."
				await add_element(chancellery_pool.pop_front())
			4:
				if chancellery_pool.size() != 0:
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
	var query_s = "SELECT count(*) as 'count' FROM `chancellery`;"
	await db.query(query_s)
	return db.query_result[0]['count']

func add_element(row):
	if row == null:
		return
	var element: PackedScene = preload("res://interface/element/element.tscn")
	var chancellery: Chancellery = Chancellery.new_from_dict(row)
		
		
	var new_element: Element = element.instantiate()
	%elements_list.add_child(new_element)
	
	new_element.set_data("chancellery", chancellery)
	new_element.set_main_lable(chancellery.name)
	new_element.set_desc_lable(chancellery.price_description)
	if not 'error' in chancellery.image_metadata:
		await new_element.set_image(chancellery.image, chancellery.image_metadata)
	if Global.user.is_admin == true:
		new_element.add_button("Delete", 'delete', self._select_chan)
	else:
		new_element.add_button("Select", 'select', self._select_chan)
	if chancellery.discount != 0:
		new_element.greenlight()
			
func _select_chan(element: Element, action: String):
		
	if not "chancellery" in element.data:
		assert(true, "ERROR: not chancellery_element")
		return
	if Global.user.is_admin == true:
		var chancellery : Chancellery = element.data['chancellery']
		chancellery.delete()
		get_tree().change_scene_to_file("res://interface/chancellery_menu/chancellery_menu.tscn")
		queue_free()
		return
	Global.selected_chancellery = element.data['chancellery']
	get_tree().change_scene_to_file("res://interface/add_purchase_menu/add_purchase_menu.tscn")
	queue_free()

func _open_add_chan_menu(element: Element, action: String):
	get_tree().change_scene_to_file("res://interface/add_chancellery_menu/add_chancellery_menu.tscn")
	queue_free()


func _on_back_pressed():
	if Global.user.is_admin == true:
		get_tree().change_scene_to_file("res://interface/admin_menu/admin_menu.tscn")
		queue_free()
		return
	get_tree().change_scene_to_file("res://interface/add_purchase_menu/add_purchase_menu.tscn")
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
