extends CharacterBody3D

## Ancleto: tercera persona con mouse look + movimiento relativo a la cámara.

@export var speed: float = 6.0
@export var invulnerability_time: float = 1.5
@export var mouse_sensitivity: float = 0.0025
@export var min_pitch_deg: float = -70.0
@export var max_pitch_deg: float = 30.0

var invulnerable := false
var spawn_position := Vector3.ZERO

@onready var model_pivot: Node3D = $ModelPivot
@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D

var _model: Node3D
var _model_base_y := 0.0
var _skeleton: Skeleton3D
var _walk_phase := 0.0


func _ready() -> void:
	add_to_group("player")
	spawn_position = global_position
	_load_variant(GameManager.selected_variant)
	model_pivot.rotation.y = PI  # el modelo mira hacia +Z; que mire hacia el frente de la cámara (-Z)
	_setup_camera()


func _setup_camera() -> void:
	camera_pivot.position = Vector3(0, 1.3, 0)
	spring_arm.rotation = Vector3(deg_to_rad(-18.0), 0.0, 0.0)
	spring_arm.spring_length = 5.0
	spring_arm.collision_mask = 1
	camera.rotation = Vector3.ZERO
	camera.current = true
	if DisplayServer.get_name() != "headless":
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		spring_arm.rotation.x = clampf(
			spring_arm.rotation.x - event.relative.y * mouse_sensitivity,
			deg_to_rad(min_pitch_deg),
			deg_to_rad(max_pitch_deg)
		)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _load_variant(index: int) -> void:
	for c in model_pivot.get_children():
		c.queue_free()
	var path := "res://assets/models/Ancleto%d.glb" % (index + 1)
	var packed: PackedScene = load(path)
	if packed == null:
		push_warning("No se pudo cargar la variante %s" % path)
		return
	_model = packed.instantiate()
	model_pivot.add_child(_model)
	ModelUtil.fit_height(_model, 1.7)
	_model_base_y = _model.position.y
	_skeleton = RigPose.find_skeleton(_model)
	RigPose.apply(_skeleton, false, 0.0)


func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input.length() > 0.01:
		var basis := camera_pivot.global_transform.basis
		var forward := -basis.z
		forward.y = 0.0
		forward = forward.normalized()
		var right := basis.x
		right.y = 0.0
		right = right.normalized()
		var move_dir := right * input.x + forward * (-input.y)
		if move_dir.length() > 0.01:
			move_dir = move_dir.normalized()
			velocity.x = move_dir.x * speed
			velocity.z = move_dir.z * speed
			var target_y := atan2(move_dir.x, move_dir.z)
			model_pivot.rotation.y = lerp_angle(model_pivot.rotation.y, target_y, 0.25)
			model_pivot.rotation.z = lerp(model_pivot.rotation.z, deg_to_rad(6.0), 0.15)
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)
		model_pivot.rotation.z = lerp(model_pivot.rotation.z, 0.0, 0.15)
	velocity.y = 0.0
	move_and_slide()
	var moving := input.length() > 0.01
	if moving:
		_walk_phase += delta * 9.0
	RigPose.apply(_skeleton, moving, _walk_phase)

func take_hit() -> void:
	if invulnerable:
		return
	GameManager.damage_player()
	global_position = spawn_position
	velocity = Vector3.ZERO
	_start_invulnerability()


func _start_invulnerability() -> void:
	invulnerable = true
	var elapsed := 0.0
	while elapsed < invulnerability_time:
		visible = not visible
		await get_tree().create_timer(0.15).timeout
		elapsed += 0.15
	visible = true
	invulnerable = false
