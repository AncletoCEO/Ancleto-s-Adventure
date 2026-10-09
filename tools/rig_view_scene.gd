extends Node3D

## Vista rápida de un GLB riggeado para validar skinning. Uso:
## godot --path . res://tools/RigView.tscn

@export var model_path := "res://assets/models/Ancleto3_rigged.glb"

func _ready() -> void:
	var inst: Node3D = load(model_path).instantiate()
	add_child(inst)
	ModelUtil.fit_height(inst, 2.0)
	var cam := Camera3D.new()
	add_child(cam)
	cam.position = Vector3(0, 1.6, 4.5)
	cam.look_at(Vector3(0, 1.0, 0))
	cam.current = true
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-40, -35, 0)
	light.light_energy = 1.3
	add_child(light)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.1, 0.1, 0.12)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_energy = 0.7
	env.environment = e
	add_child(env)
	for i in range(20):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://shots/rig_view.png")
	print("RIG_VIEW saved shots/rig_view.png")
	get_tree().quit()
