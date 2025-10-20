extends CharacterBody3D

# === PARAMÈTRES DE MOUVEMENT ===
@export var speed := 6.0
@export var jump_velocity := 8.0
@export var gravity := 20.0

# === CAMÉRA ORBITALE ===
@export var mouse_sensitivity := 0.2
@export var camera_distance := 6.0
@onready var pivot = $Pivot
@onready var camera = $Pivot/CameraRPG

var vel: Vector3 = Vector3.ZERO
var rotation_x := 0.0
var rotation_y := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if camera_locked and event is InputEventMouseMotion:
		# Rotation de la caméra à la souris seulement si elle est bloquée
		rotation_y -= event.relative.x * mouse_sensitivity * 0.01
		rotation_x -= event.relative.y * mouse_sensitivity * 0.01
		rotation_x = clamp(rotation_x, deg_to_rad(-50), deg_to_rad(50))
		pivot.rotation = Vector3(rotation_x, rotation_y, 0)

var camera_locked := false

func _input(event):
	# Basculer le mode souris avec ESC
	if event.is_action_pressed("ui_cancel"): # touche Esc par défaut
		camera_locked = !camera_locked

		if camera_locked:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	_apply_gravity(delta)
	_handle_movement(delta)
	move_and_slide()

func _apply_gravity(delta):
	if not is_on_floor():
		vel.y -= gravity * delta
	else:
		if vel.y < 0:
			vel.y = 0

func _handle_movement(delta):
	var input_dir = Vector3.ZERO

	# WASD ou ZQSD selon ton layout
	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		
		# Transforme la direction selon la caméra
		var camera_basis = pivot.global_transform.basis
		var dir = (camera_basis.x * input_dir.x + camera_basis.z * input_dir.z)
		dir.y = 0
		dir = dir.normalized()

		# Bouge le joueur
		vel.x = dir.x * speed
		vel.z = dir.z * speed

		# Tourne le joueur dans la direction du mouvement
		var target_angle = atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 10.0)
	else:
		vel.x = 0
		vel.z = 0

	# Saut
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vel.y = jump_velocity
