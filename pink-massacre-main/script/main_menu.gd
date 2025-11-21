extends Node3D


# Animation du titre
var time_passed = 0.0

func _ready():
	# Connecter les boutons
	$UI/PlayButton.pressed.connect(_on_play_button_pressed)
	$UI/QuitButton.pressed.connect(_on_quit_button_pressed)
	
	# Animation d'entrée (fade in) pour chaque élément UI
	# Remplace "Logo" par le nom exact de ton TextureRect si différent
	$UI/Logo.modulate.a = 0.0
	$UI/PlayButton.modulate.a = 0.0
	$UI/QuitButton.modulate.a = 0.0
	
	var tween = create_tween()
	tween.set_parallel(true)  # Pour animer tout en même temps
	tween.tween_property($UI/Logo, "modulate:a", 1.0, 2.0)
	tween.tween_property($UI/PlayButton, "modulate:a", 1.0, 2.0)
	tween.tween_property($UI/QuitButton, "modulate:a", 1.0, 2.0)
	
	# Animer les sphères décoratives
	_animate_decorations()

func _process(delta):
	time_passed += delta
	
	# Animation pulsante du logo
	var scale_factor = 1.0 + sin(time_passed * 2.0) * 0.03
	$UI/Logo.scale = Vector2(scale_factor, scale_factor)

func _animate_decorations():
	# Faire flotter les sphères de haut en bas
	for i in range(1, 10):
		var sphere = $Decorations.get_node("Sphere" + str(i))
		if sphere:
			var tween = create_tween()
			tween.set_loops()
			tween.tween_property(sphere, "position:y", sphere.position.y + 0.3, 1.5 + i * 0.2)
			tween.tween_property(sphere, "position:y", sphere.position.y, 1.5 + i * 0.2)

func _on_play_button_pressed():
	# Effet sonore (si tu as un son)
	# $ClickSound.play()
	
	# Transition vers le jeu
	var tween = create_tween()
	tween.tween_property($UI, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_change_to_game)

func _change_to_game():
	# IMPORTANT : Change ce chemin vers ta scène de jeu !
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
