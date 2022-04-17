extends CanvasLayer

var id

func _ready():
	pass 

func set_id(_id):
	self.id = _id
	return self

func get_id():
	return self.id
