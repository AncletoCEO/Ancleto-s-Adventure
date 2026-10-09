extends Node

## Verificación headless del mundo corriendo como escena (con autoloads).
## Uso: godot --headless --path . res://tools/TestWorld.tscn

func _ready() -> void:
	var world: Node = load("res://scenes/World.tscn").instantiate()
	add_child(world)
	for i in range(5):
		await get_tree().process_frame
	var cups := world.get_node_or_null("CoffeeCups")
	var enemies := world.get_node_or_null("Enemies")
	var nav := world.get_node_or_null("NavigationRegion3D")
	var cup_n: int = cups.get_child_count() if cups else -1
	var enemy_n: int = enemies.get_child_count() if enemies else -1
	var polys: int = nav.navigation_mesh.get_polygon_count() if nav else -1
	print("TEST_WORLD cups=%d enemies=%d navpolys=%d player=%s lives=%d level=%d" % [
		cup_n, enemy_n, polys, str(world.player != null), GameManager.lives, GameManager.level
	])
	if world.player:
		var cam: Node3D = world.player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D")
		if cam:
			var rel: Vector3 = cam.global_position - world.player.global_position
			var fwd: Vector3 = -cam.global_transform.basis.z
			print("TEST_CAM rel=(%.1f,%.1f,%.1f) forward=(%.2f,%.2f,%.2f)" % [rel.x, rel.y, rel.z, fwd.x, fwd.y, fwd.z])
	get_tree().quit()
