extends CharacterBody3D
var value = 1
var target = null
var key: int = 0   

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("players"):
		$coin.play() # ตรวจว่าใช่ player ไหม
		body.key += value          # เพิ่มค่า key ของ player โดยตรง
		queue_free()               # ทำลาย object นี้ (เช่น item)
