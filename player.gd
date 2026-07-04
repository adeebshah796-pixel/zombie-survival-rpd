extends CharacterBody3D

@export var speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float =0.002

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck:Node3D=$Neck
@onready var camera:Camera3D=$Neck/Camera3D
@onready var gun_ray:RayCast3D=$Neck/Camera3D/GunRay
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	gun_ray.add_exception(self)
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
		if Input.get_mouse_mode()==Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			return
		
	if Input.is_action_just_pressed("shoot") and Input.get_mouse_mode() ==Input.MOUSE_MODE_CAPTURED:
		shoot_weapon()
			
	if event is InputEventMouseMotion and Input.get_mouse_mode()==Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x*mouse_sensitivity)
		camera.rotate_x(-event.relative.y*mouse_sensitivity)
		camera.rotation.x=clamp(camera.rotation.x,deg_to_rad(-85),deg_to_rad(85))
func _physics_process(delta:float) -> void:
	if not is_on_floor():
		velocity.y-= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	var input_dir:Vector2 = Input.get_vector("move_left","move_right","move_forward","move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()
	if direction:
		velocity.x =direction.x*speed
		velocity.z=direction.z*speed
	else:
		velocity.x =move_toward(velocity.x,0,speed)
		velocity.z=move_toward(velocity.z,0,speed)
	move_and_slide()

func shoot_weapon():
	print("Bang!")
	
	if gun_ray.is_colliding():
		var hit_object=gun_ray.get_collider()
		print("Hit Object:",hit_object.name)
		
		if hit_object.has_method("take_damage"):
			hit_object.take_damage(25)
	
