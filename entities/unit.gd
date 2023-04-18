class_name Unit

var id:				int
var name:			String
var image:			PackedByteArray
var image_metadata:	Dictionary

var dict: Dictionary

func _init(id:int, name:String, image:PackedByteArray, image_metadata:Dictionary):
	self.id 			= id
	self.name 			= name
	self.image 			= image
	self.image_metadata = image_metadata
	
	self.dict = _dict()

static func new_from_dict(paramentrs: Dictionary):
	if paramentrs['image'] == null:
		paramentrs['image'] = []
		paramentrs['image_metadata'] = {"error": "Image is null"}
	else:
		paramentrs['image_metadata'] = JSON.parse_string(paramentrs['image_metadata'])	
	return Unit.new(
		paramentrs['id'],
		paramentrs['name'],
		paramentrs['image'],
		paramentrs['image_metadata'],
	)

func _dict():
	return {
		'id':				id,
		'name':				name,
		'image':			image,
		'image_metadata':	image_metadata,
	}

func delete():
	var query = "`id` = {id};"
	query = query.format(dict)
	Global.db.delete_rows("units", query)
