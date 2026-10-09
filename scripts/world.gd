extends Node3D

## Construye un nivel: laberinto procedural, piso, muros, tazas, enemigos,
## navmesh, jugador, cámara cenital y HUD.

const CELL_SIZE := 3.0
const WALL_HEIGHT := 3.0

const CUP_SCENE := preload("res://scenes/pickups/CoffeeCup.tscn")
const ENEMY_SCENE := preload("res://scenes/enemies/Enemy.tscn")
const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const HUD_SCENE := preload("res://scenes/HUD.tscn")

@export var maze_config: MazeConfig

var generator: MazeGenerator
var player: CharacterBody3D

var _maze_root: Node3D
var _nav_region: NavigationRegion3D
var _nav_ok := false
var _cup_count := 0


func _ready() -> void:
	if maze_config == null:
		maze_config = load("res://resources/maze_config.tres")
	GameManager.world = self
	GameManager.level_cleared.connect(_on_level_cleared)
	generate_level()


func _on_level_cleared() -> void:
	GameManager.advance_level()
	generate_level()


func generate_level() -> void:
	_clear()
	generator = MazeGenerator.new()
	if not generator.generate_with_retry(maze_config):
		push_error("No se pudo generar un laberinto conectado")
		return
	_build_maze()
	_build_environment()
	_spawn_player()
	_build_navmesh()
	_spawn_enemies()
	_place_cups()
	_build_hud()
	GameManager.set_cups(_cup_count)
	GameManager.level_changed.emit(GameManager.level)


func _clear() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()


func _cell_to_world(cell: Vector2i) -> Vector3:
	return Vector3(
		(cell.x - generator.width * 0.5 + 0.5) * CELL_SIZE,
		0.0,
		(cell.y - generator.height * 0.5 + 0.5) * CELL_SIZE
	)


func _build_maze() -> void:
	_maze_root = Node3D.new()
	_maze_root.name = "Maze"
	add_child(_maze_root)

	# Piso
	var floor_body := StaticBody3D.new()
	floor_body.name = "Floor"
	floor_body.collision_layer = 1
	floor_body.collision_mask = 0
	var floor_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(generator.width * CELL_SIZE, 1.0, generator.height * CELL_SIZE)
	floor_shape.shape = box
	floor_body.add_child(floor_shape)
	var floor_mesh := MeshInstance3D.new()
	var fbox := BoxMesh.new()
	fbox.size = box.size
	floor_mesh.mesh = fbox
	floor_mesh.position.y = -0.5
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.18, 0.19, 0.22)
	floor_mesh.material_override = floor_mat
	floor_body.add_child(floor_mesh)
	_maze_root.add_child(floor_body)

	# Muros
	var walls := Node3D.new()
	walls.name = "Walls"
	_maze_root.add_child(walls)
	var wall_mesh_res := BoxMesh.new()
	wall_mesh_res.size = Vector3(CELL_SIZE, WALL_HEIGHT, CELL_SIZE)
	var wall_mat := StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.28, 0.45, 0.85)
	for y in range(generator.height):
		for x in range(generator.width):
			if generator.grid[y][x] != MazeGenerator.OPEN:
				var body := StaticBody3D.new()
				body.collision_layer = 1
				body.collision_mask = 0
				var shape := CollisionShape3D.new()
				var sb := BoxShape3D.new()
				sb.size = wall_mesh_res.size
				shape.shape = sb
				body.add_child(shape)
				var mi := MeshInstance3D.new()
				mi.mesh = wall_mesh_res
				mi.material_override = wall_mat
				body.add_child(mi)
				body.position = _cell_to_world(Vector2i(x, y)) + Vector3(0, WALL_HEIGHT * 0.5, 0)
				walls.add_child(body)


func _build_environment() -> void:
	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.06, 0.09)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.85, 0.88, 1.0)
	env.ambient_light_energy = 0.7
	world_env.environment = env
	add_child(world_env)

	var light := DirectionalLight3D.new()
	light.name = "SunLight"
	light.rotation_degrees = Vector3(-55, -35, 0)
	light.light_energy = 1.1
	light.shadow_enabled = true
	add_child(light)


func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	player.global_position = _cell_to_world(generator.spawn)
	GameManager.player = player


func _build_navmesh() -> void:
	_nav_region = NavigationRegion3D.new()
	_nav_region.name = "NavigationRegion3D"
	var nav_mesh := NavigationMesh.new()
	nav_mesh.agent_radius = 0.5
	nav_mesh.cell_size = 0.25
	nav_mesh.cell_height = 0.25
	nav_mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	nav_mesh.geometry_source_geometry_mode = NavigationMesh.SOURCE_GEOMETRY_ROOT_NODE_CHILDREN
	_nav_region.navigation_mesh = nav_mesh
	add_child(_nav_region)
	_maze_root.reparent(_nav_region)
	_nav_region.bake_navigation_mesh(false)
	_nav_ok = nav_mesh.get_polygon_count() > 0
	if not _nav_ok:
		push_warning("Navmesh vacío; los enemigos usarán steering directo")


func _spawn_enemies() -> void:
	var count := GameManager.enemy_count()
	var cells := generator.pick_enemy_cells(count, maze_config.min_enemy_distance)
	var container := Node3D.new()
	container.name = "Enemies"
	add_child(container)
	for cell in cells:
		var enemy: CharacterBody3D = ENEMY_SCENE.instantiate()
		container.add_child(enemy)
		enemy.global_position = _cell_to_world(cell)
		enemy.target = player
		enemy.nav_ready = _nav_ok
		enemy.speed = 2.5 + 0.15 * float(GameManager.level - 1)


func _place_cups() -> void:
	var container := Node3D.new()
	container.name = "CoffeeCups"
	add_child(container)
	_cup_count = 0
	for cell in generator.open_cells():
		if cell == generator.spawn:
			continue
		var cup: Area3D = CUP_SCENE.instantiate()
		container.add_child(cup)
		cup.global_position = _cell_to_world(cell)
		_cup_count += 1


func _build_hud() -> void:
	add_child(HUD_SCENE.instantiate())
