extends CharacterBody3D

## Enemigo que persigue al jugador. Usa NavigationAgent3D si hay navmesh;
## si no, cae a persecución por dirección directa (steering).

@export var speed: float = 2.5

const ENEMY_MODEL := preload("res://assets/models/enemy.glb")

var target: Node3D = null

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var hit_area: Area3D = $HitArea
@onready var model_pivot: Node3D = $ModelPivot

var nav_ready := false


func _ready() -> void:
	hit_area.body_entered.connect(_on_body_entered)
	_build_model()


func _build_model() -> void:
	# Modelo CC0 (Slime de Quaternius) con animación si está disponible.
	var inst: Node3D = ENEMY_MODEL.instantiate()
	model_pivot.add_child(inst)
	ModelUtil.fit_height(inst, 1.1)
	_play_loop_animation(inst)


func _play_loop_animation(inst: Node3D) -> void:
	for node in inst.find_children("*", "AnimationPlayer", true, false):
		var ap: AnimationPlayer = node
		var names := ap.get_animation_list()
		if names.is_empty():
			continue
		var chosen: StringName = names[0]
		for n in names:
			var ln := String(n).to_lower()
			if ln.contains("walk") or ln.contains("run") or ln.contains("idle"):
				chosen = n
				break
		ap.play(chosen)
		break


func _physics_process(delta: float) -> void:
	if target == null:
		return
	var desired := _desired_direction()
	if desired.length() > 0.05:
		desired = desired.normalized()
		velocity.x = desired.x * speed
		velocity.z = desired.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)
	velocity.y = 0.0
	move_and_slide()


func _desired_direction() -> Vector3:
	if nav_ready:
		agent.target_position = target.global_position
		if not agent.is_navigation_finished():
			var next := agent.get_next_path_position()
			var d := next - global_position
			d.y = 0.0
			return d
		return Vector3.ZERO
	# Fallback: dirección directa.
	var direct := target.global_position - global_position
	direct.y = 0.0
	return direct


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body.has_method("take_hit"):
		body.take_hit()
