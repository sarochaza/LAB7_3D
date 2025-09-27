extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("playagain"):
		get_tree().change_scene_to_file("res://Scenes/world.tscn")
		
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _on_newgamebutton_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_quitbutton_pressed() -> void:
	get_tree().quit()
