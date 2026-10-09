class_name MazeGenerator
extends RefCounted

## Genera laberintos procedurales estilo Pacman y valida su conectividad.
## Algoritmo: recursive backtracker (celdas impares) + braid para crear bucles.

const WALL := 0
const OPEN := 1

var width: int = 15
var height: int = 15
var grid: Array = []          # grid[y][x] = WALL | OPEN
var spawn: Vector2i = Vector2i(1, 1)
var rng := RandomNumberGenerator.new()


## Genera un laberinto válido. Devuelve true si la conectividad se valida.
## seed_value < 0 usa semilla aleatoria.
func generate(config: MazeConfig, seed_value: int = -1) -> bool:
	width = config.width if config.width % 2 == 1 else config.width + 1
	height = config.height if config.height % 2 == 1 else config.height + 1
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()
	_carve()
	_braid(config.braid_ratio)
	return validate_connectivity()


## Genera reintentando con nuevas semillas hasta lograr conectividad.
func generate_with_retry(config: MazeConfig, max_attempts: int = 20) -> bool:
	for attempt in range(max_attempts):
		var seed_value: int = config.base_seed + attempt if config.base_seed != 0 else -1
		if generate(config, seed_value):
			return true
	return false


func _init_grid() -> void:
	grid = []
	for y in range(height):
		var row: Array[int] = []
		for x in range(width):
			row.append(WALL)
		grid.append(row)


func _carve() -> void:
	_init_grid()
	var start := Vector2i(1, 1)
	grid[start.y][start.x] = OPEN
	var stack: Array[Vector2i] = [start]
	var dirs: Array[Vector2i] = [Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, 2), Vector2i(0, -2)]
	while not stack.is_empty():
		var current: Vector2i = stack[-1]
		var neighbors: Array[Vector2i] = []
		for d in dirs:
			var n: Vector2i = current + d
			if n.x > 0 and n.x < width - 1 and n.y > 0 and n.y < height - 1 and grid[n.y][n.x] == WALL:
				neighbors.append(n)
		if neighbors.is_empty():
			stack.pop_back()
		else:
			var next: Vector2i = neighbors[rng.randi_range(0, neighbors.size() - 1)]
			var between: Vector2i = (current + next) / 2
			grid[between.y][between.x] = OPEN
			grid[next.y][next.x] = OPEN
			stack.append(next)
	spawn = start


func _braid(ratio: float) -> void:
	var dirs: Array[Vector2i] = [Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, 2), Vector2i(0, -2)]
	for y in range(1, height - 1):
		for x in range(1, width - 1):
			if grid[y][x] != OPEN:
				continue
			if _open_neighbor_count(Vector2i(x, y)) != 1:
				continue
			if rng.randf() > ratio:
				continue
			dirs.shuffle()
			for d in dirs:
				var n: Vector2i = Vector2i(x, y) + d
				if n.x > 0 and n.x < width - 1 and n.y > 0 and n.y < height - 1:
					var between: Vector2i = Vector2i(x, y) + d / 2
					grid[between.y][between.x] = OPEN
					grid[n.y][n.x] = OPEN
					break


func _open_neighbor_count(cell: Vector2i) -> int:
	var c := 0
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var n: Vector2i = cell + d
		if n.x >= 0 and n.x < width and n.y >= 0 and n.y < height and grid[n.y][n.x] == OPEN:
			c += 1
	return c


## Flood-fill desde el spawn: toda celda OPEN debe ser alcanzable.
func validate_connectivity() -> bool:
	var total_open := 0
	for y in range(height):
		for x in range(width):
			if grid[y][x] == OPEN:
				total_open += 1
	var visited := {}
	var queue: Array[Vector2i] = [spawn]
	visited[spawn] = true
	var count := 0
	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		count += 1
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + d
			if n.x >= 0 and n.x < width and n.y >= 0 and n.y < height and grid[n.y][n.x] == OPEN and not visited.has(n):
				visited[n] = true
				queue.append(n)
	return count == total_open


func is_open(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.x >= width or cell.y < 0 or cell.y >= height:
		return false
	return grid[cell.y][cell.x] == OPEN


func open_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in range(height):
		for x in range(width):
			if grid[y][x] == OPEN:
				cells.append(Vector2i(x, y))
	return cells


## Celdas abiertas para enemigos, a distancia >= min_distance del spawn.
func pick_enemy_cells(count: int, min_distance: int) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = []
	for c in open_cells():
		if c != spawn and c.distance_to(spawn) >= float(min_distance):
			candidates.append(c)
	candidates.shuffle()
	var result: Array[Vector2i] = []
	for i in range(min(count, candidates.size())):
		result.append(candidates[i])
	return result
