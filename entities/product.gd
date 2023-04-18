class_name Product

var id:				int
var name:			String
var price:			float
var image:			PackedByteArray
var image_metadata:	Dictionary

var dict: Dictionary
var price_description: String

func _init(id:int, name:String, price:float, image:PackedByteArray, image_metadata:Dictionary):
	self.id 			= id
	self.name 			= name
	self.price 			= price
	self.image 			= image
	self.image_metadata = image_metadata
	
	self.dict = self._dict()

static func new_from_dict(paramentrs: Dictionary):
	if paramentrs['image'] == null:
		paramentrs['image'] = []
		paramentrs['image_metadata'] = {"error": "Image is null"}
	else:
		paramentrs['image_metadata'] = JSON.parse_string(paramentrs['image_metadata'])
	return Product.new(
		paramentrs['id'],
		paramentrs['name'],
		paramentrs['price'],
		paramentrs['image'],
		paramentrs['image_metadata'],
	)

func _dict() -> Dictionary:
	return {
		'id':				id,
		'name':				name,
		'price':			price,
		'image':			image,
		'image_metadata':	image_metadata,
	}

func delete():
	var query = "`id` = {id};"
	query = query.format(dict)
	Global.db.delete_rows("products", query)
