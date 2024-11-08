# Player.gd
extends CharacterBody2D

const SPEED := 100.0
const BOXHOLDSPEED := SPEED / 2
const JUMP_VELOCITY := -150.0
const jumpSFX := preload("res://Scenes/sfx/jump_sfx.tscn")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var isJump := false
var isFreeFall := false
var isHoldingBox := false
var isNearBox := false
var heldBoxID = null
var isDead := false
const coyoteConst := 7
var coyoteTime := coyoteConst
var bufferedJump := false
var bufferedJumpTimer := 0
const bufferedJumpConst := 10
@onready var free_fall_timer: Timer = $FreeFallTimer


var is_position_restored := false  


func _ready() -> void:
	if is_position_restored:
		return 
	await get_tree().create_timer(0).timeout


	var current_scene_name = str(get_parent().get_instance_id())
	Global.save_position_for_scene(current_scene_name, get_parent().get_node("SpawnPoint").position)
	var saved_position = Global.get_position_for_scene(current_scene_name)
	position = saved_position
	
	is_position_restored = true
	
	if not is_on_floor():
		velocity.y = 0  



func _physics_process(delta: float) -> void:
	if isDead:
		return
	if Input.is_action_just_pressed("Reset"):
		Global.Reset(get_parent().get_instance_id(), get_parent().levelPath)
		return
	if !is_on_floor():
		velocity += get_gravity() * delta
		coyoteTime -= 1 if coyoteTime > 0 else 0
	else:
		coyoteTime = coyoteConst
		isJump = false
		isFreeFall = false
		free_fall_timer.stop()
		if isNearBox and Input.is_action_pressed("interact_hold"):
			isHoldingBox = true
		else:
			isHoldingBox = false
	
	if !is_on_floor() and Input.is_action_just_pressed("jump") and coyoteTime <= 0:
		bufferedJump = true
		bufferedJumpTimer = bufferedJumpConst
	
	if bufferedJumpTimer > 0:
		bufferedJumpTimer -= 1
	else:
		bufferedJump = false
	
	if bufferedJump and bufferedJumpTimer < bufferedJumpConst and is_on_floor():
		print("yippeee")
	
	# Handle jump.
	if (!isHoldingBox and (
	(Input.is_action_just_pressed("jump") and is_on_floor()) or 
	(Input.is_action_just_pressed("jump") and !is_on_floor() and coyoteTime > 0) or 
	(bufferedJump and is_on_floor()) ) ):
		if bufferedJump:
			bufferedJump = false
		coyoteTime = 0
		velocity.y = JUMP_VELOCITY
		animated_sprite_2d.play("Jump")
		isJump = true
		add_child(jumpSFX.instantiate())
		

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
	if not is_on_floor():
		animated_sprite_2d.play("FreeFall_B")
