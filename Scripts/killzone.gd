extends Area2D
@onready var timer = $Timer
<<<<<<< HEAD
@onready var player = get_parent().get_node("Player") 
var inicial_player_pos = Vector2()
var statuePath = ResourceLoader.load("res://Scenes/statue.tscn")

func _ready():
	if player:
		inicial_player_pos = player.global_position
		print("Pos inicial: ", inicial_player_pos)
		
func create_statue(position: Vector2):
	var newStatue = statuePath.instantiate()
	newStatue.position = position
	add_child(newStatue)
	print("Spawning at :", position)

func _on_body_entered(body: Node2D) -> void:
	print("Check player exists ", player)
	if body.name == "Player":
		print("You died")
		timer.start()
		create_statue(body.position)
	
func _on_timer_timeout() -> void:
	if player:
		print("Current position: ", player.global_position)
		player.global_position = inicial_player_pos
		print("Returning on ", player.global_position)
	
=======

func _on_body_entered(body: Node2D) -> void:
	print("You died!")
	timer.start()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
>>>>>>> 2597bb9a33d64c60c0c1dee28731f12553351ca2
