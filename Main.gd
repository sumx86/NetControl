extends Node

func _ready():
	$Player.spawn($StartPosition.position, "down")

func _process(delta):
	pass
