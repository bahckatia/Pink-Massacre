extends CharacterBody3D

@onready var camera_player = $camera_player_rpg
@onready var animation_player: AnimationPlayer = $visuals/mixamo_base/AnimationPlayer
@onready var visuals: Node3D = $visuals
@onready var health_display = $PlayerUI/HealthDisplay 

var SPEED = 2.9
const JUMP_VELOCITY = 4.5
const PUSHBACK = 8.0

var walking_speed = 2.9
var running_speed = 5.0 
var currentvel = Vector3.ZERO
var hp = 40
var running = false

var is_locked = false

@export var sens_horizontal = 0.2
@export var sens_vertical = 0.2


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hp = 40

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		visuals.rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		camera_player.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
		
func _physics_process(delta: float) -> void:
		
	if !animation_player.is_playing():
		is_locked = false
		
	if Input.is_action_just_pressed("kick"):
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			is_locked = true
			
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = false
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:	
			if running:
				if animation_player.current_animation != "running":
					animation_player.play("running")
			else:	
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
			visuals.look_at(position + direction)	
			
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !is_locked:	
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if !is_locked:
		move_and_slide()

func hit(damage, dir):
	hp -= damage
	hp = max(0, hp) 
	
	health_display.take_damage(damage)
	
	currentvel += dir * PUSHBACK
	
	if hp <= 0:
		_on_player_death()
		

func _on_player_death():
	print("💀 GAME OVER!")
	is_locked = true  # Bloquer les mouvements
	
	# Animation de mort (optionnel)
	if animation_player.has_animation("death"):
		animation_player.play("death")
	
	await get_tree().create_timer(1.5).timeout
	
	# Charger l'écran de Game Over
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
