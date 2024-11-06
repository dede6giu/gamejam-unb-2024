extends CharacterBody2D

const SPEED := 130.0
const BOXHOLDSPEED := SPEED / 2
const JUMP_VELOCITY := -300.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var isJump := false
var isFreeFall := false
var isHoldingBox := false
var isNearBox := false
var heldBoxID = null
@onready var free_fall_timer: Timer = $FreeFallTimer

#func create_statue():
#	# Needs to fix the state follow the player
#	var newStatue = statuePath.instantiate()
#	newStatue.position = Vector2(0,0)
#	add_child(newStatue)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		isJump = false
		isFreeFall = false
		free_fall_timer.stop()
		if isNearBox and Input.is_action_pressed("interact_hold"):
			isHoldingBox = true
		else:
			isHoldingBox = false
	
#	if Input.is_action_just_pressed("spawn_statue"):
#		#Take Player position and create a statue 
#		create_statue()

	# Handle jump.
	if !isHoldingBox and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite_2d.play("Jump")
		isJump = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if !isHoldingBox:
		if direction > 0:
			animated_sprite_2d.flip_h = false
		elif direction < 0: 
			animated_sprite_2d.flip_h = true
	
		if !isJump and velocity.y <= 0:
			if direction == 0:
				animated_sprite_2d.play("Idle")
			else:
				animated_sprite_2d.play("Walk")
		elif velocity.y > 0 and !isFreeFall:
			isFreeFall = true
			animated_sprite_2d.play("FreeFall_A")
			free_fall_timer.start()
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		if animated_sprite_2d.flip_h:
			if direction > 0:
				animated_sprite_2d.play("Pull")
			elif direction < 0: 
				animated_sprite_2d.play("Push")
			else:
				animated_sprite_2d.play("Hold_Idle")
		else:
			if direction > 0:
				animated_sprite_2d.play("Push")
			elif direction < 0: 
				animated_sprite_2d.play("Pull")
			else:
				animated_sprite_2d.play("Hold_Idle")
			
		if direction:
			velocity.x = direction * BOXHOLDSPEED
		else:
			velocity.x = move_toward(velocity.x, 0, BOXHOLDSPEED)
	
	move_and_slide()


func _on_free_fall_timer_timeout() -> void:
	if !is_on_floor():
		animated_sprite_2d.play("FreeFall_B")
		
