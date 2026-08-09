extends CharacterBody3D
@export var speed: float = 3.0
@export var health:int = 50
@export var attack_damage: float = 15.0
@export var attack_range: float = 2.0
var time_since_last_attack: float = 0.0
@export var attack_cooldown: float = 1.5
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var player: CharacterBody3D = null
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player:AnimationPlayer=$Model/AnimationPlayer
func _ready():
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player =players[0] 
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	if player:
		nav_agent.target_position = player.global_position
		if not nav_agent.is_navigation_finished():
			var next_position: Vector3 = nav_agent.get_next_path_position()
			var direction: Vector3 =(next_position - global_position).normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			
			if direction.x != 0 or direction.z != 0:
				var target_angle = atan2(-direction.x, -direction.z)
				rotation.y = rotate_toward(rotation.y, target_angle,delta * 6.0)
			if anim_player.current_animation!="mixamo_com":
				anim_player.play("mixamo_com")
		else:
			velocity.x = move_toward(velocity.x,0, speed)
			velocity.z = move_toward(velocity.z,0, speed)
	move_and_slide()
	time_since_last_attack += delta
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player <= attack_range and time_since_last_attack >= attack_cooldown:
				if player.has_method("take_damage"):
					player.take_damage(attack_damage)
					time_since_last_attack = 0.0
func take_damage(amount: int) -> void:
	health -= amount 
	print("Zombie hit! health left: ",health)
	if health <=0:
		print("zombie killed!")
		queue_free()
		
