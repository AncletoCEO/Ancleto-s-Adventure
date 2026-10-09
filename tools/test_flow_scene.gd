extends Node

## Verificación headless del flujo Main: selección -> juego -> game over -> reinicio.
## Uso: godot --headless --path . res://tools/TestFlow.tscn

func _ready() -> void:
	var main: Node = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	await _frames(5)

	var sel := main.get_node_or_null("CharacterSelect")
	print("FLOW select=%s" % str(sel != null))

	GameManager.selected_variant = 1
	if sel and sel.has_signal("confirmed"):
		sel.confirmed.emit()
	await _frames(6)
	var world := main.get_node_or_null("World")
	print("FLOW world=%s" % str(world != null))
	if world and world.player:
		var pivot: Node = world.player.get_node_or_null("ModelPivot")
		var model: Node = pivot.get_child(0) if pivot and pivot.get_child_count() > 0 else null
		print("FLOW variant_model=%s" % (model.name if model else "<none>"))

	# Fin de partida
	GameManager.lives = 1
	GameManager.damage_player()
	await _frames(6)
	var over := main.get_node_or_null("GameOver")
	print("FLOW gameover_screen=%s" % str(over != null))

	# Reinicio
	if over and over.has_signal("restart"):
		over.restart.emit()
	await _frames(6)
	var world2 := main.get_node_or_null("World")
	print("FLOW restart_world=%s lives=%d level=%d" % [str(world2 != null), GameManager.lives, GameManager.level])

	get_tree().quit()


func _frames(n: int) -> void:
	for i in range(n):
		await get_tree().process_frame
