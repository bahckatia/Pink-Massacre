extends Area3D

# Références aux effets
@onready var confetti = $ConfettiParticles
@onready var victory_light = $VictoryLight
@onready var ambient_light = $AmbientLight  # Si tu l'as créée

# État
var victory_triggered = false
var celebration_duration = 4.0  # Durée de la célébration avant téléportation

func _ready():
	# Connecter le signal de détection
	body_entered.connect(_on_body_entered)
	
	# S'assurer que les effets sont cachés au départ
	if victory_light:
		victory_light.visible = false
	if ambient_light:
		ambient_light.visible = false

func _on_body_entered(body):
	# Vérifier que c'est le joueur ET qu'on n'a pas déjà déclenché
	if body.is_in_group("player") and !victory_triggered:
		victory_triggered = true
		print("VICTOIRE ! (fausse...)")
		_start_victory_celebration()

func _start_victory_celebration():
	# Bloquer le joueur (optionnel)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_locked = true  # Empêche de bouger pendant la célébration
	
	# Lancer les effets
	_trigger_effects()
	
	# Attendre puis téléporter
	await get_tree().create_timer(celebration_duration).timeout
	_teleport_to_void()

func _trigger_effects():
	# Activer les confettis
	if confetti:
		confetti.emitting = true
		print("Confettis lancés !")
	
	# Activer les lumières
	if victory_light:
		victory_light.visible = true
		_animate_light(victory_light)
	
	if ambient_light:
		ambient_light.visible = true
		_animate_light(ambient_light)
	
	# TODO : Ajouter musique de victoire ici plus tard
	# $VictoryMusic.play()

func _animate_light(light: Light3D):
	# Animation pulsante de la lumière
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(light, "light_energy", light.light_energy * 1.5, 0.5)
	tween.tween_property(light, "light_energy", light.light_energy, 0.5)

func _teleport_to_void():
	print("Téléportation vers le vide...")
	# Charger la scène du vide
	get_tree().change_scene_to_file("res://scenes/fin_1_void.tscn")
