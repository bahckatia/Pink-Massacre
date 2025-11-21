extends Control

# Références
@onready var red_flash = $RedFlash
@onready var death_message = $DeathMessage
@onready var subtitle = $Subtitle
@onready var restart_button = $RestartButton
@onready var menu_button = $MenuButton

# Configuration
var glitch_intensity = 10.0
var time_passed = 0.0

func _ready():
	# Cacher la souris au début
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Connecter les boutons
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
	# Rendre les boutons invisibles au début
	restart_button.modulate.a = 0.0
	menu_button.modulate.a = 0.0
	death_message.modulate.a = 0.0
	if subtitle:
		subtitle.modulate.a = 0.0
	
	# Lancer l'animation d'entrée
	_play_death_animation()

func _process(delta):
	time_passed += delta
	
	# Effet de glitch sur le texte principal
	if death_message.modulate.a > 0.5:
		var glitch_offset = Vector2(
			randf_range(-glitch_intensity, glitch_intensity),
			randf_range(-glitch_intensity, glitch_intensity)
		)
		death_message.position = death_message.position.lerp(
			Vector2(228, 174) + glitch_offset,
			0.5
		)
		
		# Changer aléatoirement la couleur entre rose et rouge
		if randf() < 0.1:
			death_message.add_theme_color_override("font_color", 
				Color.RED if randf() < 0.5 else Color.DEEP_PINK
			)

func _play_death_animation():
	var tween = create_tween()
	
	# 1. Flash rouge intense
	tween.tween_property(red_flash, "modulate:a", 0.8, 0.2)
	tween.tween_property(red_flash, "modulate:a", 0.0, 0.3)
	
	# 2. Deuxième flash plus long
	tween.tween_property(red_flash, "modulate:a", 0.6, 0.15)
	tween.tween_property(red_flash, "modulate:a", 0.0, 0.5)
	
	# 3. Apparition du texte avec glitch
	tween.tween_property(death_message, "modulate:a", 1.0, 0.3)
	
	# 4. Apparition du sous-titre
	if subtitle:
		tween.tween_property(subtitle, "modulate:a", 1.0, 0.5)
	
	# 5. Apparition progressive des boutons
	tween.tween_property(restart_button, "modulate:a", 1.0, 0.4)
	tween.tween_property(menu_button, "modulate:a", 1.0, 0.4)
	
	# 6. Réduire l'intensité du glitch après animation
	tween.tween_callback(_reduce_glitch)

func _reduce_glitch():
	var tween = create_tween()
	tween.tween_property(self, "glitch_intensity", 2.0, 2.0)

func _on_restart_pressed():
	# Effet de transition
	var tween = create_tween()
	tween.tween_property(red_flash, "modulate:a", 1.0, 0.3)
	tween.tween_callback(_restart_game)

func _restart_game():
	# IMPORTANT : Change ce chemin vers ta scène de jeu
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_menu_pressed():
	# Transition vers le menu
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_go_to_menu)

func _go_to_menu():
	# IMPORTANT : Change ce chemin vers ton menu principal
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
