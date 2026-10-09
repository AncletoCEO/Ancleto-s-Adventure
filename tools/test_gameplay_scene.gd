extends Node

## Verificación headless del bucle de juego.
## Uso: godot --headless --path . res://tools/TestGameplay.tscn

var _game_over_fired := false


func _ready() -> void:
	GameManager.game_over.connect(func() -> void: _game_over_fired = true)
	var world: Node = load("res://scenes/World.tscn").instantiate()
	add_child(world)
	await _frames(5)

	# 1) Recoger una taza
	var start_cups := GameManager.cups_remaining
	var cup := world.get_node("CoffeeCups").get_child(0)
	cup._on_body_entered(world.player)
	await _frames(2)
	print("GAMEPLAY collect_one cups %d -> %d (esperado %d)" % [start_cups, GameManager.cups_remaining, start_cups - 1])

	# 2) Limpiar nivel (dejar 1 taza y recogerla) -> sube nivel y regenera mapa
	GameManager.set_cups(1)
	GameManager.collect_cup()
	await _frames(5)
	print("GAMEPLAY level_clear level=%d cups=%d (esperado level=2, cups>0)" % [GameManager.level, GameManager.cups_remaining])

	# 3) Un golpe del jugador: pierde vida y queda invulnerable
	GameManager.lives = 3
	world.player.invulnerable = false
	world.player.take_hit()
	await _frames(2)
	print("GAMEPLAY take_hit lives=%d invuln=%s (esperado 2, true)" % [GameManager.lives, str(world.player.invulnerable)])

	# 4) Agotar vidas -> game over
	world.player.invulnerable = false
	GameManager.damage_player()
	GameManager.damage_player()
	await _frames(2)
	print("GAMEPLAY game_over=%s lives=%d (esperado true, 0)" % [str(_game_over_fired), GameManager.lives])

	get_tree().quit()


func _frames(n: int) -> void:
	for i in range(n):
		await get_tree().process_frame
