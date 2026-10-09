class_name ModelUtil
extends RefCounted

## Utilidades para modelos importados de escala desconocida.


static func _collect_meshes(node: Node, out: Array) -> void:
	if node is MeshInstance3D and node.mesh != null:
		out.append(node)
	for c in node.get_children():
		_collect_meshes(c, out)


## AABB combinada de las mallas, expresada en el espacio local de `root`.
static func local_aabb(root: Node3D) -> AABB:
	var meshes: Array = []
	_collect_meshes(root, meshes)
	if meshes.is_empty():
		return AABB()
	var inv := root.global_transform.affine_inverse()
	var result := AABB()
	var first := true
	for mi in meshes:
		var xf: Transform3D = inv * mi.global_transform
		var aabb: AABB = xf * mi.get_aabb()
		if first:
			result = aabb
			first = false
		else:
			result = result.merge(aabb)
	return result


## Escala `root` para que su altura sea `target_height` y (opcional) apoya su base en y=0.
static func fit_height(root: Node3D, target_height: float, ground: bool = true) -> void:
	var aabb := local_aabb(root)
	if aabb.size.y < 0.0001:
		return
	var s := target_height / aabb.size.y
	root.scale = Vector3(s, s, s)
	if ground:
		root.position.y = -aabb.position.y * s
