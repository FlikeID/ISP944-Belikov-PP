class_name Staffer

var id:				int
var name:			String
var surname:		String
var unit:			int
var image:			PackedByteArray
var image_metadata:	Dictionary

var fullname: String

var dict: Dictionary

func _init(id:int, name:String, surname:String, unit:int, image:PackedByteArray, image_metadata:Dictionary):
	self.id 			= id
	self.name 			= name
	self.surname 		= surname
	self.unit 			= unit
	self.image 			= image
	self.image_metadata = image_metadata
	
	self.fullname = name + " " +surname
	
	self.dict = self._dict()

static func new_from_dict(paramentrs: Dictionary):
	if paramentrs['image'] == null:
		paramentrs['image'] = []
		paramentrs['image_metadata'] = {"error": "Image is null"}
	else:
		paramentrs['image_metadata'] = JSON.parse_string(paramentrs['image_metadata'])
	return Staffer.new(
		paramentrs['id'],
		paramentrs['name'],
		paramentrs['surname'],
		paramentrs['unit'],
		paramentrs['image'],
		paramentrs['image_metadata'],
	)


func _dict() -> Dictionary:
	return {
		'id': 				id,
		'name': 			name,
		'surname': 			surname,
		'unit': 			unit,
		'image': 			image,
		'image_metadata': 	image_metadata,
	}

func delete():
	var query = "`id` = {id};"
	query = query.format(dict)
	Global.db.delete_rows("staffers", query)
