extends Area3D

var already_triggered = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Vérifier que c'est le joueur
	if body.is_in_group("player") and !already_triggered:
		already_triggered = true
		print("Sortie 4 déclenchée - Téléportation vers Debug Room")
		
		# Changer de scène
		get_tree().change_scene_to_file("res://scenes/fin_4_debug.tscn")
