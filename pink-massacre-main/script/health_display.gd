extends Control


# ========== CONFIGURATION ==========
@export var max_health: int = 40           # PV maximum
@export var health_per_heart: int = 4      # PV par cœur
@export var hearts_per_row: int = 99       # Nombre max par rangée (99 = tous sur 1 ligne)
@export var heart_size: Vector2 = Vector2(40, 40)      # Taille d'un cœur
@export var heart_spacing: Vector2 = Vector2(48, 50)   # Espacement entre cœurs

# ========== RÉFÉRENCES ==========
@onready var heart_template = $HeartTemplate

# ========== VARIABLES INTERNES ==========
var current_health: int
var heart_containers: Array[TextureRect] = []

# ========== INITIALISATION ==========
func _ready():
	current_health = max_health
	heart_template.visible = false  # Cache le template
	_create_hearts()
	_update_display()

# ========== CRÉATION DES CŒURS ==========
func _create_hearts():
	var total_hearts = ceil(float(max_health) / float(health_per_heart))
	
	for i in range(total_hearts):
		# Dupliquer le template
		var heart = heart_template.duplicate()
		heart.visible = true
		add_child(heart)
		
		# Calculer la position dans la grille
		var row = i / hearts_per_row
		var col = i % hearts_per_row
		heart.position = Vector2(
			col * heart_spacing.x,
			row * heart_spacing.y
		)
		
		# Ajouter à la liste
		heart_containers.append(heart)
	
	print("Created ", total_hearts, " hearts")

# ========== MISE À JOUR VISUELLE ==========
func _update_display():
	var hearts_to_show = ceil(float(current_health) / float(health_per_heart))
	
	for i in range(heart_containers.size()):
		if i < hearts_to_show:
			# Cœur plein
			heart_containers[i].modulate = Color.WHITE
			heart_containers[i].modulate.a = 1.0
		else:
			# Cœur vide (grisé et transparent)
			heart_containers[i].modulate = Color(0.2, 0.2, 0.2, 0.4)

# ========== PRENDRE DES DÉGÂTS ==========
func take_damage(amount: int):
	current_health = max(0, current_health - amount)
	print("Damage taken! HP: ", current_health, "/", max_health)
	
	_update_display()
	_animate_damage()
	
	if current_health <= 0:
		_on_death()

# ========== SE SOIGNER ==========
func heal(amount: int):
	var old_health = current_health
	current_health = min(max_health, current_health + amount)
	
	if current_health > old_health:
		print("Healed! HP: ", current_health, "/", max_health)
		_update_display()
		_animate_heal()

# ========== ANIMATION DÉGÂTS ==========
func _animate_damage():
	# Flash rouge sur tous les cœurs
	var tween = create_tween()
	tween.set_parallel(true)
	
	for heart in heart_containers:
		tween.tween_property(heart, "modulate", Color.RED, 0.1)
	
	tween.chain()
	tween.set_parallel(true)
	
	# Retour à la couleur normale
	var hearts_filled = ceil(float(current_health) / float(health_per_heart))
	for i in range(heart_containers.size()):
		var target_color: Color
		if i < hearts_filled:
			target_color = Color.WHITE
		else:
			target_color = Color(0.2, 0.2, 0.2, 0.4)
		
		tween.tween_property(heart_containers[i], "modulate", target_color, 0.2)

# ========== ANIMATION SOIN ==========
func _animate_heal():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Agrandissement
	for heart in heart_containers:
		tween.tween_property(heart, "scale", Vector2(1.3, 1.3), 0.15)
	
	tween.chain()
	tween.set_parallel(true)
	
	# Retour à la normale
	for heart in heart_containers:
		tween.tween_property(heart, "scale", Vector2.ONE, 0.15)

# ========== MORT DU JOUEUR ==========
func _on_death():
	print("💀 PLAYER IS DEAD!")
	# Flash final
	var tween = create_tween()
	for heart in heart_containers:
		tween.tween_property(heart, "modulate", Color.BLACK, 0.5)
	
	# TODO : Ajouter écran de game over, respawn, etc.

# ========== FONCTIONS PUBLIQUES ==========
func get_current_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health

func is_dead() -> bool:
	return current_health <= 0
