extends StaticBody3D

@export var required_keys: int = 7  # จำนวนกุญแจที่ต้องการ
@onready var door_collision: CollisionShape3D = $CollisionShape3D  # ตัวกั้นประตู (ถ้ามีหลายตัว ดูโค้ดด้านล่าง)
@export var required_enemy: int = 25

func _ready() -> void:
	$CanvasLayer/quest.hide()
	$CanvasLayer/Lock.hide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body:
		return
	# ถ้าเป็น Player (คุณใช้ has_method("players") มาแล้ว แปลว่าตรงกับที่คุณเช็ค)
	if body.has_method("players"):
		print("Player keys:", body.key)
		if body.key >= required_keys and body.gold >= required_enemy :
			print("ประตูเปิดแล้ว — พยายามปลด collision แบบ deferred")
			# 1) ปลด disabled ของ CollisionShape3D แบบ deferred (ปลอดภัยขณะ physics tick)
			if door_collision:
				door_collision.set_deferred("disabled", true)
			# 2) ถ้ายังบล็อค อาจเป็นเพราะ parent (StaticBody3D) ยังมี layer -> ปรับ layer/mask ให้เป็น 0 แบบ deferred
			self.set_deferred("collision_layer", 0)
			self.set_deferred("collision_mask", 0)
			get_tree().change_scene_to_file("res://Scenes/gamewin.tscn")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			# 3) ถ้าต้องการ ลบ shape ออกเลย (ทดสอบ)
			# door_collision.call_deferred("queue_free")
		else:
			$CanvasLayer/Lock.show()
			$CanvasLayer/quest.show()
			print("ต้องการกุญแจอีก %d ดอก" % (required_keys - body.key))


# --- เพิ่ม utility สำหรับ debug ถ้าจำเป็น ---
func debug_print_all_collisions() -> void:
	print("---- Door debug info ----")
	for child in get_children():
		if child is CollisionShape3D:
			print("Found CollisionShape3D:", child.name, " disabled =", child.disabled)
	# แสดง layer/mask ของ StaticBody3D (self)
	print("Door collision_layer:", self.collision_layer, " collision_mask:", self.collision_mask)
	print("-------------------------")


func _on_area_3d_body_exited(body: Node3D) -> void:
	$CanvasLayer/Lock.hide()
	$CanvasLayer/quest.hide()
