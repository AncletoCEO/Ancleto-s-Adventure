class_name RigPose
extends RefCounted

## Locomoción procedural sobre el rig generado por skin-tokens (28 huesos,
## ejes locales = mundo). Compartido por el jugador y la pantalla de selección.

const B_ARM_R := 7
const B_ARM_L := 14
const B_THIGH_R := 20
const B_SHIN_R := 21
const B_THIGH_L := 24
const B_SHIN_L := 25


static func find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for c in node.get_children():
		var r := find_skeleton(c)
		if r != null:
			return r
	return null


## Aplica idle (moving=false) o caminata (moving=true, con `phase` acumulada).
static func apply(skeleton: Skeleton3D, moving: bool, phase: float) -> void:
	if skeleton == null or skeleton.get_bone_count() <= B_SHIN_L:
		return
	var leg_swing := sin(phase) * deg_to_rad(30.0) if moving else 0.0
	var arm_swing := sin(phase) * deg_to_rad(22.0) if moving else 0.0
	skeleton.set_bone_pose_rotation(B_THIGH_R, Quaternion(Vector3(1, 0, 0), leg_swing))
	skeleton.set_bone_pose_rotation(B_THIGH_L, Quaternion(Vector3(1, 0, 0), -leg_swing))
	skeleton.set_bone_pose_rotation(B_SHIN_R, Quaternion(Vector3(1, 0, 0), maxf(0.0, -leg_swing) * 1.1))
	skeleton.set_bone_pose_rotation(B_SHIN_L, Quaternion(Vector3(1, 0, 0), maxf(0.0, leg_swing) * 1.1))
	skeleton.set_bone_pose_rotation(
		B_ARM_R, Quaternion(Vector3(1, 0, 0), arm_swing) * Quaternion(Vector3(0, 0, 1), deg_to_rad(-78.0))
	)
	skeleton.set_bone_pose_rotation(
		B_ARM_L, Quaternion(Vector3(1, 0, 0), -arm_swing) * Quaternion(Vector3(0, 0, 1), deg_to_rad(78.0))
	)
