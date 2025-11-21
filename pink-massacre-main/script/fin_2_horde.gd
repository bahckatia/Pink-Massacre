extends Node3D

# Références aux zombies
@onready var zombies = [
	$Zombie1,
	$Zombie2,
	$Zombie3
]

@onready var dialogue_ui = $DialogueUI
@onready var dialogue_text = $DialogueUI/DialogueBox/DialogueText
@onready var red_overlay = $DialogueUI/RedOverlay  # On va créer ça
@onready var blood_light = $BloodLight

# Configuration
var message_text = "You were nothing but a meal."
var message_duration = 5.0

func _ready():
	# Lancer les animations idle des zombies
	for zombie in zombies:
		if zombie:
			var anim_player = zombie.get_node_or_null("AnimationPlayer")
			if anim_player and anim_player.has_animation("idle"):
				anim_player.play("idle")
	
	_start_cinematic()

func _start_cinematic():
	print("🎬 FIN 2 : The Horde")
	
	# Attente initiale
	await get_tree().create_timer(2.0).timeout
	
	# Les zombies attaquent (animation)
	_zombies_attack()
	await get_tree().create_timer(2.0).timeout
	
	# Flash rouge + message
	_show_death_screen()
	await get_tree().create_timer(message_duration).timeout
	
	# Fade complet
	_fade_to_end()

func _zombies_attack():
	print("🧟 Les zombies attaquent !")
	
	for zombie in zombies:
		if zombie:
			var anim_player = zombie.get_node_or_null("AnimationPlayer")
			if anim_player and anim_player.has_animation("attack"):
				anim_player.play("attack")

func _show_death_screen():
	print("💀 Écran de mort")
	
	# Créer overlay rouge par-dessus tout
	var red_overlay = ColorRect.new()
	red_overlay.color = Color(1, 0, 0, 0)  # Rouge transparent
	dialogue_ui.add_child(red_overlay)
	red_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	red_overlay.z_index = -1  # Derrière le texte
	
	# Flash rouge progressif
	var tween = create_tween()
	tween.tween_property(red_overlay, "color:a", 0.6, 1.0)
	
	# Lumière rouge pulse
	if blood_light:
		var light_tween = create_tween()
		light_tween.set_loops(3)
		light_tween.tween_property(blood_light, "light_energy", 5.0, 0.3)
		light_tween.tween_property(blood_light, "light_energy", 3.0, 0.3)
	
	# Afficher le dialogue
	await get_tree().create_timer(0.5).timeout
	dialogue_ui.visible = true
	_typewriter_effect()

func _typewriter_effect():
	dialogue_text.text = ""
	
	for i in range(message_text.length()):
		dialogue_text.text += message_text[i]
		await get_tree().create_timer(0.05).timeout

func _fade_to_end():
	print("🌑 Fade to black...")
	
	# Créer un fade noir
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.modulate.a = 0.0
	dialogue_ui.add_child(fade)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 2.0)
	await tween.finished
	
	print("🏁 END 2 complete")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/MainMenu.tscn")
