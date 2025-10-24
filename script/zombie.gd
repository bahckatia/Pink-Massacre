extends CharacterBody3D

@export var health := 100
@export var speed := 1.5
@onready var player = get_tree().get_first_node_in_group("player") # Player doit être dans un groupe "player"

func _physics_process(delta):
	if not player:
		return
	
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0
	velocity = direction * speed
	move_and_slide()

	# Quand l'ennemi est proche
	if global_position.distance_to(player.global_position) < 1.8:
		# future attaque ici
		pass

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
