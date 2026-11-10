#ensures all layers are processed/masked correctly per camera
extends Node3D


const GOGGLE_LAYER := 1 << 2
const WORLD_LAYER := 1 << 3

func _ready() -> void:
	var mirror := Node3D.new()
	mirror.name = "GoggleMirror"
	for child in get_children():
		var copy := child.duplicate()
		_make_render_only(copy, GOGGLE_LAYER)
		mirror.add_child(copy)

	_set_layers(self, WORLD_LAYER)
	add_child(mirror)


func _set_layers(node: Node, layer: int) -> void:
	if node is VisualInstance3D:
		node.layers = layer
	for child in node.get_children():
		_set_layers(child, layer)


func _make_render_only(node: Node, layer: int) -> void:
	if node is VisualInstance3D:
		node.layers = layer
	if node is CSGShape3D and node.is_root_shape():
		node.use_collision = false
	if node is CollisionObject3D:
		node.collision_layer = 0
		node.collision_mask = 0
		node.process_mode = Node.PROCESS_MODE_DISABLED
	for child in node.get_children():
		_make_render_only(child, layer)
