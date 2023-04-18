class_name Key

var id:				int
var key:			String
var product:		int

var dict: Dictionary

func _init(id:int, name:String, price:float):
	self.id 			= id
	self.key 			= name
	self.product 			= price
	
	self.dict = self._dict()

static func new_from_dict(paramentrs: Dictionary) -> Key:

	return Key.new(
		paramentrs['id'],
		paramentrs['key'],
		paramentrs['product'],
	)

static func get_key(id:int) -> Key:
	if (!Global.db.open_db()):
		print("Cannot open database.");
		assert(true,"Cannot open database.")
		return;
	
	var query = "";
	var result = null;
	
	# Fetch rows
	query = "SELECT * FROM `keys` WHERE `id` = {id};"
	query = query.format({'id': id})
	Global.db.query(query);
	result = Global.db.query_result
	
	return Key.new_from_dict(result[0])

func _dict() -> Dictionary:
	return {
		'id':				id,
		'key':				key,
		'product':			product
	}

func delete():
	var query = "`id` = {id};"
	query = query.format(dict)
	Global.db.delete_rows("keys", query)
