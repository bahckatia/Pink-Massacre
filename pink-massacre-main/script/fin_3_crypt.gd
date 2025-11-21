extends Node3D

# Références aux clones
@onready var clones = [
	$Clone1,
	$Clone2,
	$Clone3,
	$Clone4,
	$Clone5
]

@onready var dialogue_ui = $DialogueUI
@onready var dialogue_text = $DialogueUI/DialogueBox/DialogueText

# Configuration
var dialogue_message = "You will never leave this place."
var dialogue_duration = 3.5

func _ready():
	# Lancer l'animation idle pour tous les clones
	for clone in clones:
		if clone:
			var anim_player = clone.get_node_or_null("AnimationPlayer")
			if anim_player and anim_player.has_animation("idle"):
				anim_player.play("idle")
	
	_start_cinematic()

func _start_cinematic():
	print("🎬 FIN 3 : The Crypt")
	
	# Attente initiale
	await get_tree().create_timer(2.0).timeout
	
	# Afficher le dialogue
	await get_tree().create_timer(0.5).timeout
	_show_dialogue()
	await get_tree().create_timer(dialogue_duration).timeout
	
	# Fade
	_fade_to_end()


func _show_dialogue():
	dialogue_ui.visible = true
	dialogue_text.text = ""
	
	# Effet typewriter
	for i in range(dialogue_message.length()):
		dialogue_text.text += dialogue_message[i]
		await get_tree().create_timer(0.05).timeout

func _fade_to_end():
	print("🌑 Fade to black...")
	
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.modulate.a = 0.0
	dialogue_ui.add_child(fade)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 2.0)
	await tween.finished
	
	print("🏁 END 3 complete")
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
