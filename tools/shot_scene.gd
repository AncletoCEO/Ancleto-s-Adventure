extends Node
func _ready() -> void:
	var v := 2
	if OS.has_environment("VARIANT"): v = int(OS.get_environment("VARIANT"))
	var out := "res://shots/world.png"
	if OS.has_environment("OUT"): out = OS.get_environment("OUT")
	GameManager.selected_variant = v
	var world: Node = load("res://scenes/World.tscn").instantiate()
	add_child(world)
	for i in range(15): await get_tree().process_frame
	Input.action_press("move_up")
	for i in range(35): await get_tree().process_frame
	Input.action_release("move_up")
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(out)
	print("SHOT v%d saved %s" % [v, out])
	get_tree().quit()
