class_name Purchase

var id:			int
var key_id:		int
var staffer_id:	int

var dict: Dictionary

var _key: Key
var _staffer: Staffer


func _init(id:int,key_id:int,staffer_id:int):
	self.id 		= id
	self.key_id 	= key_id
	self.staffer_id = staffer_id
	
	self.dict = self._dict()
	
	
static func new_from_dict(paramentrs: Dictionary):
	return Purchase.new(
		paramentrs['id'],
		paramentrs['id_departament'],
		paramentrs['id_chancellery'],
	)

func _dict() -> Dictionary:
	return {
		'id'		: self.id,
		'key_id'	: self.key_id,
		'staffer_id': self.staffer_id,
	}

func key(cache: bool = true) -> Key:
	if cache or (_key == null):
		var query = "SELECT * FROM `keys` where `id` = {key_id};"
		query = query.format(dict)
		Global.db.query(query);
		var result = Global.db.query_result
		self._key = Key.new_from_dict(result[0])
	return _key

func staffer(cache: bool = true) -> Staffer:
	if cache or (_key == null):
		var query = "SELECT * FROM `staffers` where `id` = {staffer_id};"
		query = query.format(dict)
		Global.db.query(query);
		var result = Global.db.query_result
		self._staffer = Staffer.new_from_dict(result[0])
	return _staffer

func delete():
	var query = "`id` = {id};"
	query = query.format(dict)
	Global.db.delete_rows("purchase", query)
