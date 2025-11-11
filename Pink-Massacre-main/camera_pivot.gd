extends Node3D

@export var rotation_speed := 5.0 # degrés par seconde
@export var bob_amplitude := 0.5
@export var bob_speed := 1.0
var time := 0.0

func _process(delta):
	time += delta
	rotate_y(deg_to_rad(rotation_speed) * delta)
	position.y = 10 + sin(time * bob_speed) * bob_amplitude
