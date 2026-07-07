extends Area3D
@export var hunger_restore_amount: float = 35.0
func _ready() -> void:
	body_entered.connect(_on_body_entered)
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("Yum! Food collected.")
		body.current_hunger = min(body.current_hunger + hunger_restore_amount, body.max_hunger)
		queue_free()
