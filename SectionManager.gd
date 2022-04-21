extends Node

var current_section = null
var current_section_id = 0
var total_sections = 0
var bots_per_section = 30

func _ready():
	pass

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_LEFT:
				if self.current_section_id > 0:
					self.current_section_id -= 1
			elif event.scancode == KEY_RIGHT:
				if self.current_section_id < self.total_sections:
					self.current_section_id += 1
			if self.get_section_by_id(self.current_section_id):
				pass

func add_new_section(instance, parent):
	self.current_section = instance.set_id(self.current_section_id)
	parent.add_child(self.current_section)
	self.current_section.add_to_group("bots_sections")
	self.current_section_id += 1
	self.total_sections += 1

func get_section_by_id(id):
	for section in get_tree().get_nodes_in_group("bots_sections"):
		if section.get_id() == id:
			return section
	return null
