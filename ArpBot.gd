extends Area2D

var _data = {}
var gateway_data = {"ip":"192.168.0.1", "hw":"aa:aa:aa:aa:aa:aa"}
var command_options = ["arp.py", "--spoof"]
var good_bot = preload("res://Bots/goodbot.png")
var evil_bot = preload("res://Bots/evilbot.png")

onready var main = self.get_parent()
onready var player = main.get_node("Player")

func _ready():
	pass
	
func set_data(data, _position: Vector2):
	self._data = data
	self.position = _position
	if not self._data["trusted"]:
		$Sprite.set_texture(self.evil_bot)
	else:
		$Sprite.set_texture(self.good_bot)
	return self

func get_data():
	return self._data

func ban_from_network():
	self.command_options.append("--ip="      + self.data["ipaddr"])
	self.command_options.append("--tmac="    + self.data["hwaddr"])
	self.command_options.append("--gateway=" + self.gateway_data["ip"])
	self.command_options.append("--smac="    + self.gateway_data["hw"])
	OS.execute("python", self.command_options, false)
