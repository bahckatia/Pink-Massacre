extends Area3D

var already_triggered = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and !already_triggered:
		already_triggered = true
		print("🚪 Exit 4 triggered - Loading Debug Room")
		get_tree().call_deferred("change_scene_to_file", "res://scenes/fin_4_debug.tscn")
