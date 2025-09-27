extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var onCooldown = false
var sensivity = 0.003
var gold = 0
var hp = 100
var maxHp = 50 
var damage = 10
var target = []
var key: int = 0 
@onready var camera = $FirstPerson
@onready var animatonPlayer = $AnimationPlayer
@onready var cooldown = $AttackCooldown
@onready var hpBar = $HUD/HpBar
@onready var goldlabel = $HUD/Goldlabel
@onready var keylabel = $HUD/keylabel

func players():
	pass

func deal_damage():
	for enemies in target:
		enemies.hp -= damage
	
func _ready():
	$Control.hide()
	animatonPlayer.play("idle")
	hpBar.max_value = 50
	$FirstPerson.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func attack():
	if Input.is_action_just_pressed("attack") and onCooldown == false:
		animatonPlayer.play("SwordSwing")
		onCooldown = true
		$Swordsound.play()
		cooldown.start()
			
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		
		rotate_y(-event.relative.x * sensivity)
		camera.rotate_x(-event.relative.y *sensivity)
		camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-60),deg_to_rad(70))
		
func update_HUD():
	hpBar.value = hp
	hpBar.max_value = maxHp   # เพื่อให้ bar รู้ค่าสูงสุด

	# แสดงค่าแบบ x / max
	goldlabel.text = str(gold) + "/" + str(25)
	keylabel.text  = str(key)  + "/" + str(7)


	
func _switch_view():
	if Input.is_action_just_pressed("switch"):
		if camera == $FirstPerson:
			camera = $Head
			$Head/ThirdPerson.current = true
		else:
			camera = $FirstPerson
			$FirstPerson.current = true
	
	
func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

func _process(delta): 
	update_HUD()
	attack()
	_switch_view()
	if Input.is_action_just_pressed("escape"): 
		get_tree().quit()
	gameover()


func _on_attack_cooldown_timeout() -> void:
	onCooldown = false


func _on_attack_zone_body_entered(body):
	if body.has_method("enemy"):
		target.append(body)


func _on_attack_zone_body_exited(body) :
	if body.has_method("enemy"):
		target.erase(body)
		if hp > 0:
			regen()

func regen():
	hpBar.value = hp
	$regen.start()

func _on_regen_timeout() -> void:
	hp = min(hp + 7, maxHp)
	hpBar.value = hp
	
func gameover():
	# Trigger game over once when hp drops to zero or below.
	if hp <= 0:
		# Ensure hp never goes negative
		hp = 0
		# Update HUD immediately
		hpBar.value = hp

		# If the Control (game over UI) is already visible, do nothing more.
		# This prevents repeated triggers / repeated animation plays.
		if $Control.visible:
			return

		# Play death animation (only once)
		if animatonPlayer.current_animation != "Death":
			animatonPlayer.play("Death")

		# Show the game-over UI and newgame button
		$Control.show()
	

		# Stop movement & processing so character can't move or act after death
		set_process(false)
		set_physics_process(false)

		# Make mouse visible so player can click UI
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

		# Make sure first-person camera isn't capturing input anymore
		# (safeguard: try to unset current cameras if present)
		if has_node("$FirstPerson"):
			$FirstPerson.current = false
		if has_node("$Head/ThirdPerson"):
			$Head/ThirdPerson.current = false

		# Stop timers (safe to call stop even if they are already stopped)
		if has_node("$regen"):
			$regen.stop()
		if cooldown:
			# cooldown is onready var at top — stop it too
			cooldown.stop()
