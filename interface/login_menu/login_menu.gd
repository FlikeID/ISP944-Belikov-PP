extends Control

var secret = {}
var db = Global.db
var captcha_text: String
var captcha_timer: bool = false


var crypto = Crypto.new()
var key: CryptoKey = load("res://generated.key")
var cert: X509Certificate = load("res://generated.crt")

func _process(delta):
	if captcha_timer:
		var error_lable = get_node("P/MC/Login/error_lable")
		error_lable.visible = false
		error_lable.text = "Wrong capthca.
		Wait {n} seconds...".format({'n':snapped(%timer.time_left, 1)})
		error_lable.visible = true
		_captcha_generete()

func _ready():
	
	get_node("P/MC/Login/password_input").secret = true
	

func validate_login_fields() -> Dictionary: 
	var result = {}
	result["login"] = get_node("P/MC/Login/login_input").text
	result["password"] = get_node("P/MC/Login/password_input").text
	if result["login"].length() < 3:	
		result['error'] = "Login must be longer than 2 characters"
	elif result["password"].length() < 8:
		result['error'] = "Password must be longer than 7 characters"
	return result

func validate_register_fields() -> Dictionary: 
	var result = {}
	var regex = RegEx.new()
	regex.compile("^(.+)@(\\S+)$") # Compile our pattern
	
	
	
	result["email"] = %reg_email_input.text
	result["login"] = %reg_login_input.text
	result["password"] = %reg_password_input.text
	var email = regex.search(result["email"])
	if email == null or email.strings[0] != result["email"]:
		result['error'] = "Invalid email format"
	elif result["login"].length() < 3:
		result['error'] = "Login must be longer than 2 characters"
	elif result["password"].length() < 8:
		result['error'] = "Password must be longer than 7 characters"
	return result


func _on_login_pressed():
	
			
	
	# Create gdsqlite instance
	var error_lable = get_node("P/MC/Login/error_lable")
	error_lable.visible = false
	
	if not captcha_text.is_empty():
		if captcha_text != %captcha_input.text:
			%timer.start()
			captcha_timer = true
			%login.disabled = true
			%register.disabled = true
			%forget_pass.disabled = true
			return
		else:
			%capthca.visible = false
			return
	
	var auth_data = validate_login_fields()
	if auth_data.has('error'):
		error_lable.text = auth_data['error']
		error_lable.visible = true
		return
		
	
	# Open database
	if (!db.open_db()):
		print("Cannot open database.");
		error_lable.text = "Cannot open database."
		error_lable.visible = true
		return;
	
	var query = "";
	var result = null;
	
	# Fetch rows
	query = "SELECT * FROM `users` WHERE `login` = '{login}';"
	query = query.format(auth_data)
	db.query(query);
	result = db.query_result
	
	# Print rows
	if result.size() == 0:
		error_lable.text = "Invalid login or password"
		error_lable.visible = true
		_captcha_generete()
		
	elif result.size() == 1:
		if not _decrypting(auth_data["password"], result[0]["password"]):
			error_lable.text = "Invalid login or password"
			error_lable.visible = true
			_captcha_generete()
			return
			
		Global.user = User.new_from_dict(result[0])
		# Close database
		# Insert a new row in the table
		Global.db.insert_row("history", {'work_time':0})
		Global.user.last_session = Global.db.last_insert_rowid
		Global.db.update_rows("users", "`id` = {id}".format(Global.user.dict), Global.user.dict)
		db.close_db()
		if Global.user.is_admin:
			open_adminMenu() 
		else:
			open_unitsMenu()
	else:
		error_lable.text = "Unexpected count of users."
		error_lable.visible = true
		db.close_db()
	# Close database
	db.close_db()

func open_unitsMenu():
	get_tree().change_scene_to_file("res://interface/units_menu/units_menu.tscn")
	queue_free()

func open_adminMenu():
	get_tree().change_scene_to_file("res://interface/admin_menu/admin_menu.tscn")
	queue_free()

func _on_show_password_pressed():
	var error_lable = get_node("P/MC/Secret/error_lable")
	error_lable.visible = false

	
	# Open database
	if (!db.open_db()):
		print("Cannot open database.");
		return;
	
	var query = "";
	var result = null;
	
	# Fetch rows
	query = "SELECT * FROM `users` WHERE `id` = '{user_id}';"
	query = query.format(secret)
	db.query(query);result = db.query_result
	
	# Print rows
	if result.size() == 0:
		error_lable.text = "Invalid username or password"
		error_lable.visible = true
	if result.size() == 1:
		get_node("P/MC/Login").visible = true
		get_node("P/MC/Secret").visible = false
		get_node("P/MC/Login/password_input").text = result[0]['password']
		get_node("P/MC/Login/password_input").secret = false
		
	# Close database
	db.close()


func _on_forget_pass_pressed():
	
	get_node("P/MC/Login").visible = false
	get_node("P/MC/Secret").visible = true


func _on_register_pressed():
	$P/MC/Register.visible = true
	$P/MC/Login.visible = false


