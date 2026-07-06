extends CharacterBody3D

@export var speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float =0.002

@export var max_health: float = 100.0
var current_health: float = max_health
@export var max_stamina: float = 100.0
var current_stamina: float = max_stamina
@export var stamina_drain_rate: float = 20.0
@export var stamina_regen_rate: float = 10.0

@export var max_hunger: float = 100.0
var current_hunger: float = max_hunger
@export var hunger_drain_rate: float = 0.5
@export var max_ammo: int = 12
var current_ammo: int = max_ammo
@export var reload_time: float = 1.5
var is_reloading: bool = false 
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


@onready var neck:Node3D=$Neck
@onready var camera:Camera3D=$Neck/Camera3D
@onready var gun_ray:RayCast3D=$Neck/Camera3D/GunRay

@onready var health_bar: ProgressBar = $HUD/HealthBAR
@onready var stamina_bar: ProgressBar = $HUD/StaminaBar
@onready var hunger_bar: ProgressBar = $HUD/HungerBar


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gun_ray.add_exception(self)
	update_ui()
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
		if Input.get_mouse_mode()==Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			return
		
	if Input.is_action_just_pressed("shoot") and Input.get_mouse_mode() ==Input.MOUSE_MODE_CAPTURED:
		shoot_weapon()
	if Input.is_action_just_pressed("reload") and current_ammo < max_ammo and not is_reloading:
		reload_weapon()
			
	if event is InputEventMouseMotion and Input.get_mouse_mode()==Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x*mouse_sensitivity)
		camera.rotate_x(-event.relative.y*mouse_sensitivity)
		camera.rotation.x=clamp(camera.rotation.x,deg_to_rad(-85),deg_to_rad(85))
func _physics_process(delta:float) -> void:
	handle_survival_stats(delta)
	if not is_on_floor():
		velocity.y-= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor() and current_stamina > 10:
		velocity.y = jump_velocity
		current_stamina -= 10.0
	var input_dir:Vector2 = Input.get_vector("move_left","move_right","move_forward","move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()
	var current_speed = speed
	if Input.is_action_pressed("sprint") and direction != Vector3.ZERO and current_stamina > 0.0:
		current_speed = sprint_speed
		current_stamina -= stamina_drain_rate * delta
	
	else:
		current_stamina = move_toward(current_stamina, max_stamina, stamina_regen_rate * delta)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x =move_toward(velocity.x,0,speed)
		velocity.z=move_toward(velocity.z,0,speed)
	move_and_slide()
	update_ui()
func handle_survival_stats(delta: float) -> void:
	current_hunger = move_toward(current_hunger, 0, hunger_drain_rate * delta)
	if current_hunger <= 0:
		take_damage(2.0 * delta)
		
func update_ui() -> void:
	health_bar.value = current_health
	stamina_bar.value = current_stamina
	hunger_bar.value = current_hunger
	if is_reloading:
		ammo_label.text = "Reloding..."
	else:
		ammo_label.text = str(current_ammo) + " / " + str(max_ammo)


func shoot_weapon():
	if is_reloading:
		print("can't shoot while reloading!")
		return
	if current_ammo <= 0:
		print("Out of ammo! Press R toreload.")
	current_ammo -= 1
	update_ui()
	print("Bang!")
	
	if gun_ray.is_colliding():
		var hit_object=gun_ray.get_collider()
		print("Hit Object:",hit_object.name)
		
		if hit_object.has_method("take_damage"):
			hit_object.take_damage(25)
func reload_weapon():
	print("reloading started...")
	is_reloading = true
	update_ui()
	await get_tree().create_timer(reload_time).timeout
	current_ammo = max_ammo
	is_reloding = false
	print("res://player.tscn""Reload complete!")
	update_ui()

func take_damage(amount: float) -> void:
	current_health -= amount
	if current_health <= 0:
			die()
func die() -> void:
	print("YOU DIED!")
	get_tree().reload_current_scene()
	

 
