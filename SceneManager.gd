extends Node2D

var next_scene = null

func _ready():
	self.RunTransition("FadeIn")

func RunTransition(name):
	$TransitionLayer/AnimationPlayer.play(name)
	
func go_to_scene(scene: String):
	self.next_scene = scene
	self.RunTransition("FadeOut")

func TransitionEndedUnlockPlayer():
	$CurrentScene/Main/Player.set_locked_mode(false)

func TransitionEnded():
	$CurrentScene.get_child(0).queue_free()
	$CurrentScene.add_child(load(self.next_scene).instance())
	self.RunTransition("FadeInBotsMonitor")
