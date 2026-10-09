extends SceneTree

## Test headless: genera 100 laberintos y exige 100% de conectividad.
## Uso: godot --headless --path . --script res://tools/test_maze.gd

func _init() -> void:
	var config := MazeConfig.new()
	config.width = 15
	config.height = 15
	config.braid_ratio = 0.6
	config.min_enemy_distance = 5

	var total := 100
	var failures := 0
	var total_open_cells := 0
	for i in range(total):
		var gen := MazeGenerator.new()
		if not gen.generate(config, i + 1):
			failures += 1
			push_error("Mapa %d no conectado" % i)
		else:
			total_open_cells += gen.open_cells().size()
			# Las tazas se colocan en toda celda abierta salvo spawn -> alcanzables por definición.
			var enemy_cells := gen.pick_enemy_cells(1, config.min_enemy_distance)
			if enemy_cells.is_empty():
				failures += 1
				push_error("Mapa %d sin celda de enemigo válida" % i)

	var avg_open := float(total_open_cells) / float(max(total - failures, 1))
	print("TEST_MAZE: total=%d fallos=%d avg_celdas_abiertas=%.1f" % [total, failures, avg_open])
	quit(0 if failures == 0 else 1)
