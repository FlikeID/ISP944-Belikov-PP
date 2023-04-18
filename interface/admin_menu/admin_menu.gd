extends Control


func _on_units_list_pressed():
	get_tree().change_scene_to_file("res://interface/units_menu/units_menu.tscn")
	queue_free()


func _on_unit_add_pressed():
	get_tree().change_scene_to_file("res://interface/add_unit_menu/add_unit_menu.tscn")
	queue_free()


func _on_products_list_pressed():
	get_tree().change_scene_to_file("res://interface/products_menu/products_menu.tscn")
	queue_free()


func _on_add_product_pressed():
	get_tree().change_scene_to_file("res://interface/add_product_menu/add_product_menu.tscn")
	queue_free()
