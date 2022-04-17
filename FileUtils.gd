extends Node

func _ready():
	pass

func load_file(fname):
	var file = File.new()
	var error = file.open(fname, File.READ)
	if error != OK:
		print("Error opening file -> ", error)
		return null
	
	if file.get_len() <= 0:
		print("File " + fname + " is empty!")
		return null
	return file
