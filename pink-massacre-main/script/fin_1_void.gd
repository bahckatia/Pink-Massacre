extends Node3D

# Références
@onready var npc = $NPC  # Change si ton NPC a un autre nom
@onready var npc_animation = $NPC/AnimationPlayer  # Ajuste le chemin si nécessaire
@onready var dialogue_ui = $DialogueUI
@onready var dialogue_text = $DialogueUI/DialogueBox/DialogueText
@onready var dramatic_light = $DramaticLight

# Configuration
var dialogue_message = "Do you really think you will get out one day? \n Perhaps there are other things to explore..."
var tension_delay = 1.5  # Temps avant que le PNJ bouge
var dialogue_delay = 0.5  # Délai après qu'il se lève avant le texte
var dialogue_duration = 8.0  # Temps d'affichage du message

func _ready():
	# S'assurer que le PNJ est dans la bonne pose au départ
	if npc_animation:
		# Jouer l'animation "idle" en position assise (frame 0)
		if npc_animation.has_animation("sit_to_idle"):
			npc_animation.play("sit_to_idle")
			npc_animation.seek(0.0, true)  # Va au début et pause
			npc_animation.pause()
				
	# Lancer la cinématique
	_start_cinematic()


func _start_cinematic():
	print("🎬 Début de la cinématique")
	await get_tree().create_timer(tension_delay).timeout
	
	# 2. Le PNJ se lève (animation sit_to_idle)
	_npc_stand_up()
	
	# Attendre la fin de l'animation sit_to_idle
	var sit_to_idle_duration = _get_animation_length("sit_to_idle")
	await get_tree().create_timer(sit_to_idle_duration).timeout
	
	# 3. Lancer l'animation idle en boucle
	_npc_idle()
	
	# 4. Petit délai puis afficher le dialogue
	await get_tree().create_timer(dialogue_delay).timeout
	_show_dialogue()
	
	# 5. Attendre la fin du dialogue
	await get_tree().create_timer(dialogue_duration).timeout
	
	# 6. Fade out et respawn
	_fade_and_respawn()

func _npc_stand_up():
	print("🧍 Le PNJ se lève...")
	
	if npc_animation and npc_animation.has_animation("sit_to_idle"):
		npc_animation.play("sit_to_idle")
	else:
		print("⚠️ Animation 'sit_to_idle' introuvable!")
	
	# Flash de lumière quand il commence à bouger
	_flash_light_subtle()

func _npc_idle():
	print("👤 Le PNJ est debout (idle)")
	
	if npc_animation and npc_animation.has_animation("idle"):
		npc_animation.play("idle")
	else:
		print("⚠️ Animation 'idle' introuvable!")

func _get_animation_length(anim_name: String) -> float:
	# Récupère la durée de l'animation
	if npc_animation and npc_animation.has_animation(anim_name):
		var animation = npc_animation.get_animation(anim_name)
		return animation.length
	return 2.0  # Valeur par défaut si on ne trouve pas

func _show_dialogue():
	# Afficher l'UI
	dialogue_ui.visible = true
	dialogue_text.text = ""
	
	# Effet de texte qui s'écrit lettre par lettre
	_typewriter_effect(dialogue_message)
	
	# Animation de flash sur la lumière
	_flash_light()
	
	print("💬 Dialogue affiché")

func _typewriter_effect(text: String):
	# Écrire le texte progressivement
	for i in range(text.length()):
		dialogue_text.text += text[i]
		await get_tree().create_timer(0.05).timeout  # Vitesse d'écriture

func _flash_light():
	# Flash intense quand le texte apparaît
	if dramatic_light:
		var tween = create_tween()
		tween.tween_property(dramatic_light, "light_energy", 5.0, 0.3)
		tween.tween_property(dramatic_light, "light_energy", 3.0, 0.3)

func _flash_light_subtle():
	# Flash subtil quand le PNJ bouge
	if dramatic_light:
		var tween = create_tween()
		tween.tween_property(dramatic_light, "light_energy", 4.0, 0.5)
		tween.tween_property(dramatic_light, "light_energy", 3.0, 0.5)

func _fade_and_respawn():
	print("🌑 Fade to black...")
	
	# Créer un fade noir
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.modulate.a = 0.0
	$DialogueUI.add_child(fade)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 2.0)
	
	await tween.finished
	
	# Respawn dans le labyrinthe
	_respawn_in_labyrinth()

func _respawn_in_labyrinth():
	print("🔄 Respawn dans le labyrinthe")
	
	# IMPORTANT : Change ce chemin vers ta scène de labyrinthe
	get_tree().change_scene_to_file("res://scenes/game.tscn")
