extends Node3D
@export var zombie_scene: PackedScene
@onready var timer: Timer = $Timer
func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
func _on_timer_timeout() -> void:
	if zombie_scene == null:
		print("WARNING: No zombie scene assigned to the ZombieSpawner!")
	var new_zombie = zombie_scene.instantiate()
	get_parent().add_child(new_zombie)
	new_zombie.global_position = global_position
	print("A new zombie has crawled out of ground!")
