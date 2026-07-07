extends StaticBody3D
var health: int=100

func take_damage(amount:int) ->void:
	health -=amount
	print("Dummy hit! Remaining health: ",health)
	if health <= 0:
		print("Dummy destroyed!")
		queue_free()
				