func _on_create_account_pressed():
	var error_lable = $P/MC/Register/error_lable
	error_lable.visible = false
	
	var auth_data = validate_register_fields()
	if auth_data.has('error'):
		error_lable.text = auth_data['error']
		error_lable.visible = true
		%login.disabled = true
		%register.disabled = true
		%forget_pass.disabled = true
		return
		
	# Open database
	if (!db.open_db()):
		print("Cannot open database.")
		return;
	
	# Fetch rows
	var query = "SELECT * FROM `users` WHERE `login` = '{login}';"
	query = query.format(auth_data)
	db.query(query);
	var result = db.query_result
	if (db.error_message != "not an error"):
		error_lable.text = db.error_message
		error_lable.visible = true
		print("Cannot insert data! "+db.error_message);
	# Print rows
	if result.size() == 1:
		error_lable.text = "This Login already taken"
		error_lable.visible = true
		return
	
	# Create user
	var row_array : Array = []
	var row_dict : Dictionary = Dictionary()
	row_dict["login"] = %reg_login_input.text
	var password =  %reg_password_input.text
	row_dict["password"] = _encrypting(password)
	row_dict["email"] = %reg_email_input.text
	# Insert a new row in the table
	db.insert_row("users", row_dict)
	row_dict.clear()
	if (db.error_message != "not an error"):
		error_lable.text = db.error_message
		error_lable.visible = true
		print("Cannot insert data! "+db.error_message);
	else:
		print("Data inserted into table.")
		$P/MC/Login.visible = true
		$P/MC/Register.visible = false
		$P/MC/Login/login_input.text = auth_data['login']
		$P/MC/Login/password_input.placeholder_text = "Insert your password"	
	db.close_db()

func _on_back_pressed():
	$P/MC/Login.visible = true
	$P/MC/Register.visible = false
	$P/MC/Secret.visible = false


func _on_send_code_pressed():
	var db = SQLite.new();
	
	var error_lable = $P/MC/Secret/error_lable
	error_lable.visible = false
	
	var regex = RegEx.new()
	regex.compile("^(.+)@(\\S+)$") # Compile our pattern
	
	var auth_data = {'email': $P/MC/Secret/email_input.text}
	var email = regex.search(auth_data["email"])
	if email == null or email.strings[0] != auth_data["email"]:
		auth_data['error'] = "Invalid email format"
		
	if auth_data.has('error'):
		error_lable.text = auth_data['error']
		error_lable.visible = true
		return
		
	# Open database
	if (!db.open_db()):
		print("Cannot open database.")
		return;
	
	# Fetch rows
	var query = "SELECT * FROM `users` WHERE `email` = '{email}';"
	query = query.format({
		'email': $P/MC/Secret/email_input.text
	})
	var result = db.fetch_array(query)
	
	# Print rows
	if result.size() == 0:
		error_lable.text = "Email is not used"
		error_lable.visible = true
		return
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var code = rng.randi_range(1111, 9999)
	
	secret['user_id'] = result[0]['id']
	secret['code'] = code
	$P/MC/Secret/send_code.disabled = true
	
	SendEmail("flikemaster2@gmail.com", "space.game.project.s@gmail.com", 
				"Register code: "+str(code), 
				"Here is your register approval code: "+str(code))
	
	%email_input.editable = false
	%code_input.editable = true
	%code_lable.visible = true
	%code_input.visible = true
	%show_password.visible = true
	
func SendEmail(emailto, emailfrom, subject, body):

	var command_body = [
		"$EmailFrom = '%s'" %[emailfrom],
		"$EmailTo = '%s'" %[emailto],
		"$Subject = '%s'"%[subject],
		"$Body = '%s'" %[body],
		"$SMTPServer = 'smtp.gmail.com'",
		"$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)",
		"$SMTPClient.EnableSsl = $true",
		"$SMTPClient.Credentials = New-Object System.Net.NetworkCredential('%s', '%s');"%["space.game.project.s@gmail.com", "zlwdqdyolpszrvui"],
		"$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)",
	]

	var commands = ""
	var count = 1
	for command in len(command_body):
		if count != len(command_body):
			commands += command_body[command] + "; "
		else:
			commands += command_body[command]
		
		count += 1

	var output = []
	OS.execute("powershell.exe", [commands], output)
	print(output)

func _captcha_generete():
	var chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	var word: String
	var n_char = len(chars)
	for i in range(4):
		word += chars[randi()% n_char]
	((%noise.texture as NoiseTexture2D).noise as FastNoiseLite).seed = randi()
	captcha_text = word
	%captcha_lable.text = word
	%capthca.visible = true



func _on_timer_timeout():
	captcha_timer = false
	%login.disabled = false
	%register.disabled = false
	%forget_pass.disabled = false
	var error_lable = get_node("P/MC/Login/error_lable")
	error_lable.text = "Insert capthca again."

func _encrypting(data: String) -> PackedByteArray:
	return crypto.encrypt(key, data.to_utf8_buffer())

func _decrypting(data: String, e: PackedByteArray) -> bool:
	
	# Decryption
	var decrypted = crypto.decrypt(key, e)
	
	# Signing
	var signature = crypto.sign(HashingContext.HASH_SHA256, data.sha256_buffer(), key)
	# Verifying
	var verified = crypto.verify(HashingContext.HASH_SHA256, data.sha256_buffer(), signature, key)
	# Checks
	return verified
