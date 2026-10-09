extends Area3D

## Taza de café recolectable (modelo CC0 de Kenney). Al tocar el jugador,
## decrementa el contador.

const CUP_MODEL := preload("res://assets/models/coffee_cup.glb")

@export var spin_speed: float = 2.0

var _t := 0.0
var _base_y := 0.55


func _ready() -> void:
	add_to_group("coffee")
	body_entered.connect(_on_body_entered)
	_build_model()


func _build_model() -> void:
	var inst: Node3D = CUP_MODEL.instantiate()
	add_child(inst)
	ModelUtil.fit_height(inst, 0.5)


func _process(delta: float) -> void:
	_t += delta
	rotate_y(spin_speed * delta)
	position.y = _base_y + sin(_t * 3.0) * 0.1


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		GameManager.collect_cup()
		queue_free()
