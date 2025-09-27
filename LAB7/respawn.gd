extends Node3D

@export var enemy : PackedScene
var timerStarded = false
func _process(delta):
	if get_child_count() <= 1 and timerStarded == false:
		$Timer.start()
		timerStarded = true
		
func _on_timer_timeout() -> void:
	var instance = enemy.instantiate()
	add_child(instance)
	timerStarded = false
