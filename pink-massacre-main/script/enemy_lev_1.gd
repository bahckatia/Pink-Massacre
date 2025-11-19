extends CharacterBody3D

var player = null
var hp = 25.0
var state_machine

const SPEED = 3.8
const ATTACK_RANGE = 2.0
const DAMAGE = 2.0

@export var player_path : NodePath

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var collisionshape = $CollisionShape3D

func _ready() -> void:
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")

func _physics_process(_delta: float) -> void:
	match state_machine.get_current_node():
		"idle":
			anim_tree.set("parameters/conditions/running", true)
		"running":
			velocity = Vector3.ZERO
			nav_agent.set_target_position(player.global_position)
			var next_nav_point = nav_agent.get_next_path_position() 
			velocity = (next_nav_point - global_position).normalized() * SPEED
			
			look_at(Vector3(next_nav_point.x, global_position.y, next_nav_point.z),Vector3.UP)
			anim_tree.set("parameters/conditions/attack", target_in_range())
			move_and_slide()
		"attack":
			anim_tree.set("parameters/conditions/running", !target_in_range())
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z),Vector3.UP)
		"hit_reaction":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z),Vector3.UP)
			anim_tree.set("parameters/conditions/hit_reaction", false)
		"dying":
			collisionshape.disabled = true

func hit_player():
	if target_in_range:
		var dir = global_position.direction_to(player.global_position)
		player.hit(DAMAGE, dir)
		
func hit(damage):
	hp -= damage
	if hp <= 0 :
		anim_tree.set("parameters/conditions/dying",true)
	else :
		anim_tree.set("parameters/conditions/hit_reaction",true)
			
func target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
