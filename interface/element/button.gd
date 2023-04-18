extends Button

class_name Action_button

var action: String
var parent

signal clicked(parent, action)

func link_signal(function: Callable):
	clicked.connect(function)

func _enter_tree():
	connect("pressed",Callable(self,"signaling"))
	
func signaling():
	clicked.emit(parent, action)
