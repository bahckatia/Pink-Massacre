extends Node3D

# Références
@onready var debug_npc = $DebugNPC
@onready var npc_animation = $DebugNPC/AnimationPlayer
@onready var dialogue_ui = $DialogueUI
@onready var dialogue_text = $DialogueUI/DialogueBox/DialogueText

# Configuration
var dialogue_message = "You shouldn't have found this place."
var dialogue_duration = 5.0

func _ready():
	# Lancer la cinématique
	_start_cinematic()

func _start_cinematic():
	print("FIN 4 : Debug Room")
	
	# Attente initiale
	await get_tree().create_timer(1.5).timeout
	
	# 1. Le NPC se retourne
	_npc_turn_around()
	var turn_duration = _get_animation_length("turn_around")
	await get_tree().create_timer(turn_duration).timeout
	
	# 3. Afficher le dialogue
	_show_dialogue()
	await get_tree().create_timer(dialogue_duration).timeout
	
	# 4. Fade
	_fade_to_end()

func _npc_turn_around():
	print("🔄 Le NPC se retourne...")
	if npc_animation and npc_animation.has_animation("turn_around"):
		npc_animation.play("turn_around")
	else:
		print("⚠️ Animation 'turn_around' introuvable!")
		# Fallback : rotation manuelle
		if debug_npc:
			var tween = create_tween()
			tween.tween_property(debug_npc, "rotation:y", 0, 1.0)


func _get_animation_length(anim_name: String) -> float:
	if npc_animation and npc_animation.has_animation(anim_name):
		return npc_animation.get_animation(anim_name).length
	return 1.0  # Durée par défaut

func _show_dialogue():
	dialogue_ui.visible = true
	dialogue_text.text = ""
	
	# Effet typewriter
	for i in range(dialogue_message.length()):
		dialogue_text.text += dialogue_message[i]
		await get_tree().create_timer(0.05).timeout


func _fade_to_end():
	print("Fade to black...")
	
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.modulate.a = 0.0
	dialogue_ui.add_child(fade)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 2.0)
	await tween.finished
	
	print("FIN 4 ")
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
