extends Node

const DB_PATH = "res://ISP944_Belikov_UP.db"
var db : SQLite = SQLite.new();

var user: User
var selected_unit: Unit
var selected_staffer: Staffer
var selected_product: Product

var delata_time: float = 0.0
var time: int = 0

func _enter_tree():
	db.path = DB_PATH
	get_tree().set_auto_accept_quit(false)

func _ready():
	DisplayServer.window_set_window_event_callback(self.close_window_callback)

	
func close_window_callback(event): 
	if event == DisplayServer.WINDOW_EVENT_CLOSE_REQUEST:
		if (!Global.db.open_db()):
			print("Cannot open database.");
		if user != null:
			var a = Global.db.update_rows("history", "`id` = {last_session}".format(user.dict), {"work_time":time})
			print(a)
		Global.db.close_db()
		get_tree().quit()


func _process(delta):
	
	if user != null:
		delata_time+=delta
		if delata_time >= 1:
			time += int(delata_time)
			delata_time -= int(delata_time)
	
 

const OrderBy: Dictionary = {
	0: "name",
	1: "price",
	2: "discount",
}

const OrderHow: Dictionary = {
	0: "ASC",
	1: "DESC"
}

func _save_work_time():
	
	pass
