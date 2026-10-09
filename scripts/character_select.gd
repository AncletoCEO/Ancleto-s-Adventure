extends Node3D

## Pantalla de selección de las 3 variantes de Ancleto.

signal confirmed

const VARIANT_COUNT := 3

var _models: Array[Node3D] = []
var _index := 0

var _hint: Label


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_build_camera()
	_build_models()
	_build_ui()
	_highlight()


func _build_camera() -> void:
	var cam := Camera3D.new()
	add_child(cam)
	cam.position = Vector3(0, 3.2, 9)
	cam.look_at(Vector3(0, 1.0, 0))
	cam.current = true
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50, -30, 0)
	light.light_energy = 1.2
	add_child(light)


func _build_models() -> void:
	for i in range(VARIANT_COUNT):
		var packed: PackedScene = load("res://assets/models/Ancleto%d.glb" % (i + 1))
		if packed == null:
			continue
		var inst: Node3D = packed.instantiate()
		add_child(inst)
		ModelUtil.fit_height(inst, 1.7)
		inst.position.x = (i - (VARIANT_COUNT - 1) * 0.5) * 3.5
		RigPose.apply(RigPose.find_skeleton(inst), false, 0.0)
		_models.append(inst)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_hint = Label.new()
	_hint.position = Vector2(40, 40)
	layer.add_child(_hint)


func _highlight() -> void:
	for i in range(_models.size()):
		var target := 2.0 if i == _index else 1.5
		ModelUtil.fit_height(_models[i], target)
		_models[i].position.y = 0.0
	if _hint:
		_hint.text = "Ancleto — variante %d/%d\n← / →  cambiar      Enter / Espacio  jugar" % [_index + 1, VARIANT_COUNT]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select_variant_next") or event.is_action_pressed("move_right"):
		_index = (_index + 1) % VARIANT_COUNT
		_highlight()
	elif event.is_action_pressed("ui_select_variant_prev") or event.is_action_pressed("move_left"):
		_index = (_index - 1 + VARIANT_COUNT) % VARIANT_COUNT
		_highlight()
	elif event.is_action_pressed("ui_confirm"):
		GameManager.selected_variant = _index
		confirmed.emit()
