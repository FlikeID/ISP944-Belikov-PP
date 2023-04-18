class_name User

var id				: int
var login			: String
var email			: String
var is_admin		: bool
var last_session		: int

var dict: Dictionary


func _init(id:int,login:String,email:String,is_admin:bool, last_session:int=0):
	self.id			 = id
	self.login		 = login
	self.email		 = email
	self.is_admin	 = is_admin
	self.last_session	 = last_session
	
	self.dict = self._dict()
	
	
static func new_from_dict(paramentrs: Dictionary):
	return User.new(
		paramentrs['id'],
		paramentrs['login'],
		paramentrs['email'],
		paramentrs['is_admin'],
		paramentrs['last_session'],
	)

func _dict() -> Dictionary:
	return {
		'id'			: self.id,
		'login'			: self.login,
		'email'			: self.email,
		'is_admin'		: self.is_admin,
		'last_session'		: self.last_session,
	}
