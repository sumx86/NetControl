extends Node

var current_section = null
var total_sections = 0
var bots_per_section = 30

func _ready():
	pass

func add_new_section(instance, parent):
	self.current_section = instance.set_id(self.total_sections)
	parent.add_child(self.current_section)
	self.current_section.add_to_group("bots_sections")
	self.total_sections += 1

func get_section_by_id(id):
	for section in get_tree().get_nodes_in_group("bots_sections"):
		if section.get_id() == id:
			return section
	return null

func add_navigation_button():
	self.total_sections
	pass
